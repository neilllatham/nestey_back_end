import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Utilities
function computePayPeriodsElapsed(date = new Date()) {
  // Bi-weekly schedule assumption (26 per year)
  // Add 13 days before dividing to count the current, in-progress period as elapsed
  const start = new Date(date.getFullYear(), 0, 1);
  const days = Math.floor((date - start) / (1000 * 60 * 60 * 24));
  return Math.floor((days + 13) / 14);
}

function usd(n) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(n || 0);
}

async function getBenefitsData(employee_id) {
  const raw = await prisma.employee_benefits.findMany({
    where: { employee_id },
    include: {
      benefit_plan: {
        include: { benefits_catalog: true }
      }
    }
  });

  const items = raw.map((eb) => {
    const plan = eb.benefit_plan || {};
    const catalog = Array.isArray(plan.benefits_catalog)
      ? plan.benefits_catalog[0]
      : plan.benefits_catalog;
    const category = catalog?.benefit_category || 'Other';
    const name = catalog?.benefit_name || plan?.plan_name || 'Benefit';
    // Treat costs as per pay period
    const employee_pays = Number(plan?.employee_pays || catalog?.employee_pays || 0);
    const employer_pays = Number(plan?.employer_pays || catalog?.employer_pays || 0);
    const total_plan_cost = employee_pays + employer_pays;
    return { category, name, employee_pays, employer_pays, total_plan_cost };
  });

  const byCategory = items.reduce((acc, it) => {
    acc[it.category] = acc[it.category] || [];
    acc[it.category].push(it);
    return acc;
  }, {});

  const totals = items.reduce(
    (acc, it) => {
      acc.total_employee_pays += it.employee_pays;
      acc.total_employer_pays += it.employer_pays;
      acc.total_cost += it.total_plan_cost;
      return acc;
    },
    { total_employee_pays: 0, total_employer_pays: 0, total_cost: 0 }
  );

  return { items, byCategory, totals };
}

async function getDependentsInfo(employee_id) {
  // Pull dependants counts across all enrolled benefits
  const rows = await prisma.employee_benefits.findMany({
    where: { employee_id },
    select: {
      dependants: true,
      benefit_plan: {
        select: {
          benefits_catalog: {
            select: { benefit_category: true }
          }
        }
      }
    }
  });

  const counts = rows.map(r => Number(r.dependants || 0));
  const overall = counts.length ? Math.max(...counts) : 0;

  // Build a simple category breakdown (use the max per category)
  const byCategory = {};
  rows.forEach(r => {
    const cat = Array.isArray(r?.benefit_plan?.benefits_catalog)
      ? r.benefit_plan.benefits_catalog[0]?.benefit_category
      : r?.benefit_plan?.benefits_catalog?.benefit_category;
    const key = cat || 'Other';
    const n = Number(r.dependants || 0);
    byCategory[key] = Math.max(byCategory[key] || 0, n);
  });

  return { overall, byCategory };
}

// Call Ollama API
async function askOllama(prompt) {
  try {
    const response = await fetch('http://localhost:11434/api/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: 'llama3.2',
        prompt: prompt,
        stream: false
      })
    });
    
    if (!response.ok) throw new Error('Ollama request failed');
    const data = await response.json();
    return data.response;
  } catch (error) {
    console.error('Ollama error:', error);
    return null;
  }
}

// POST /api/chat - Smart chat with database context
router.post('/', async (req, res) => {
  try {
    const { message, employee_id } = req.body;

    if (!message || !employee_id) {
      return res.status(400).json({ error: 'message and employee_id required' });
    }

  const msg = String(message || '').toLowerCase();
    let context = '';
    let enhancedPrompt = '';
  const today = new Date();
  const payPeriodsElapsed = computePayPeriodsElapsed(today);

    // Gather relevant database context based on question
    
    // PTO/Time Off related
    if (msg.includes('pto') || msg.includes('time off') || msg.includes('vacation') || msg.includes('balance')) {
      const balance = await prisma.$queryRaw`
        SELECT type, accrued_days, used_days, remaining_days 
        FROM time_off_accruals 
        WHERE employee_id = ${employee_id} AND year = ${new Date().getFullYear()}
      `;
      
      const requests = await prisma.time_off_requests.findMany({
        where: { employee_id },
        orderBy: { created_at: 'desc' },
        take: 5
      });
      
      context = `Employee's Time Off Data:
PTO Balance: ${balance.find(b => b.type === 'PTO')?.remaining_days || 0} days remaining
Sick Leave: ${balance.find(b => b.type === 'Sick Leave')?.remaining_days || 0} days remaining
Recent Requests: ${requests.map(r => `${r.type} from ${r.start_date.toISOString().split('T')[0]} to ${r.end_date.toISOString().split('T')[0]} (${r.status})`).join(', ')}`;
    }
    
    // Benefits related
    if (msg.includes('benefit') || msg.includes('medical') || msg.includes('dental') || msg.includes('vision') || msg.includes('insurance')) {
      const { items, byCategory, totals } = await getBenefitsData(employee_id);

      const lines = items.map((it) => `${it.category}: ${it.name} — You pay ${usd(it.employee_pays)} per pay period; Employer pays ${usd(it.employer_pays)} per pay period`);
      const perPeriodSummary = `Per pay period totals — You pay: ${usd(totals.total_employee_pays)}; Employer pays: ${usd(totals.total_employer_pays)}; Combined: ${usd(totals.total_cost)}`;

      context = `Employee's Benefits (costs are per pay period, bi-weekly):
${lines.join('\n')}

${perPeriodSummary}`;
    }

    // Intercept deterministic questions to avoid AI mistakes
    // 0) Dependents count
    if (
      (msg.includes('how many') || msg.includes('number of') || msg.includes('count of')) &&
      (msg.includes('dependent') || msg.includes('dependant'))
    ) {
      const { overall, byCategory } = await getDependentsInfo(employee_id);
      const cats = Object.entries(byCategory)
        .filter(([, v]) => v > 0)
        .map(([k, v]) => `${k}: ${v}`);
      const breakdown = cats.length ? `\nBreakdown — ${cats.join(' · ')}` : '';
      return res.json({
        response: `You have ${overall} dependents on file.${breakdown}`,
        hasContext: true
      });
    }
    // A) How many pay periods so far this year
    if (
      (msg.includes('how many') && msg.includes('pay period')) ||
      (msg.includes('pay periods') && (msg.includes('as of') || msg.includes('have i had'))) ||
      msg.includes('number of pay periods')
    ) {
      return res.json({
        response: `As of ${today.toLocaleDateString('en-US')}, you've had approximately ${payPeriodsElapsed} pay periods (bi-weekly schedule, 26 per year).`,
        hasContext: false
      });
    }

    // B) YTD amounts paid for benefits (overall or by category)
    if (
      (msg.includes('how much') || msg.includes('what have') || msg.includes('what did') || msg.includes('ytd') || msg.includes('year to date')) &&
      (msg.includes('benefit') || msg.includes('medical') || msg.includes('dental') || msg.includes('vision'))
    ) {
      const { byCategory, totals } = await getBenefitsData(employee_id);
      const category = msg.includes('medical') ? 'Medical' : msg.includes('dental') ? 'Dental' : msg.includes('vision') ? 'Vision' : null;

      if (category) {
        const list = byCategory[category] || [];
        if (list.length === 0) {
          return res.json({ response: `You don't have any ${category.toLowerCase()} benefits enrolled.`, hasContext: false });
        }
        const perPeriodEmployee = list.reduce((s, b) => s + (b.employee_pays || 0), 0);
        const perPeriodEmployer = list.reduce((s, b) => s + (b.employer_pays || 0), 0);
        const ytdEmployee = perPeriodEmployee * payPeriodsElapsed;
        const ytdEmployer = perPeriodEmployer * payPeriodsElapsed;
        const ytdTotal = ytdEmployee + ytdEmployer;
        return res.json({
          response: `${category} — Year-to-date (${payPeriodsElapsed} pay periods as of ${today.toLocaleDateString('en-US')}):\n\nYou've paid: ${usd(ytdEmployee)}\nYour employer paid: ${usd(ytdEmployer)}\nTotal: ${usd(ytdTotal)}\n\nNote: Costs are per pay period (bi-weekly).`,
          hasContext: true
        });
      } else {
        const perPeriodEmployee = totals.total_employee_pays;
        const perPeriodEmployer = totals.total_employer_pays;
        const ytdEmployee = perPeriodEmployee * payPeriodsElapsed;
        const ytdEmployer = perPeriodEmployer * payPeriodsElapsed;
        const ytdTotal = ytdEmployee + ytdEmployer;
        return res.json({
          response: `All benefits — Year-to-date (${payPeriodsElapsed} pay periods as of ${today.toLocaleDateString('en-US')}):\n\nYou've paid: ${usd(ytdEmployee)}\nYour employer paid: ${usd(ytdEmployer)}\nTotal: ${usd(ytdTotal)}\n\nNote: Costs are per pay period (bi-weekly).`,
          hasContext: true
        });
      }
    }

    // Build enhanced prompt with context
    if (context) {
      const policy = `Important rules:\n- All costs shown are per pay period (bi-weekly). Do not convert to monthly unless explicitly asked.\n- If asked for YTD totals, use ${payPeriodsElapsed} pay periods as of ${today.toLocaleDateString('en-US')}.\n- If numbers are provided below, use them verbatim without recomputing.`;
      enhancedPrompt = `You are Nestey, a helpful HR assistant. Answer the employee's question using ONLY the data provided below. Be concise and friendly.

${policy}

${context}

Employee Question: ${message}

Your Answer:`;
    } else {
      enhancedPrompt = `You are Nestey, a helpful HR assistant. Answer this employee question briefly and professionally:

${message}`;
    }

    // Get response from Ollama
    const aiResponse = await askOllama(enhancedPrompt);
    
    if (!aiResponse) {
      return res.status(500).json({ 
        error: 'AI service unavailable',
        fallback: 'I can help with PTO, benefits, and approvals. Try asking about your balance or benefits.'
      });
    }

    res.json({ 
      response: aiResponse,
      hasContext: !!context
    });

  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ error: 'Failed to process chat request' });
  }
});

export default router;

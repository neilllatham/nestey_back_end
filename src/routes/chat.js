import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

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

    const msg = message.toLowerCase();
    let context = '';
    let enhancedPrompt = '';

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
      const benefits = await prisma.employee_benefits.findMany({
        where: { employee_id },
        include: {
          benefit_plan: {
            include: {
              benefits_catalog: true
            }
          }
        }
      });
      
      const benefitsList = benefits.map(eb => {
        const catalog = Array.isArray(eb.benefit_plan.benefits_catalog) 
          ? eb.benefit_plan.benefits_catalog[0] 
          : eb.benefit_plan.benefits_catalog;
        
        if (!catalog) return null;
        
        return `${catalog.benefit_category}: ${catalog.benefit_name} - You pay $${catalog.employee_pays}, Employer pays $${catalog.employer_pays}, ${eb.dependants} dependents`;
      }).filter(Boolean);
      
      context = `Employee's Benefits:
${benefitsList.join('\n')}`;
    }

    // Build enhanced prompt with context
    if (context) {
      enhancedPrompt = `You are Nestey, a helpful HR assistant. Answer the employee's question using ONLY the data provided below. Be concise and friendly.

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

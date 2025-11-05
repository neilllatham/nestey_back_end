import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// GET /api/benefits?employee_id=X - Get all benefits for an employee
router.get('/', async (req, res) => {
  try {
    const { employee_id } = req.query;

    if (!employee_id) {
      return res.status(400).json({ error: 'employee_id is required' });
    }

    const employeeId = parseInt(employee_id);

    // Get all employee benefits with related catalog and plan data
    const employeeBenefits = await prisma.employee_benefits.findMany({
      where: { employee_id: employeeId },
      include: {
        benefit_plan: {
          include: {
            benefits_catalog: true
          }
        }
      }
    });

    // Transform data - each employee_benefit maps to ONE catalog entry
    const benefits = employeeBenefits.map(eb => {
      // Get the first catalog entry (or handle if there are multiple)
      const catalog = Array.isArray(eb.benefit_plan.benefits_catalog) 
        ? eb.benefit_plan.benefits_catalog[0] 
        : eb.benefit_plan.benefits_catalog;
      
      if (!catalog) return null;
      
      return {
        employee_benefit_id: eb.employee_benefit_id,
        benefit_name: catalog.benefit_name,
        benefit_category: catalog.benefit_category,
        description: catalog.description,
        dependants: eb.dependants,
        employee_contribution_pct: catalog.employee_contribution,
        employer_contribution_pct: catalog.employer_contribution,
        employee_pays: parseFloat(catalog.employee_pays || 0),
        employer_pays: parseFloat(catalog.employer_pays || 0),
        total_plan_cost: parseFloat(catalog.total_plan_cost || 0),
        plan_name: eb.benefit_plan.plan_name,
        coverage_level: eb.benefit_plan.coverage_level,
        effective_date: eb.effective_date,
        expiry_date: eb.expiry_date
      };
    }).filter(Boolean);

    // Calculate totals
    const totals = {
      total_employee_pays: benefits.reduce((sum, b) => sum + b.employee_pays, 0),
      total_employer_pays: benefits.reduce((sum, b) => sum + b.employer_pays, 0),
      total_cost: benefits.reduce((sum, b) => sum + b.total_plan_cost, 0)
    };

    // Group by category
    const byCategory = benefits.reduce((acc, benefit) => {
      const cat = benefit.benefit_category || 'Other';
      if (!acc[cat]) acc[cat] = [];
      acc[cat].push(benefit);
      return acc;
    }, {});

    res.json({
      benefits,
      byCategory,
      totals
    });

  } catch (error) {
    console.error('Error fetching benefits:', error);
    res.status(500).json({ error: 'Failed to fetch benefits' });
  }
});

export default router;

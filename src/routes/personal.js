import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// GET /api/personal?employee_id=X - Get personal information for an employee
router.get('/', async (req, res) => {
  try {
    const { employee_id } = req.query;

    if (!employee_id) {
      return res.status(400).json({ error: 'employee_id is required' });
    }

    const employeeId = parseInt(employee_id);

    // Get employee data with all related information
    const employee = await prisma.employees.findUnique({
      where: { employee_id: employeeId },
      select: {
        employee_number: true,
        full_name: true,
        preferred_name: true,
        job_title: true,
        hire_date: true,
        departments: {
          select: {
            department_name: true,
            functions: {
              select: {
                function_name: true
              }
            }
          }
        },
        roles: {
          select: {
            role_name: true
          }
        },
        manager: {
          select: {
            full_name: true,
            job_title: true
          }
        }
      }
    });

    if (!employee) {
      return res.status(404).json({ error: 'Employee not found' });
    }

    // Structure the response
    const personalInfo = {
      employee_number: employee.employee_number,
      full_name: employee.full_name,
      preferred_name: employee.preferred_name,
      job_title: employee.job_title,
      hire_date: employee.hire_date,
      department_name: employee.departments?.department_name || null,
      function_name: employee.departments?.functions?.function_name || null,
      role_name: employee.roles?.role_name || null,
      manager_name: employee.manager?.full_name || null,
      manager_title: employee.manager?.job_title || null
    };

    res.json(personalInfo);

  } catch (error) {
    console.error('Personal info error:', error);
    res.status(500).json({ error: 'Failed to retrieve personal information' });
  }
});

export default router;
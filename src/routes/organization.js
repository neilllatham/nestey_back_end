import express from 'express';
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

// NOTE: Removed deprecated /direct-reports route that used an undefined raw db client.
// Direct reports are now returned inline with /employee/:employee_id response.

// Get organization info for an employee (including their manager and direct reports)
router.get('/employee/:employee_id', async (req, res) => {
  try {
    const { employee_id } = req.params;
    const employeeId = parseInt(employee_id);
    console.log(`[org] Request employee ${employeeId}`);
    
    // Get employee with manager info
    const employee = await prisma.employees.findUnique({
      where: { employee_id: employeeId },
      include: {
        manager: true
      }
    });
    console.log('[org] Employee lookup complete');
    
    if (!employee) {
      return res.status(404).json({ 
        success: false, 
        error: 'Employee not found' 
      });
    }
    
    // Get direct reports
    const directReports = await prisma.employees.findMany({
      where: { manager_id: employeeId },
      orderBy: { full_name: 'asc' }
    });
    console.log(`[org] Direct reports count: ${directReports.length}`);
    
    res.json({
      success: true,
      employee: {
        id: employee.employee_id,
        name: employee.full_name,
        preferred_name: employee.preferred_name,
        title: employee.job_title,
        department: employee.department_name,
        function: employee.function_name,
        role: employee.role_name
      },
      manager: employee.manager ? {
        id: employee.manager.employee_id,
        name: employee.manager.full_name,
        title: employee.manager.job_title,
        department: employee.manager.department_name
      } : null,
      directReports: directReports.map(report => ({
        id: report.employee_id,
        name: report.full_name,
        title: report.job_title,
        department: report.department_name
      }))
    });
    console.log('[org] Response sent');
  } catch (error) {
    console.error('Error fetching organization data:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to fetch organization data' 
    });
  }
});

export default router;
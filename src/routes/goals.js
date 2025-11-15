import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// GET /api/goals - Fetch goals data for employee based on state
router.get('/', async (req, res) => {
  try {
    const { employee_id, state } = req.query;

    if (!employee_id) {
      return res.status(400).json({ error: 'employee_id is required' });
    }

    console.log(`Fetching goals for employee ${employee_id} in state: ${state}`);

    // Get employee info for manager lookup
    const employee = await prisma.employees.findUnique({
      where: { employee_id: parseInt(employee_id) },
      include: {
        manager: true,
        roles: {
          include: {
            role_levels: true
          }
        }
      }
    });

    if (!employee) {
      return res.status(404).json({ error: 'Employee not found' });
    }

    // Get current active review cycle
    const currentCycle = await prisma.review_cycles.findFirst({
      where: { 
        is_active: true,
        status: 'Open'
      }
    });

    if (!currentCycle) {
      return res.status(404).json({ error: 'No active review cycle found' });
    }

    // Get or create employee review for current cycle
    let employeeReview = await prisma.employee_reviews.findFirst({
      where: {
        employee_id: parseInt(employee_id),
        review_cycle_id: currentCycle.review_cycle_id
      }
    });

    if (!employeeReview) {
      // Create review if it doesn't exist
      employeeReview = await prisma.employee_reviews.create({
        data: {
          employee_id: parseInt(employee_id),
          review_cycle_id: currentCycle.review_cycle_id,
          review_status: 'Draft'
        }
      });
    }

    // Get manager's goals (if employee has a manager)
    let managerGoals = [];
    if (employee.manager_id) {
      const managerReview = await prisma.employee_reviews.findFirst({
        where: {
          employee_id: employee.manager_id,
          review_cycle_id: currentCycle.review_cycle_id
        }
      });

      if (managerReview) {
        managerGoals = await prisma.employee_goals.findMany({
          where: { review_id: managerReview.review_id },
          include: {
            strategies: true
          }
        });
      }
    }

    // Get employee's own goals
    const myGoals = await prisma.employee_goals.findMany({
      where: { review_id: employeeReview.review_id },
      include: {
        strategies: true
      }
    });

    let competencies = [];
    let reviewData = null;

    // For end-of-year state, also get competencies and overall review data
    if (state === 'end-year') {
      // Get competencies based on employee's role level
      const roleCompetencies = await prisma.competency_definitions.findMany({
        where: {
          role_level_code: employee.roles?.role_level_code
        },
        include: {
          competency: true
        }
      });

      // Get employee competency ratings
      const employeeCompetencies = await prisma.employee_competencies.findMany({
        where: { review_id: employeeReview.review_id },
        include: {
          competency: true
        }
      });

      // Merge competencies with employee ratings
      competencies = roleCompetencies.map(roleDef => {
        const empComp = employeeCompetencies.find(ec => 
          ec.competency_id === roleDef.competency_id
        );

        return {
          competency_id: roleDef.competency_id,
          competency_name: roleDef.competency.competency_name,
          description: roleDef.competency.description,
          expected_behavior: roleDef.expected_behavior,
          employee_rating: empComp?.employee_rating || null,
          manager_rating: empComp?.manager_rating || null,
          employee_comments: empComp?.employee_comments || null,
          manager_comments: empComp?.manager_comments || null
        };
      });

      reviewData = {
        review_id: employeeReview.review_id,
        review_status: employeeReview.review_status,
        employee_overall_comments: employeeReview.employee_overall_comments,
        manager_overall_comments: employeeReview.manager_overall_comments,
        employee_overall_rating: employeeReview.employee_overall_rating,
        manager_overall_rating: employeeReview.manager_overall_rating,
        submitted_at: employeeReview.submitted_at,
        finalized_at: employeeReview.finalized_at
      };
    }

    // Get available strategies for dropdowns
    const strategies = await prisma.strategies.findMany({
      orderBy: { strategy_name: 'asc' }
    });

    // Get rating scale for reference
    const ratingScale = await prisma.rating_scale.findMany({
      orderBy: { rating_value: 'asc' }
    });

    const responseData = {
      employee: {
        employee_id: employee.employee_id,
        full_name: employee.full_name,
        job_title: employee.job_title,
        manager_name: employee.manager?.full_name || null,
        role_level: employee.roles?.role_levels?.role_level_name || null
      },
      reviewCycle: {
        review_cycle_id: currentCycle.review_cycle_id,
        name: currentCycle.name,
        cycle_type: currentCycle.cycle_type,
        status: currentCycle.status
      },
      managerGoals: managerGoals.map(goal => ({
        goal_id: goal.goal_id,
        strategy_name: goal.strategies?.strategy_name || null,
        objective: goal.objective,
        goal_description: goal.goal_description,
        target_date: goal.target_date,
        employee_rating: goal.employee_rating,
        manager_rating: goal.manager_rating,
        status: goal.status
      })),
      myGoals: myGoals.map(goal => ({
        goal_id: goal.goal_id,
        strategy_id: goal.strategy_id,
        strategy_name: goal.strategies?.strategy_name || null,
        objective: goal.objective,
        goal_description: goal.goal_description,
        target_date: goal.target_date,
        employee_rating: goal.employee_rating,
        manager_rating: goal.manager_rating,
        status: goal.status,
        created_at: goal.created_at,
        updated_at: goal.updated_at
      })),
      competencies,
      review: reviewData,
      strategies: strategies.map(s => ({
        strategy_id: s.strategy_id,
        strategy_name: s.strategy_name,
        description: s.description
      })),
      ratingScale: ratingScale.map(r => ({
        rating_value: r.rating_value,
        rating_label: r.rating_label,
        description: r.description
      })),
      state,
      canEdit: ['Draft'].includes(employeeReview.review_status)
    };

    console.log(`Successfully fetched goals data for employee ${employee_id}`);
    res.json(responseData);

  } catch (error) {
    console.error('Error fetching goals:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      message: error.message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});

// POST /api/goals - Create a new goal
router.post('/', async (req, res) => {
  try {
    const { employee_id, review_cycle_id, strategy_id, objective, goal_description, target_date } = req.body;

    if (!employee_id || !review_cycle_id) {
      return res.status(400).json({ error: 'employee_id and review_cycle_id are required' });
    }

    // Get or create employee review
    let employeeReview = await prisma.employee_reviews.findFirst({
      where: {
        employee_id: parseInt(employee_id),
        review_cycle_id: parseInt(review_cycle_id)
      }
    });

    if (!employeeReview) {
      employeeReview = await prisma.employee_reviews.create({
        data: {
          employee_id: parseInt(employee_id),
          review_cycle_id: parseInt(review_cycle_id),
          review_status: 'Draft'
        }
      });
    }

    // Create the goal
    const newGoal = await prisma.employee_goals.create({
      data: {
        review_id: employeeReview.review_id,
        strategy_id: strategy_id ? parseInt(strategy_id) : null,
        objective: objective || '',
        goal_description: goal_description || '',
        target_date: target_date ? new Date(target_date) : null,
        status: 'active'
      },
      include: {
        strategies: true
      }
    });

    console.log(`Created new goal ${newGoal.goal_id} for employee ${employee_id}`);
    res.status(201).json({
      goal_id: newGoal.goal_id,
      strategy_id: newGoal.strategy_id,
      strategy_name: newGoal.strategies?.strategy_name || null,
      objective: newGoal.objective,
      goal_description: newGoal.goal_description,
      target_date: newGoal.target_date,
      status: newGoal.status,
      created_at: newGoal.created_at
    });

  } catch (error) {
    console.error('Error creating goal:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      message: error.message 
    });
  }
});

// PUT /api/goals/:goalId - Update a goal
router.put('/:goalId', async (req, res) => {
  try {
    const { goalId } = req.params;
    const { strategy_id, objective, goal_description, target_date, employee_rating } = req.body;

    const updatedGoal = await prisma.employee_goals.update({
      where: { goal_id: parseInt(goalId) },
      data: {
        ...(strategy_id !== undefined && { strategy_id: strategy_id ? parseInt(strategy_id) : null }),
        ...(objective !== undefined && { objective }),
        ...(goal_description !== undefined && { goal_description }),
        ...(target_date !== undefined && { target_date: target_date ? new Date(target_date) : null }),
        ...(employee_rating !== undefined && { employee_rating: employee_rating ? parseInt(employee_rating) : null }),
        updated_at: new Date()
      },
      include: {
        strategies: true
      }
    });

    console.log(`Updated goal ${goalId}`);
    res.json({
      goal_id: updatedGoal.goal_id,
      strategy_id: updatedGoal.strategy_id,
      strategy_name: updatedGoal.strategies?.strategy_name || null,
      objective: updatedGoal.objective,
      goal_description: updatedGoal.goal_description,
      target_date: updatedGoal.target_date,
      employee_rating: updatedGoal.employee_rating,
      status: updatedGoal.status,
      updated_at: updatedGoal.updated_at
    });

  } catch (error) {
    console.error('Error updating goal:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      message: error.message 
    });
  }
});

// DELETE /api/goals/:goalId - Delete a goal
router.delete('/:goalId', async (req, res) => {
  try {
    const { goalId } = req.params;

    await prisma.employee_goals.delete({
      where: { goal_id: parseInt(goalId) }
    });

    console.log(`Deleted goal ${goalId}`);
    res.json({ message: 'Goal deleted successfully' });

  } catch (error) {
    console.error('Error deleting goal:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      message: error.message 
    });
  }
});

// PUT /api/goals/review/:reviewId - Update overall review comments/ratings
router.put('/review/:reviewId', async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { employee_overall_comments, employee_overall_rating, review_status } = req.body;

    const updatedReview = await prisma.employee_reviews.update({
      where: { review_id: parseInt(reviewId) },
      data: {
        ...(employee_overall_comments !== undefined && { employee_overall_comments }),
        ...(employee_overall_rating !== undefined && { employee_overall_rating: employee_overall_rating ? parseInt(employee_overall_rating) : null }),
        ...(review_status !== undefined && { review_status }),
        ...(review_status === 'Submitted' && { submitted_at: new Date() }),
        updated_at: new Date()
      }
    });

    console.log(`Updated review ${reviewId}`);
    res.json({
      review_id: updatedReview.review_id,
      employee_overall_comments: updatedReview.employee_overall_comments,
      employee_overall_rating: updatedReview.employee_overall_rating,
      review_status: updatedReview.review_status,
      submitted_at: updatedReview.submitted_at,
      updated_at: updatedReview.updated_at
    });

  } catch (error) {
    console.error('Error updating review:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      message: error.message 
    });
  }
});

export default router;
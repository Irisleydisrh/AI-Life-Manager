const express = require('express');
const { body, validationResult, query } = require('express-validator');
const { prisma } = require('../../../config/database');
const { CreateGoalDTO, GoalResponseDTO } = require('../../../core/dto');
const authMiddleware = require('../../../middleware/auth.middleware');

const router = express.Router();
router.use(authMiddleware);

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }
  next();
};

// Get all goals
router.get('/', [
  query('status').optional().isIn(['active', 'completed', 'paused', 'cancelled']),
  query('category').optional().isIn(['health', 'career', 'finance', 'personal', 'learning'])
], validate, async (req, res) => {
  try {
    const { status, category } = req.query;
    
    const where = { userId: req.userId };
    if (status) where.status = status;
    if (category) where.category = category;
    
    const goals = await prisma.goal.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });
    
    res.json({ success: true, data: goals.map(g => GoalResponseDTO.from(g)) });
  } catch (error) {
    console.error('Get goals error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Create goal
router.post('/', [
  body('title').notEmpty().trim().isLength({ max: 500 }),
  body('description').optional().trim(),
  body('category').optional().isIn(['health', 'career', 'finance', 'personal', 'learning']),
  body('targetValue').optional().isFloat({ min: 0 }),
  body('currentValue').optional().isFloat({ min: 0 }),
  body('unit').optional().trim(),
  body('targetDate').optional().isISO8601(),
  body('milestones').optional().isArray()
], validate, async (req, res) => {
  try {
    const goalDTO = CreateGoalDTO.from(req.body);
    
    const progress = goalDTO.targetValue && goalDTO.currentValue 
      ? (goalDTO.currentValue / goalDTO.targetValue) * 100 
      : 0;
    
    const goal = await prisma.goal.create({
      data: {
        userId: req.userId,
        title: goalDTO.title,
        description: goalDTO.description,
        category: goalDTO.category,
        targetValue: goalDTO.targetValue,
        currentValue: goalDTO.currentValue || 0,
        unit: goalDTO.unit,
        targetDate: goalDTO.targetDate,
        progress: Math.min(progress, 100),
        milestones: goalDTO.milestones || []
      }
    });
    
    res.status(201).json({
      success: true,
      data: GoalResponseDTO.from(goal),
      message: 'Meta creada exitosamente'
    });
  } catch (error) {
    console.error('Create goal error:', error);
    if (error.message && error.message.includes('requerido')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get single goal
router.get('/:id', async (req, res) => {
  try {
    const goal = await prisma.goal.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!goal) {
      return res.status(404).json({ success: false, message: 'Meta no encontrada' });
    }
    
    res.json({ success: true, data: GoalResponseDTO.from(goal) });
  } catch (error) {
    console.error('Get goal error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update goal
router.put('/:id', [
  body('title').optional().trim().isLength({ max: 500 }),
  body('description').optional().trim(),
  body('category').optional().isIn(['health', 'career', 'finance', 'personal', 'learning']),
  body('targetValue').optional().isFloat({ min: 0 }),
  body('currentValue').optional().isFloat({ min: 0 }),
  body('unit').optional().trim(),
  body('status').optional().isIn(['active', 'completed', 'paused', 'cancelled']),
  body('targetDate').optional().isISO8601(),
  body('milestones').optional().isArray()
], validate, async (req, res) => {
  try {
    const existing = await prisma.goal.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!existing) {
      return res.status(404).json({ success: false, message: 'Meta no encontrada' });
    }
    
    const { title, description, category, targetValue, currentValue, unit, status, targetDate, milestones } = req.body;
    
    // Calculate progress if values provided
    let progress = existing.progress;
    if (targetValue !== undefined && currentValue !== undefined) {
      progress = targetValue > 0 ? (currentValue / targetValue) * 100 : 0;
    } else if (currentValue !== undefined && existing.targetValue) {
      progress = (currentValue / Number(existing.targetValue)) * 100;
    }
    
    const updateData = { progress: Math.min(progress, 100) };
    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (category !== undefined) updateData.category = category;
    if (targetValue !== undefined) updateData.targetValue = targetValue;
    if (currentValue !== undefined) updateData.currentValue = currentValue;
    if (unit !== undefined) updateData.unit = unit;
    if (status !== undefined) updateData.status = status;
    if (targetDate !== undefined) updateData.targetDate = targetDate;
    if (milestones !== undefined) updateData.milestones = milestones;
    
    const goal = await prisma.goal.update({
      where: { id: req.params.id },
      data: updateData
    });
    
    res.json({
      success: true,
      data: GoalResponseDTO.from(goal),
      message: 'Meta actualizada'
    });
  } catch (error) {
    console.error('Update goal error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Delete goal
router.delete('/:id', async (req, res) => {
  try {
    const goal = await prisma.goal.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!goal) {
      return res.status(404).json({ success: false, message: 'Meta no encontrada' });
    }
    
    await prisma.goal.delete({ where: { id: req.params.id } });
    
    res.json({ success: true, message: 'Meta eliminada' });
  } catch (error) {
    console.error('Delete goal error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update progress
router.patch('/:id/progress', [
  body('currentValue').isFloat({ min: 0 })
], validate, async (req, res) => {
  try {
    const { currentValue } = req.body;
    
    const goal = await prisma.goal.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!goal) {
      return res.status(404).json({ success: false, message: 'Meta no encontrada' });
    }
    
    const progress = goal.targetValue 
      ? Math.min((currentValue / Number(goal.targetValue)) * 100, 100)
      : 0;
    
    const updated = await prisma.goal.update({
      where: { id: req.params.id },
      data: {
        currentValue,
        progress
      }
    });
    
    // Auto-complete if 100%
    if (progress >= 100 && goal.status === 'active') {
      await prisma.goal.update({
        where: { id: req.params.id },
        data: { status: 'completed' }
      });
      updated.status = 'completed';
    }
    
    res.json({
      success: true,
      data: GoalResponseDTO.from(updated),
      message: 'Progreso actualizado'
    });
  } catch (error) {
    console.error('Update progress error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Toggle milestone
router.patch('/:id/milestone', [
  body('milestoneIndex').isInt({ min: 0 })
], validate, async (req, res) => {
  try {
    const { milestoneIndex } = req.body;
    
    const goal = await prisma.goal.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!goal) {
      return res.status(404).json({ success: false, message: 'Meta no encontrada' });
    }
    
    const milestones = goal.milestones || [];
    if (milestoneIndex >= milestones.length) {
      return res.status(400).json({ success: false, message: 'Índice de hito inválido' });
    }
    
    milestones[milestoneIndex].completed = !milestones[milestoneIndex].completed;
    if (milestones[milestoneIndex].completed && !milestones[milestoneIndex].date) {
      milestones[milestoneIndex].date = new Date().toISOString();
    }
    
    const updated = await prisma.goal.update({
      where: { id: req.params.id },
      data: { milestones }
    });
    
    res.json({
      success: true,
      data: GoalResponseDTO.from(updated),
      message: 'Hito actualizado'
    });
  } catch (error) {
    console.error('Toggle milestone error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get goals stats
router.get('/stats', async (req, res) => {
  try {
    const userId = req.userId;
    
    const [active, completed] = await Promise.all([
      prisma.goal.count({ where: { userId, status: 'active' } }),
      prisma.goal.count({ where: { userId, status: 'completed' } })
    ]);
    
    // Calculate average progress
    const activeGoals = await prisma.goal.findMany({
      where: { userId, status: 'active' },
      select: { progress: true }
    });
    
    const avgProgress = activeGoals.length > 0
      ? activeGoals.reduce((sum, g) => sum + Number(g.progress), 0) / activeGoals.length
      : 0;
    
    // At risk (progress < 50% and close to target date)
    const twoWeeksFromNow = new Date();
    twoWeeksFromNow.setDate(twoWeeksFromNow.getDate() + 14);
    
    const atRisk = await prisma.goal.count({
      where: {
        userId,
        status: 'active',
        progress: { lt: 50 },
        targetDate: { lt: twoWeeksFromNow, not: null }
      }
    });
    
    res.json({
      success: true,
      data: {
        active,
        completed,
        avgProgress: Math.round(avgProgress),
        atRisk
      }
    });
  } catch (error) {
    console.error('Get goals stats error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

module.exports = router;

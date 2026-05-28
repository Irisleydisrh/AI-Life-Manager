const express = require('express');
const { body, validationResult } = require('express-validator');
const { prisma } = require('../../../config/database');
const { CreateHabitDTO, HabitResponseDTO } = require('../../../core/dto');
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

// Get all habits
router.get('/', async (req, res) => {
  try {
    const habits = await prisma.habit.findMany({
      where: { userId: req.userId, isActive: true },
      orderBy: { createdAt: 'desc' }
    });
    
    res.json({ success: true, data: habits.map(h => HabitResponseDTO.from(h)) });
  } catch (error) {
    console.error('Get habits error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Create habit
router.post('/', [
  body('title').notEmpty().trim().isLength({ max: 255 }),
  body('description').optional().trim(),
  body('icon').optional().trim(),
  body('color').optional().trim(),
  body('frequency').optional().isIn(['daily', 'weekly', 'custom']),
  body('frequencyDays').optional().isArray(),
  body('targetCount').optional().isInt({ min: 1 }),
  body('reminderTime').optional().isString()
], validate, async (req, res) => {
  try {
    const habitDTO = CreateHabitDTO.from(req.body);
    
    const habit = await prisma.habit.create({
      data: {
        userId: req.userId,
        title: habitDTO.title,
        description: habitDTO.description,
        icon: habitDTO.icon,
        color: habitDTO.color,
        frequency: habitDTO.frequency,
        frequencyDays: habitDTO.frequencyDays,
        targetCount: habitDTO.targetCount,
        reminderTime: habitDTO.reminderTime
      }
    });
    
    res.status(201).json({
      success: true,
      data: HabitResponseDTO.from(habit),
      message: 'Hábito creado exitosamente'
    });
  } catch (error) {
    console.error('Create habit error:', error);
    if (error.message && error.message.includes('requerido')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get single habit with logs
router.get('/:id', async (req, res) => {
  try {
    const habit = await prisma.habit.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Hábito no encontrado' });
    }
    
    // Get recent logs (last 30 days)
    const logs = await prisma.habitLog.findMany({
      where: { habitId: req.params.id },
      orderBy: { loggedAt: 'desc' },
      take: 30
    });
    
    res.json({
      success: true,
      data: HabitResponseDTO.from(habit, logs)
    });
  } catch (error) {
    console.error('Get habit error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update habit
router.put('/:id', [
  body('title').optional().trim().isLength({ max: 255 }),
  body('description').optional().trim(),
  body('icon').optional().trim(),
  body('color').optional().trim(),
  body('frequency').optional().isIn(['daily', 'weekly', 'custom']),
  body('frequencyDays').optional().isArray(),
  body('targetCount').optional().isInt({ min: 1 }),
  body('reminderTime').optional().isString(),
  body('isActive').optional().isBoolean()
], validate, async (req, res) => {
  try {
    const existing = await prisma.habit.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!existing) {
      return res.status(404).json({ success: false, message: 'Hábito no encontrado' });
    }
    
    const allowedFields = ['title', 'description', 'icon', 'color', 'frequency', 'frequencyDays', 'targetCount', 'reminderTime', 'isActive'];
    const updateData = {};
    
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    }
    
    const habit = await prisma.habit.update({
      where: { id: req.params.id },
      data: updateData
    });
    
    res.json({
      success: true,
      data: HabitResponseDTO.from(habit),
      message: 'Hábito actualizado'
    });
  } catch (error) {
    console.error('Update habit error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Delete (soft delete) habit
router.delete('/:id', async (req, res) => {
  try {
    const habit = await prisma.habit.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Hábito no encontrado' });
    }
    
    await prisma.habit.update({
      where: { id: req.params.id },
      data: { isActive: false }
    });
    
    res.json({ success: true, message: 'Hábito eliminado' });
  } catch (error) {
    console.error('Delete habit error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Log habit completion
router.post('/:id/log', async (req, res) => {
  try {
    const habit = await prisma.habit.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Hábito no encontrado' });
    }
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // Check if already logged today
    const existingLog = await prisma.habitLog.findFirst({
      where: {
        habitId: req.params.id,
        loggedAt: { gte: today, lt: tomorrow }
      }
    });
    
    if (existingLog) {
      return res.status(400).json({ success: false, message: 'Ya registraste este hábito hoy' });
    }
    
    // Create log
    const log = await prisma.habitLog.create({
      data: {
        habitId: req.params.id,
        userId: req.userId,
        loggedAt: new Date(),
        count: 1
      }
    });
    
    // Update streak
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    yesterday.setHours(0, 0, 0, 0);
    
    const yesterdayLog = await prisma.habitLog.findFirst({
      where: {
        habitId: req.params.id,
        loggedAt: { gte: yesterday, lt: today }
      }
    });
    
    const newStreak = yesterdayLog ? habit.streakCurrent + 1 : 1;
    const bestStreak = Math.max(newStreak, habit.streakBest);
    
    await prisma.habit.update({
      where: { id: req.params.id },
      data: {
        streakCurrent: newStreak,
        streakBest: bestStreak
      }
    });
    
    res.status(201).json({
      success: true,
      data: log,
      message: 'Hábito registrado',
      streak: newStreak
    });
  } catch (error) {
    console.error('Log habit error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Remove log (undo)
router.delete('/:id/log/:date', async (req, res) => {
  try {
    const { date } = req.params;
    const logDate = new Date(date);
    
    const deleted = await prisma.habitLog.deleteMany({
      where: {
        habitId: req.params.id,
        userId: req.userId,
        loggedAt: {
          gte: logDate,
          lt: new Date(logDate.getTime() + 24 * 60 * 60 * 1000)
        }
      }
    });
    
    if (!deleted.count) {
      return res.status(404).json({ success: false, message: 'Log no encontrado' });
    }
    
    // Recalculate streak
    const logs = await prisma.habitLog.findMany({
      where: { habitId: req.params.id },
      orderBy: { loggedAt: 'desc' }
    });
    
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    for (let i = 0; i < logs.length; i++) {
      const expectedDate = new Date(today);
      expectedDate.setDate(expectedDate.getDate() - i);
      
      const logDate = new Date(logs[i].loggedAt);
      logDate.setHours(0, 0, 0, 0);
      
      if (logDate.getTime() === expectedDate.getTime()) {
        streak++;
      } else {
        break;
      }
    }
    
    await prisma.habit.update({
      where: { id: req.params.id },
      data: { streakCurrent: streak }
    });
    
    res.json({ success: true, message: 'Log eliminado', streak });
  } catch (error) {
    console.error('Remove log error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get habit history
router.get('/:id/history', async (req, res) => {
  try {
    const { page = 1, limit = 30 } = req.query;
    
    const [logs, total] = await Promise.all([
      prisma.habitLog.findMany({
        where: { habitId: req.params.id },
        orderBy: { loggedAt: 'desc' },
        skip: (page - 1) * limit,
        take: parseInt(limit)
      }),
      prisma.habitLog.count({ where: { habitId: req.params.id } })
    ]);
    
    res.json({
      success: true,
      data: logs,
      meta: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get history error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get habits stats
router.get('/stats', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const weekAgo = new Date(today);
    weekAgo.setDate(weekAgo.getDate() - 7);
    
    const userId = req.userId;
    
    // Active habits count
    const activeCount = await prisma.habit.count({
      where: { userId, isActive: true }
    });
    
    // Completed today
    const completedToday = await prisma.habitLog.count({
      where: {
        userId,
        loggedAt: { gte: today, lt: tomorrow }
      }
    });
    
    // Best streak
    const bestStreakHabit = await prisma.habit.findFirst({
      where: { userId, isActive: true },
      orderBy: { streakBest: 'desc' },
      select: { streakBest: true }
    });
    
    const completionRate = activeCount > 0 
      ? Math.round((completedToday / activeCount) * 100)
      : 0;
    
    res.json({
      success: true,
      data: {
        active: activeCount,
        completedToday,
        bestStreak: bestStreakHabit?.streakBest || 0,
        completionRate
      }
    });
  } catch (error) {
    console.error('Get habits stats error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

module.exports = router;

const express = require('express');
const { body, validationResult, query } = require('express-validator');
const { prisma } = require('../../../config/database');
const { CreateTaskDTO, UpdateTaskDTO, TaskResponseDTO } = require('../../../core/dto');
const authMiddleware = require('../../../middleware/auth.middleware');

const router = express.Router();
router.use(authMiddleware);

// Validation middleware
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }
  next();
};

// Get all tasks with filters
router.get('/', [
  query('status').optional().isIn(['pending', 'in_progress', 'completed', 'cancelled']),
  query('priority').optional().isIn(['low', 'medium', 'high', 'urgent']),
  query('search').optional().trim()
], validate, async (req, res) => {
  try {
    const { status, priority, search, dueDateFrom, dueDateTo, page = 1, limit = 20 } = req.query;
    
    const where = { userId: req.userId };
    
    if (status) where.status = status;
    if (priority) where.priority = priority;
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } }
      ];
    }
    if (dueDateFrom || dueDateTo) {
      where.dueDate = {};
      if (dueDateFrom) where.dueDate.gte = new Date(dueDateFrom);
      if (dueDateTo) where.dueDate.lte = new Date(dueDateTo);
    }
    
    const [tasks, total] = await Promise.all([
      prisma.task.findMany({
        where,
        orderBy: [{ position: 'asc' }, { createdAt: 'desc' }],
        skip: (page - 1) * limit,
        take: parseInt(limit)
      }),
      prisma.task.count({ where })
    ]);
    
    res.json({
      success: true,
      data: tasks.map(t => TaskResponseDTO.from(t)),
      meta: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Create task
router.post('/', [
  body('title').notEmpty().trim().isLength({ max: 500 }),
  body('description').optional().trim(),
  body('priority').optional().isIn(['low', 'medium', 'high', 'urgent']),
  body('dueDate').optional().isISO8601(),
  body('tags').optional().isArray()
], validate, async (req, res) => {
  try {
    // Validate with DTO
    const taskDTO = CreateTaskDTO.from(req.body);
    
    // Get max position
    const maxTask = await prisma.task.findFirst({
      where: { userId: req.userId },
      orderBy: { position: 'desc' },
      select: { position: true }
    });
    
    const task = await prisma.task.create({
      data: {
        userId: req.userId,
        title: taskDTO.title,
        description: taskDTO.description,
        priority: taskDTO.priority,
        dueDate: taskDTO.dueDate,
        tags: taskDTO.tags,
        position: (maxTask?.position || 0) + 1
      }
    });
    
    res.status(201).json({
      success: true,
      data: TaskResponseDTO.from(task),
      message: 'Tarea creada exitosamente'
    });
  } catch (error) {
    console.error('Create task error:', error);
    if (error.message && error.message.includes('requerido')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get single task
router.get('/:id', async (req, res) => {
  try {
    const task = await prisma.task.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!task) {
      return res.status(404).json({ success: false, message: 'Tarea no encontrada' });
    }
    
    res.json({ success: true, data: TaskResponseDTO.from(task) });
  } catch (error) {
    console.error('Get task error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update task
router.put('/:id', [
  body('title').optional().trim().isLength({ max: 500 }),
  body('description').optional().trim(),
  body('priority').optional().isIn(['low', 'medium', 'high', 'urgent']),
  body('status').optional().isIn(['pending', 'in_progress', 'completed', 'cancelled']),
  body('dueDate').optional().isISO8601(),
  body('tags').optional().isArray()
], validate, async (req, res) => {
  try {
    // Validate with DTO
    const updateData = UpdateTaskDTO.from(req.body);
    
    // Check if task exists
    const existingTask = await prisma.task.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!existingTask) {
      return res.status(404).json({ success: false, message: 'Tarea no encontrada' });
    }
    
    // Handle completed status
    if (updateData.status === 'completed' && existingTask.status !== 'completed') {
      updateData.completedAt = new Date();
    }
    
    const task = await prisma.task.update({
      where: { id: req.params.id },
      data: updateData
    });
    
    res.json({
      success: true,
      data: TaskResponseDTO.from(task),
      message: 'Tarea actualizada exitosamente'
    });
  } catch (error) {
    console.error('Update task error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Delete task
router.delete('/:id', async (req, res) => {
  try {
    const task = await prisma.task.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!task) {
      return res.status(404).json({ success: false, message: 'Tarea no encontrada' });
    }
    
    await prisma.task.delete({ where: { id: req.params.id } });
    
    res.json({ success: true, message: 'Tarea eliminada' });
  } catch (error) {
    console.error('Delete task error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update task status
router.patch('/:id/status', [
  body('status').isIn(['pending', 'in_progress', 'completed', 'cancelled'])
], validate, async (req, res) => {
  try {
    const { status } = req.body;
    
    const updateData = { status };
    if (status === 'completed') {
      updateData.completedAt = new Date();
    }
    
    const task = await prisma.task.updateMany({
      where: { id: req.params.id, userId: req.userId },
      data: updateData
    });
    
    if (!task.count) {
      return res.status(404).json({ success: false, message: 'Tarea no encontrada' });
    }
    
    const updated = await prisma.task.findUnique({ where: { id: req.params.id } });
    
    res.json({
      success: true,
      data: TaskResponseDTO.from(updated),
      message: 'Estado actualizado'
    });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Reorder tasks
router.patch('/reorder', [
  body('tasks').isArray()
], validate, async (req, res) => {
  try {
    const { tasks } = req.body; // [{ id, position }]
    
    // Update positions in bulk using transaction
    await prisma.$transaction(
      tasks.map(task => 
        prisma.task.updateMany({
          where: { id: task.id, userId: req.userId },
          data: { position: task.position }
        })
      )
    );
    
    res.json({
      success: true,
      message: 'Tareas reordenadas'
    });
  } catch (error) {
    console.error('Reorder tasks error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get task stats
router.get('/stats', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const weekAgo = new Date(today);
    weekAgo.setDate(weekAgo.getDate() - 7);
    
    const userId = req.userId;
    
    // Stats queries
    const [
      todayTotal,
      todayCompleted,
      weekTotal,
      weekCompleted,
      urgentCount,
      overdueCount
    ] = await Promise.all([
      prisma.task.count({ where: { userId, createdAt: { gte: today } } }),
      prisma.task.count({ where: { userId, createdAt: { gte: today }, status: 'completed' } }),
      prisma.task.count({ where: { userId, createdAt: { gte: weekAgo } } }),
      prisma.task.count({ where: { userId, createdAt: { gte: weekAgo }, status: 'completed' } }),
      prisma.task.count({ where: { userId, priority: 'urgent', status: 'pending' } }),
      prisma.task.count({ where: { 
        userId, 
        dueDate: { lt: today },
        status: { not: 'completed' }
      } })
    ]);
    
    res.json({
      success: true,
      data: {
        today: {
          total: todayTotal,
          completed: todayCompleted,
          pending: todayTotal - todayCompleted
        },
        thisWeek: {
          total: weekTotal,
          completed: weekCompleted
        },
        urgent: urgentCount,
        overdue: overdueCount
      }
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

module.exports = router;

const express = require('express');
const { body, validationResult, query } = require('express-validator');
const { prisma } = require('../../../config/database');
const { CreateExpenseDTO, ExpenseResponseDTO, BudgetDTO, FinanceSummaryDTO } = require('../../../core/dto');
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

// Get expenses with filters
router.get('/expenses', [
  query('category').optional().isIn(['food', 'transport', 'entertainment', 'health', 'housing', 'education', 'other']),
  query('type').optional().isIn(['expense', 'income']),
  query('dateFrom').optional().isISO8601(),
  query('dateTo').optional().isISO8601()
], validate, async (req, res) => {
  try {
    const { category, type, dateFrom, dateTo, page = 1, limit = 20 } = req.query;
    
    const where = { userId: req.userId };
    
    if (category) where.category = category;
    if (type) where.type = type;
    if (dateFrom || dateTo) {
      where.date = {};
      if (dateFrom) where.date.gte = new Date(dateFrom);
      if (dateTo) where.date.lte = new Date(dateTo);
    }
    
    const [expenses, total] = await Promise.all([
      prisma.expense.findMany({
        where,
        orderBy: [{ date: 'desc' }, { createdAt: 'desc' }],
        skip: (page - 1) * limit,
        take: parseInt(limit)
      }),
      prisma.expense.count({ where })
    ]);
    
    res.json({
      success: true,
      data: expenses.map(e => ExpenseResponseDTO.from(e)),
      meta: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get expenses error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Create expense
router.post('/expenses', [
  body('amount').isFloat({ min: 0.01 }),
  body('category').isIn(['food', 'transport', 'entertainment', 'health', 'housing', 'education', 'other']),
  body('type').optional().isIn(['expense', 'income']),
  body('description').optional().trim(),
  body('date').optional().isISO8601(),
  body('isRecurring').optional().isBoolean(),
  body('recurrence').optional().isIn(['daily', 'weekly', 'monthly']),
  body('tags').optional().isArray()
], validate, async (req, res) => {
  try {
    const expenseDTO = CreateExpenseDTO.from(req.body);
    
    const expense = await prisma.expense.create({
      data: {
        userId: req.userId,
        amount: expenseDTO.amount,
        category: expenseDTO.category,
        type: expenseDTO.type,
        description: expenseDTO.description,
        date: expenseDTO.date,
        isRecurring: expenseDTO.isRecurring,
        recurrence: expenseDTO.recurrence,
        tags: expenseDTO.tags
      }
    });
    
    res.status(201).json({
      success: true,
      data: ExpenseResponseDTO.from(expense),
      message: expenseDTO.type === 'income' ? 'Ingreso registrado' : 'Gasto registrado'
    });
  } catch (error) {
    console.error('Create expense error:', error);
    if (error.message && error.message.includes('mayor a 0')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get single expense
router.get('/expenses/:id', async (req, res) => {
  try {
    const expense = await prisma.expense.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!expense) {
      return res.status(404).json({ success: false, message: 'Registro no encontrado' });
    }
    
    res.json({ success: true, data: ExpenseResponseDTO.from(expense) });
  } catch (error) {
    console.error('Get expense error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update expense
router.put('/expenses/:id', [
  body('amount').optional().isFloat({ min: 0.01 }),
  body('category').optional().isIn(['food', 'transport', 'entertainment', 'health', 'housing', 'education', 'other']),
  body('type').optional().isIn(['expense', 'income']),
  body('description').optional().trim(),
  body('date').optional().isISO8601(),
  body('isRecurring').optional().isBoolean(),
  body('recurrence').optional().isIn(['daily', 'weekly', 'monthly']),
  body('tags').optional().isArray()
], validate, async (req, res) => {
  try {
    const existing = await prisma.expense.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!existing) {
      return res.status(404).json({ success: false, message: 'Registro no encontrado' });
    }
    
    const allowedFields = ['amount', 'category', 'type', 'description', 'date', 'isRecurring', 'recurrence', 'tags'];
    const updateData = {};
    
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    }
    
    const expense = await prisma.expense.update({
      where: { id: req.params.id },
      data: updateData
    });
    
    res.json({
      success: true,
      data: ExpenseResponseDTO.from(expense),
      message: 'Registro actualizado'
    });
  } catch (error) {
    console.error('Update expense error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Delete expense
router.delete('/expenses/:id', async (req, res) => {
  try {
    const expense = await prisma.expense.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!expense) {
      return res.status(404).json({ success: false, message: 'Registro no encontrado' });
    }
    
    await prisma.expense.delete({ where: { id: req.params.id } });
    
    res.json({ success: true, message: 'Registro eliminado' });
  } catch (error) {
    console.error('Delete expense error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get monthly summary
router.get('/summary', async (req, res) => {
  try {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
    
    // Use Prisma aggregation for sums
    const [incomeResult, expensesResult] = await Promise.all([
      prisma.expense.aggregate({
        where: { userId: req.userId, type: 'income', date: { gte: startOfMonth, lte: endOfMonth } },
        _sum: { amount: true }
      }),
      prisma.expense.aggregate({
        where: { userId: req.userId, type: 'expense', date: { gte: startOfMonth, lte: endOfMonth } },
        _sum: { amount: true }
      })
    ]);
    
    const income = Number(incomeResult._sum.amount) || 0;
    const expenses = Number(expensesResult._sum.amount) || 0;
    const balance = income - expenses;
    
    // Get weekly breakdown - fetch all expenses for the month and group in JS
    const monthExpenses = await prisma.expense.findMany({
      where: { userId: req.userId, date: { gte: startOfMonth, lte: endOfMonth } },
      select: { date: true, type: true, amount: true }
    });
    
    // Group by week
    const weeklyMap = {};
    for (const exp of monthExpenses) {
      const weekStart = new Date(exp.date);
      weekStart.setDate(weekStart.getDate() - weekStart.getDay());
      const weekKey = weekStart.toISOString().split('T')[0];
      
      if (!weeklyMap[weekKey]) {
        weeklyMap[weekKey] = { week: weekKey, expenses: 0, income: 0 };
      }
      if (exp.type === 'expense') {
        weeklyMap[weekKey].expenses += Number(exp.amount);
      } else {
        weeklyMap[weekKey].income += Number(exp.amount);
      }
    }
    
    const weeklyData = Object.values(weeklyMap).sort((a, b) => a.week.localeCompare(b.week));
    
    res.json({
      success: true,
      data: FinanceSummaryDTO.from(income, expenses, weeklyData)
    });
  } catch (error) {
    console.error('Get summary error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get monthly summary for range
router.get('/summary/monthly', async (req, res) => {
  try {
    const now = new Date();
    const twelveMonthsAgo = new Date(now.getFullYear() - 1, now.getMonth(), 1);
    
    // Fetch expenses for past 12 months and group by month in JS
    const expenses = await prisma.expense.findMany({
      where: { userId: req.userId, date: { gte: twelveMonthsAgo } },
      select: { date: true, type: true, amount: true }
    });
    
    // Group by month
    const monthlyMap = {};
    for (const exp of expenses) {
      const monthKey = `${exp.date.getFullYear()}-${String(exp.date.getMonth() + 1).padStart(2, '0')}`;
      
      if (!monthlyMap[monthKey]) {
        monthlyMap[monthKey] = { month: monthKey, expenses: 0, income: 0 };
      }
      if (exp.type === 'expense') {
        monthlyMap[monthKey].expenses += Number(exp.amount);
      } else {
        monthlyMap[monthKey].income += Number(exp.amount);
      }
    }
    
    const monthlyData = Object.values(monthlyMap).sort((a, b) => a.month.localeCompare(b.month));
    
    res.json({
      success: true,
      data: monthlyData
    });
  } catch (error) {
    console.error('Get monthly summary error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get expenses by category
router.get('/by-category', async (req, res) => {
  try {
    const { dateFrom, dateTo } = req.query;
    
    const where = { userId: req.userId, type: 'expense' };
    if (dateFrom || dateTo) {
      where.date = {};
      if (dateFrom) where.date.gte = new Date(dateFrom);
      if (dateTo) where.date.lte = new Date(dateTo);
    }
    
    const categories = await prisma.expense.groupBy({
      by: ['category'],
      where,
      _sum: { amount: true },
      _count: true,
      orderBy: { _sum: { amount: 'desc' } }
    });
    
    const formatted = categories.map(c => ({
      category: c.category,
      total: Number(c._sum.amount) || 0,
      count: c._count
    }));
    
    res.json({ success: true, data: formatted });
  } catch (error) {
    console.error('Get by category error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get budgets
router.get('/budgets', async (req, res) => {
  try {
    const budgets = await prisma.budget.findMany({
      where: { userId: req.userId },
      orderBy: { category: 'asc' }
    });
    
    res.json({ success: true, data: budgets });
  } catch (error) {
    console.error('Get budgets error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Create/update budget
router.post('/budgets', [
  body('category').isIn(['food', 'transport', 'entertainment', 'health', 'housing', 'education', 'other']),
  body('amount').isFloat({ min: 0 }),
  body('period').optional().isIn(['weekly', 'monthly', 'yearly'])
], validate, async (req, res) => {
  try {
    const { category, amount, period = 'monthly' } = req.body;
    
    const [budget] = await db('budgets')
      .insert({
        user_id: req.userId,
        category,
        amount,
        period
      })
      .onConflict(['user_id', 'category', 'period'])
      .merge()
      .returning('*');
    
    res.json({
      success: true,
      data: budget,
      message: 'Presupuesto actualizado'
    });
  } catch (error) {
    console.error('Create budget error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get budget status
router.get('/budgets/status', async (req, res) => {
  try {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    
    const budgets = await db('budgets')
      .where({ user_id: req.userId, period: 'monthly' });
    
    const budgetStatus = await Promise.all(
      budgets.map(async (budget) => {
        const [spent] = await db('expenses')
          .where({ user_id: req.userId, category: budget.category, type: 'expense' })
          .whereBetween('date', [startOfMonth, now])
          .sum('amount as total');
        
        const spentAmount = parseFloat(spent.total) || 0;
        const percentage = (spentAmount / budget.amount) * 100;
        
        return {
          category: budget.category,
          budget: budget.amount,
          spent: spentAmount,
          remaining: budget.amount - spentAmount,
          percentage: Math.round(percentage),
          status: percentage >= 100 ? 'over' : percentage >= 80 ? 'warning' : 'ok'
        };
      })
    );
    
    res.json({ success: true, data: budgetStatus });
  } catch (error) {
    console.error('Get budget status error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

module.exports = router;
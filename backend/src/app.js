const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100,
  standardHeaders: true,
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Routes
app.use('/api/v1/auth', require('./api/v1/routes/auth.routes'));
app.use('/api/v1/tasks', require('./api/v1/routes/tasks.routes'));
app.use('/api/v1/habits', require('./api/v1/routes/habits.routes'));
app.use('/api/v1/goals', require('./api/v1/routes/goals.routes'));
app.use('/api/v1/finance', require('./api/v1/routes/finance.routes'));
app.use('/api/v1/ai', require('./api/v1/routes/ai.routes'));
app.use('/api/v1/profile', require('./api/v1/routes/profile.routes'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

module.exports = app;
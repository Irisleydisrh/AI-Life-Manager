const express = require('express');
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const { prisma } = require('../../../config/database');
const { UpdateProfileDTO, UpdateSettingsDTO, ChangePasswordDTO, OnboardingDTO, ProfileResponseDTO, UserStatsDTO } = require('../../../core/dto');
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

// Multer config for avatar upload
const storage = multer.diskStorage({
  destination: './uploads/avatars',
  filename: (req, file, cb) => {
    cb(null, `${req.userId}-${Date.now()}${path.extname(file.originalname)}`);
  }
});
const upload = multer({
  storage,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880 },
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp/;
    const ext = allowed.test(path.extname(file.originalname).toLowerCase());
    const mime = allowed.test(file.mimetype);
    if (ext && mime) {
      cb(null, true);
    } else {
      cb(new Error('Solo imágenes permitidas'));
    }
  }
});

// Get full profile
router.get('/', async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId }
    });
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }
    
    const settings = await prisma.userSettings.findUnique({
      where: { userId: req.userId }
    });
    
    res.json({
      success: true,
      data: ProfileResponseDTO.from(user, settings)
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update profile
router.put('/', [
  body('fullName').optional().trim().isLength({ min: 1, max: 255 }),
  body('language').optional().isIn(['es', 'en']),
  body('theme').optional().isIn(['dark', 'light']),
  body('timezone').optional().trim()
], validate, async (req, res) => {
  try {
    const updateData = UpdateProfileDTO.from(req.body);
    
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: updateData
    });
    
    res.json({
      success: true,
      data: ProfileResponseDTO.from(user),
      message: 'Perfil actualizado'
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Update settings
router.put('/settings', [
  body('monthlyBudget').optional().isFloat({ min: 0 }),
  body('notificationsEnabled').optional().isBoolean(),
  body('aiContextEnabled').optional().isBoolean(),
  body('currency').optional().isLength({ min: 3, max: 3 }),
  body('weekStart').optional().isIn(['monday', 'sunday'])
], validate, async (req, res) => {
  try {
    const updateData = UpdateSettingsDTO.from(req.body);
    
    const settings = await prisma.userSettings.upsert({
      where: { userId: req.userId },
      update: updateData,
      create: { userId: req.userId, ...updateData }
    });
    
    res.json({
      success: true,
      data: settings,
      message: 'Configuración actualizada'
    });
  } catch (error) {
    console.error('Update settings error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Change password
router.put('/password', [
  body('currentPassword').notEmpty(),
  body('newPassword').isLength({ min: 6 })
], validate, async (req, res) => {
  try {
    const passwordDTO = ChangePasswordDTO.from(req.body);
    
    const user = await prisma.user.findUnique({
      where: { id: req.userId }
    });
    
    const isValid = await bcrypt.compare(passwordDTO.currentPassword, user.passwordHash);
    if (!isValid) {
      return res.status(400).json({ success: false, message: 'Contraseña actual incorrecta' });
    }
    
    const passwordHash = await bcrypt.hash(passwordDTO.newPassword, 12);
    
    await prisma.user.update({
      where: { id: req.userId },
      data: { passwordHash }
    });
    
    res.json({ success: true, message: 'Contraseña actualizada' });
  } catch (error) {
    console.error('Change password error:', error);
    if (error.message && error.message.includes('requerido')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Upload avatar
router.post('/avatar', upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No se recibió archivo' });
    }
    
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;
    
    await prisma.user.update({
      where: { id: req.userId },
      data: { avatarUrl }
    });
    
    res.json({
      success: true,
      data: { avatarUrl },
      message: 'Avatar actualizado'
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({ success: false, message: 'Error al subir imagen' });
  }
});

// Complete onboarding
router.post('/onboarding', [
  body('fullName').notEmpty().trim(),
  body('language').optional().isIn(['es', 'en']),
  body('theme').optional().isIn(['dark', 'light'])
], validate, async (req, res) => {
  try {
    const onboardingDTO = OnboardingDTO.from(req.body);
    
    await prisma.user.update({
      where: { id: req.userId },
      data: {
        fullName: onboardingDTO.fullName,
        language: onboardingDTO.language,
        theme: onboardingDTO.theme,
        onboardingCompleted: true
      }
    });
    
    res.json({
      success: true,
      message: 'Onboarding completado'
    });
  } catch (error) {
    console.error('Onboarding error:', error);
    if (error.message && error.message.includes('requerido')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Delete account (soft delete)
router.delete('/account', async (req, res) => {
  try {
    // Revoke all refresh tokens
    await prisma.refreshToken.deleteMany({
      where: { userId: req.userId }
    });
    
    res.json({
      success: true,
      message: 'Cuenta cerrada exitosamente'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get user stats
router.get('/stats', async (req, res) => {
  try {
    const userId = req.userId;
    
    const [
      totalTasks,
      completedTasks,
      activeHabits,
      completedGoals,
      user
    ] = await Promise.all([
      prisma.task.count({ where: { userId } }),
      prisma.task.count({ where: { userId, status: 'completed' } }),
      prisma.habit.count({ where: { userId, isActive: true } }),
      prisma.goal.count({ where: { userId, status: 'completed' } }),
      prisma.user.findUnique({
        where: { id: userId },
        select: { createdAt: true }
      })
    ]);
    
    const usageDays = Math.floor((new Date() - new Date(user.createdAt)) / (1000 * 60 * 60 * 24)) + 1;
    
    const stats = {
      totalTasks,
      completedTasks,
      activeHabits,
      completedGoals,
      usageDays
    };
    
    res.json({
      success: true,
      data: UserStatsDTO.from(stats)
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

module.exports = router;

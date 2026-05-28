// =====================================================
// DTOs - Data Transfer Objects
// Validan entrada y controlan salida de datos
// =====================================================

// ---------------- AUTH DTOs ----------------

class RegisterDTO {
  constructor(data) {
    this.email = data.email;
    this.password = data.password;
    this.fullName = data.fullName;
  }

  static from(data) {
    const dto = new RegisterDTO(data);
    // Validaciones adicionales
    if (!dto.email || !dto.email.includes('@')) {
      throw new Error('Email inválido');
    }
    if (!dto.password || dto.password.length < 6) {
      throw new Error('La contraseña debe tener al menos 6 caracteres');
    }
    if (!dto.fullName || dto.fullName.trim().length === 0) {
      throw new Error('El nombre es requerido');
    }
    return dto;
  }
}

class LoginDTO {
  constructor(data) {
    this.email = data.email;
    this.password = data.password;
  }

  static from(data) {
    const dto = new LoginDTO(data);
    if (!dto.email || !dto.email.includes('@')) {
      throw new Error('Email inválido');
    }
    if (!dto.password) {
      throw new Error('La contraseña es requerida');
    }
    return dto;
  }
}

class UserResponseDTO {
  static from(user) {
    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      language: user.language,
      theme: user.theme,
      avatarUrl: user.avatarUrl,
      onboardingCompleted: user.onboardingCompleted,
    };
  }
}

// ---------------- TASKS DTOs ----------------

class CreateTaskDTO {
  constructor(data) {
    this.title = data.title;
    this.description = data.description;
    this.priority = data.priority || 'medium';
    this.dueDate = data.dueDate;
    this.tags = data.tags || [];
  }

  static from(data) {
    const dto = new CreateTaskDTO(data);
    if (!dto.title || dto.title.trim().length === 0) {
      throw new Error('El título es requerido');
    }
    if (dto.title.length > 500) {
      throw new Error('El título no puede exceder 500 caracteres');
    }
    const validPriorities = ['low', 'medium', 'high', 'urgent'];
    if (dto.priority && !validPriorities.includes(dto.priority)) {
      throw new Error('Prioridad inválida');
    }
    return dto;
  }
}

class UpdateTaskDTO {
  static from(data) {
    const allowedFields = ['title', 'description', 'priority', 'status', 'dueDate', 'tags', 'position'];
    const dto = {};
    
    for (const field of allowedFields) {
      if (data[field] !== undefined) {
        dto[field] = data[field];
      }
    }
    
    return dto;
  }
}

class TaskResponseDTO {
  static from(task) {
    return {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      tags: task.tags,
      position: task.position,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: task.completedAt,
    };
  }
}

// ---------------- HABITS DTOs ----------------

class CreateHabitDTO {
  constructor(data) {
    this.title = data.title;
    this.description = data.description;
    this.icon = data.icon || '✨';
    this.color = data.color || '#6C63FF';
    this.frequency = data.frequency || 'daily';
    this.frequencyDays = data.frequencyDays;
    this.targetCount = data.targetCount || 1;
    this.reminderTime = data.reminderTime;
  }

  static from(data) {
    const dto = new CreateHabitDTO(data);
    if (!dto.title || dto.title.trim().length === 0) {
      throw new Error('El título es requerido');
    }
    const validFrequencies = ['daily', 'weekly', 'custom'];
    if (dto.frequency && !validFrequencies.includes(dto.frequency)) {
      throw new Error('Frecuencia inválida');
    }
    return dto;
  }
}

class HabitResponseDTO {
  static from(habit, logs = []) {
    return {
      id: habit.id,
      title: habit.title,
      description: habit.description,
      icon: habit.icon,
      color: habit.color,
      frequency: habit.frequency,
      frequencyDays: habit.frequencyDays,
      targetCount: habit.targetCount,
      reminderTime: habit.reminderTime,
      isActive: habit.isActive,
      streakCurrent: habit.streakCurrent,
      streakBest: habit.streakBest,
      createdAt: habit.createdAt,
      logs: logs.map(log => ({
        id: log.id,
        loggedAt: log.loggedAt,
        count: log.count,
        notes: log.notes,
      })),
    };
  }
}

// ---------------- GOALS DTOs ----------------

class CreateGoalDTO {
  constructor(data) {
    this.title = data.title;
    this.description = data.description;
    this.category = data.category;
    this.targetValue = data.targetValue;
    this.currentValue = data.currentValue || 0;
    this.unit = data.unit;
    this.targetDate = data.targetDate;
    this.milestones = data.milestones || [];
  }

  static from(data) {
    const dto = new CreateGoalDTO(data);
    if (!dto.title || dto.title.trim().length === 0) {
      throw new Error('El título es requerido');
    }
    const validCategories = ['health', 'career', 'finance', 'personal', 'learning'];
    if (dto.category && !validCategories.includes(dto.category)) {
      throw new Error('Categoría inválida');
    }
    return dto;
  }
}

class GoalResponseDTO {
  static from(goal) {
    return {
      id: goal.id,
      title: goal.title,
      description: goal.description,
      category: goal.category,
      targetValue: goal.targetValue,
      currentValue: goal.currentValue,
      unit: goal.unit,
      status: goal.status,
      startDate: goal.startDate,
      targetDate: goal.targetDate,
      progress: goal.progress,
      milestones: goal.milestones,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    };
  }
}

// ---------------- FINANCE DTOs ----------------

class CreateExpenseDTO {
  constructor(data) {
    this.amount = data.amount;
    this.category = data.category;
    this.description = data.description;
    this.date = data.date || new Date();
    this.type = data.type || 'expense';
    this.isRecurring = data.isRecurring || false;
    this.recurrence = data.recurrence;
    this.tags = data.tags || [];
  }

  static from(data) {
    const dto = new CreateExpenseDTO(data);
    if (!dto.amount || dto.amount <= 0) {
      throw new Error('El monto debe ser mayor a 0');
    }
    const validCategories = ['food', 'transport', 'entertainment', 'health', 'housing', 'education', 'other'];
    if (!dto.category || !validCategories.includes(dto.category)) {
      throw new Error('Categoría inválida');
    }
    const validTypes = ['expense', 'income'];
    if (dto.type && !validTypes.includes(dto.type)) {
      throw new Error('Tipo inválido');
    }
    return dto;
  }
}

class ExpenseResponseDTO {
  static from(expense) {
    return {
      id: expense.id,
      amount: expense.amount,
      currency: expense.currency,
      category: expense.category,
      description: expense.description,
      date: expense.date,
      type: expense.type,
      isRecurring: expense.isRecurring,
      recurrence: expense.recurrence,
      tags: expense.tags,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    };
  }
}

class BudgetDTO {
  constructor(data) {
    this.category = data.category;
    this.amount = data.amount;
    this.period = data.period || 'monthly';
  }

  static from(data) {
    const dto = new BudgetDTO(data);
    const validCategories = ['food', 'transport', 'entertainment', 'health', 'housing', 'education', 'other'];
    if (!dto.category || !validCategories.includes(dto.category)) {
      throw new Error('Categoría inválida');
    }
    if (!dto.amount || dto.amount <= 0) {
      throw new Error('El monto debe ser mayor a 0');
    }
    return dto;
  }
}

class FinanceSummaryDTO {
  static from(income, expenses, weeklyData) {
    return {
      income: parseFloat(income) || 0,
      expenses: parseFloat(expenses) || 0,
      balance: (parseFloat(income) || 0) - (parseFloat(expenses) || 0),
      weekly: weeklyData,
    };
  }
}

// ---------------- AI DTOs ----------------

class AIMessageDTO {
  constructor(data) {
    this.content = data.content;
  }

  static from(data) {
    const dto = new AIMessageDTO(data);
    if (!dto.content || dto.content.trim().length === 0) {
      throw new Error('El mensaje es requerido');
    }
    return dto;
  }
}

class AIConversationDTO {
  static from(conversation, messages = []) {
    return {
      id: conversation.id,
      title: conversation.title,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      messages: messages.map(msg => ({
        id: msg.id,
        role: msg.role,
        content: msg.content,
        createdAt: msg.createdAt,
      })),
    };
  }
}

class AIInsightsDTO {
  static from(insights, summary) {
    return {
      insights: insights || [],
      summary: summary || {
        pendingTasks: 0,
        urgentTasks: 0,
        activeHabits: 0,
        activeGoals: 0,
        monthExpenses: 0,
      },
    };
  }
}

// ---------------- PROFILE DTOs ----------------

class UpdateProfileDTO {
  static from(data) {
    const allowedFields = ['fullName', 'language', 'theme', 'timezone'];
    const dto = {};
    
    for (const field of allowedFields) {
      if (data[field] !== undefined) {
        dto[field] = data[field];
      }
    }
    
    return dto;
  }
}

class UpdateSettingsDTO {
  static from(data) {
    const allowedFields = ['monthlyBudget', 'notificationsEnabled', 'aiContextEnabled', 'currency', 'weekStart'];
    const dto = {};
    
    for (const field of allowedFields) {
      if (data[field] !== undefined) {
        dto[field] = data[field];
      }
    }
    
    return dto;
  }
}

class ChangePasswordDTO {
  constructor(data) {
    this.currentPassword = data.currentPassword;
    this.newPassword = data.newPassword;
  }

  static from(data) {
    const dto = new ChangePasswordDTO(data);
    if (!dto.currentPassword) {
      throw new Error('La contraseña actual es requerida');
    }
    if (!dto.newPassword || dto.newPassword.length < 6) {
      throw new Error('La nueva contraseña debe tener al menos 6 caracteres');
    }
    return dto;
  }
}

class OnboardingDTO {
  constructor(data) {
    this.fullName = data.fullName;
    this.language = data.language || 'es';
    this.theme = data.theme || 'dark';
  }

  static from(data) {
    const dto = new OnboardingDTO(data);
    if (!dto.fullName || dto.fullName.trim().length === 0) {
      throw new Error('El nombre es requerido');
    }
    return dto;
  }
}

class ProfileResponseDTO {
  static from(user, settings = null) {
    const response = {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      avatarUrl: user.avatarUrl,
      language: user.language,
      theme: user.theme,
      timezone: user.timezone,
      onboardingCompleted: user.onboardingCompleted,
      createdAt: user.createdAt,
    };
    
    if (settings) {
      response.settings = {
        monthlyBudget: settings.monthlyBudget,
        notificationsEnabled: settings.notificationsEnabled,
        aiContextEnabled: settings.aiContextEnabled,
        currency: settings.currency,
        weekStart: settings.weekStart,
      };
    }
    
    return response;
  }
}

class UserStatsDTO {
  static from(stats) {
    return {
      totalTasks: stats.totalTasks || 0,
      completedTasks: stats.completedTasks || 0,
      activeHabits: stats.activeHabits || 0,
      completedGoals: stats.completedGoals || 0,
      usageDays: stats.usageDays || 0,
    };
  }
}

// Export all DTOs
module.exports = {
  // Auth
  RegisterDTO,
  LoginDTO,
  UserResponseDTO,
  
  // Tasks
  CreateTaskDTO,
  UpdateTaskDTO,
  TaskResponseDTO,
  
  // Habits
  CreateHabitDTO,
  HabitResponseDTO,
  
  // Goals
  CreateGoalDTO,
  GoalResponseDTO,
  
  // Finance
  CreateExpenseDTO,
  ExpenseResponseDTO,
  BudgetDTO,
  FinanceSummaryDTO,
  
  // AI
  AIMessageDTO,
  AIConversationDTO,
  AIInsightsDTO,
  
  // Profile
  UpdateProfileDTO,
  UpdateSettingsDTO,
  ChangePasswordDTO,
  OnboardingDTO,
  ProfileResponseDTO,
  UserStatsDTO,
};
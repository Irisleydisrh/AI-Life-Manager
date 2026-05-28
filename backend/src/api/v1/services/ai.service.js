const OpenAI = require('openai');
const { prisma } = require('../../../config/database');
const { redisClient } = require('../../../config/redis');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const SYSTEM_PROMPT = `Eres un asistente personal de productividad y bienestar llamado "ARIA" (AI Real-time Intelligent Assistant). 
Tu rol es ayudar al usuario a organizar su vida, alcanzar sus metas y mantener hábitos saludables.
Tienes acceso al contexto real del usuario (tareas, hábitos, metas, finanzas) y debes usarlo para dar consejos personalizados.
Responde siempre en el idioma del usuario. Sé motivador, práctico y conciso.
Cuando el usuario te pida crear/modificar algo, extrae los datos estructurados y devuélvelos en JSON dentro de <action> tags.`;

// Build user context from database
async function buildUserContext(userId) {
  const today = new Date();
  const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
  
  const [tasks, habits, goals, expenses, settings] = await Promise.all([
    db('tasks').where({ user_id: userId, status: 'pending' }).limit(10),
    db('habits').where({ user_id: userId, is_active: true }),
    db('goals').where({ user_id: userId, status: 'active' }),
    db('expenses').where({ user_id: userId })
      .whereBetween('date', [startOfMonth, today])
      .limit(50),
    db('user_settings').where({ user_id: userId }).first()
  ]);
  
  const userLanguage = settings?.language || 'es';
  
  const urgentTasks = tasks.filter(t => t.priority === 'urgent');
  const totalExpenses = expenses.reduce((sum, e) => sum + parseFloat(e.amount), 0);
  
  const sortedHabits = [...habits].sort((a, b) => b.streak_current - a.streak_current);
  
  return {
    language: userLanguage,
    pendingTasks: tasks.length,
    urgentTasks: urgentTasks.length,
    activeHabits: habits.length,
    activeGoals: goals.length,
    monthExpenses: totalExpenses,
    topHabits: sortedHabits.slice(0, 3),
    urgentTaskTitles: urgentTasks.map(t => t.title),
    goalProgress: goals.map(g => `${g.title} (${Math.round(g.progress)}%)`)
  };
}

// Send message with streaming
async function sendMessageStream(userId, conversationHistory, userMessage, onChunk, onComplete) {
  // Check if AI context is enabled
  const settings = await db('user_settings').where({ user_id: userId }).first();
  let contextInfo = '';
  
  if (settings?.ai_context_enabled) {
    const context = await buildUserContext(userId);
    contextInfo = `
Contexto del usuario (actualizado):
- Tareas pendientes: ${context.pendingTasks} (urgentes: ${context.urgentTasks})
- Hábitos activos: ${context.activeHabits}
- Metas en progreso: ${context.activeGoals}
- Gastos del mes: $${context.monthExpenses.toFixed(2)}

${context.urgentTasks > 0 ? `Tareas urgentes: ${context.urgentTaskTitles.join(', ')}` : ''}
${context.topHabits.length > 0 ? `Hábitos con mejor racha: ${context.topHabits.map(h => `${h.title} (${h.streak_current} días)`).join(', ')}` : ''}
${context.goalProgress.length > 0 ? `Metas principales: ${context.goalProgress.join(', ')}` : ''}
`.trim();
  }
  
  // Build messages for API
  const messages = [
    { role: 'system', content: SYSTEM_PROMPT + (contextInfo ? '\n\n' + contextInfo : '') }
  ];
  
  // Add conversation history
  for (const msg of conversationHistory) {
    messages.push({
      role: msg.role === 'user' ? 'user' : 'assistant',
      content: msg.content
    });
  }
  
  // Add current message
  messages.push({ role: 'user', content: userMessage });
  
  try {
    const stream = await openai.chat.completions.create({
      model: process.env.OPENAI_MODEL || 'gpt-4o',
      messages,
      stream: true,
      max_tokens: parseInt(process.env.AI_MAX_TOKENS) || 1000
    });
    
    let fullResponse = '';
    
    for await (const chunk of stream) {
      const content = chunk.choices[0]?.delta?.content || '';
      if (content) {
        fullResponse += content;
        onChunk(content);
      }
    }
    
    await onComplete(fullResponse);
  } catch (error) {
    console.error('OpenAI error:', error);
    onChunk('Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.');
    await onComplete('Lo siento, hubo un error al procesar tu mensaje.');
  }
}

// Get AI insights for dashboard
async function getInsights(userId) {
  // Check cache first
  const cacheKey = `insights:${userId}`;
  try {
    if (redisClient.isOpen) {
      const cached = await redisClient.get(cacheKey);
      if (cached) return JSON.parse(cached);
    }
  } catch (e) {
    console.log('Cache miss for insights');
  }
  
  const context = await buildUserContext(userId);
  const language = context.language;
  
  let insights = [];
  
  // Task insights
  if (context.urgentTasks > 0) {
    const text = language === 'es' 
      ? `Tienes ${context.urgentTasks} tarea${context.urgentTasks > 1 ? 's' : ''} urgente${context.urgentTasks > 1 ? 's' : ''} que requiere${context.urgentTasks > 1 ? 'n' : ''} atención inmediata.`
      : `You have ${context.urgentTasks} urgent task${context.urgentTasks > 1 ? 's' : ''} that need${context.urgentTasks > 1 ? '' : 's'} immediate attention.`;
    insights.push({ type: 'tasks', priority: 'high', message: text });
  }
  
  // Habit insights
  if (context.topHabits.length > 0 && context.topHabits[0].streak_current >= 3) {
    const text = language === 'es'
      ? `Tu racha de ${context.topHabits[0].title} va increíble (${context.topHabits[0].streak_current} días). ¡Sigue así!`
      : `Your ${context.topHabits[0].title} streak is amazing (${context.topHabits[0].streak_current} days). Keep it up!`;
    insights.push({ type: 'habits', priority: 'good', message: text });
  }
  
  // Finance insights
  const monthlyBudget = 1000; // Default, should get from settings
  if (context.monthExpenses > monthlyBudget * 0.8) {
    const text = language === 'es'
      ? `Esta semana gastaste $${(context.monthExpenses - monthlyBudget).toFixed(2)} más de lo planeado. Considera ajustar tus gastos.`
      : `This week you spent $${(context.monthExpenses - monthlyBudget).toFixed(2)} more than planned. Consider adjusting your spending.`;
    insights.push({ type: 'finance', priority: 'warning', message: text });
  }
  
  // Goal insights
  if (context.activeGoals > 0) {
    const text = language === 'es'
      ? `Tienes ${context.activeGoals} meta${context.activeGoals > 1 ? 's' : ''} en progreso. ¡Sigue trabajando en ellas!`
      : `You have ${context.activeGoals} goal${context.activeGoals > 1 ? 's' : ''} in progress. Keep working on them!`;
    insights.push({ type: 'goals', priority: 'info', message: text });
  }
  
  // Cache for 5 minutes
  try {
    if (redisClient.isOpen) {
      await redisClient.setEx(cacheKey, 300, JSON.stringify(insights));
    }
  } catch (e) {
    console.log('Cache set failed');
  }
  
  return {
    insights,
    summary: {
      pendingTasks: context.pendingTasks,
      urgentTasks: context.urgentTasks,
      activeHabits: context.activeHabits,
      activeGoals: context.activeGoals,
      monthExpenses: context.monthExpenses
    }
  };
}

module.exports = { sendMessageStream, getInsights };
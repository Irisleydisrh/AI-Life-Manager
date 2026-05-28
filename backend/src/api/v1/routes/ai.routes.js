const express = require('express');
const { body, validationResult } = require('express-validator');
const { prisma } = require('../../../config/database');
const { AIMessageDTO, AIConversationDTO, AIInsightsDTO } = require('../../../core/dto');
const authMiddleware = require('../../../middleware/auth.middleware');
const aiService = require('../services/ai.service');

const router = express.Router();
router.use(authMiddleware);

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }
  next();
};

// Get all conversations
router.get('/conversations', async (req, res) => {
  try {
    const conversations = await prisma.aIConversation.findMany({
      where: { userId: req.userId },
      orderBy: { updatedAt: 'desc' }
    });
    
    res.json({ success: true, data: conversations });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Create new conversation
router.post('/conversations', async (req, res) => {
  try {
    const conversation = await prisma.aIConversation.create({
      data: {
        userId: req.userId,
        title: 'Nueva conversación'
      }
    });
    
    res.status(201).json({
      success: true,
      data: conversation,
      message: 'Conversación creada'
    });
  } catch (error) {
    console.error('Create conversation error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get single conversation with messages
router.get('/conversations/:id', async (req, res) => {
  try {
    const conversation = await prisma.aIConversation.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversación no encontrada' });
    }
    
    const messages = await prisma.aIMessage.findMany({
      where: { conversationId: req.params.id },
      orderBy: { createdAt: 'asc' }
    });
    
    res.json({
      success: true,
      data: AIConversationDTO.from(conversation, messages)
    });
  } catch (error) {
    console.error('Get conversation error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Delete conversation
router.delete('/conversations/:id', async (req, res) => {
  try {
    const conversation = await prisma.aIConversation.findFirst({
      where: { id: req.params.id, userId: req.userId }
    });
    
    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversación no encontrada' });
    }
    
    await prisma.aIConversation.delete({ where: { id: req.params.id } });
    
    res.json({ success: true, message: 'Conversación eliminada' });
  } catch (error) {
    console.error('Delete conversation error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Send message with SSE streaming
router.post('/conversations/:id/message', [
  body('content').notEmpty().trim()
], validate, async (req, res) => {
  try {
    const messageDTO = AIMessageDTO.from(req.body);
    const { content } = messageDTO;
    const conversationId = req.params.id;
    
    // Verify conversation belongs to user
    const conversation = await prisma.aIConversation.findFirst({
      where: { id: conversationId, userId: req.userId }
    });
    
    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversación no encontrada' });
    }
    
    // Save user message
    const userMessage = await prisma.aIMessage.create({
      data: {
        conversationId,
        userId: req.userId,
        role: 'user',
        content
      }
    });
    
    // Get conversation history
    const messages = await prisma.aIMessage.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' }
    });
    
    // Set headers for SSE
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    
    // Get AI response with streaming
    await aiService.sendMessageStream(req.userId, messages, content, (chunk) => {
      res.write(`data: ${JSON.stringify({ content: chunk })}\n\n`);
    }, async (fullResponse) => {
      // Save assistant message
      const assistantMessage = await prisma.aIMessage.create({
        data: {
          conversationId,
          userId: req.userId,
          role: 'assistant',
          content: fullResponse,
          metadata: { tokens_used: fullResponse.length }
        }
      });
      
      // Update conversation title if it's the first message
      if (messages.length === 0 && content.length > 30) {
        await prisma.aIConversation.update({
          where: { id: conversationId },
          data: { 
            title: content.substring(0, 50) + (content.length > 50 ? '...' : '')
          }
        });
      }
      
      // Update conversation timestamp
      await prisma.aIConversation.update({
        where: { id: conversationId },
        data: { updatedAt: new Date() }
      });
      
      res.write(`data: ${JSON.stringify({ done: true, messageId: assistantMessage.id })}\n\n`);
      res.end();
    });
  } catch (error) {
    console.error('Send message error:', error);
    if (error.message && error.message.includes('requerido')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Get AI insights
router.get('/insights', async (req, res) => {
  try {
    const insights = await aiService.getInsights(req.userId);
    
    res.json({
      success: true,
      data: AIInsightsDTO.from(insights.insights, insights.summary)
    });
  } catch (error) {
    console.error('Get insights error:', error);
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

module.exports = router;

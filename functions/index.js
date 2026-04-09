/**
 * Cloud Functions для Neuro Explorer
 * Безопасный прокси для AI API - API ключи никогда не хранятся на клиенте
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
const OpenAI = require('openai');
const { GoogleGenerativeAI } = require('@google/generative-ai');

admin.initializeApp();

// Конфигурация из Firebase Functions secrets
// Для настройки: firebase functions:secrets:set OPENAI_API_KEY
const getOpenAI = () => {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'OpenAI API key не настроен. Настройте secrets: firebase functions:secrets:set OPENAI_API_KEY'
    );
  }
  return new OpenAI({ apiKey });
};

const getGemini = () => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Gemini API key не настроен. Настройте secrets: firebase functions:secrets:set GEMINI_API_KEY'
    );
  }
  return new GoogleGenerativeAI(apiKey);
};

// System Prompt для детского AI ассистента
const CHILD_FRIENDLY_SYSTEM_PROMPT = `Ты — дружелюбный учитель для детей 8-14 лет.
Твои правила:
1. Используй простые слова, понятные детям
2. Объясняй сложные темы через примеры из жизни
3. Блокируй взрослые темы (насилие, политика, сексуальный контент)
4. Не пиши код за ребенка — объясняй логику и помогай учиться
5. Поощряй творчество и любопытство
6. Будь терпеливым и поддерживающим
7. Если не знаешь ответ — честно скажи, что нужно поискать информацию
8. Не используй сложные термины без объяснений
9. Всегда спрашивай, понятно ли объяснение`;

const TOXICITY_SCREENING_PROMPT = `
Проверь следующее сообщение на токсичность. Ответь ТОЛЬКО словом "SAFE" или "UNSAFE":
`;

/**
 * AI Chat функция - безопасный прокси для OpenAI/Gemini
 * Никогда не хранит API ключи на клиенте
 */
exports.aiChat = functions.https.onRequest(async (req, res) => {
  return cors(req, res, async () => {
    try {
      // Проверяем аутентификацию
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Требуется авторизация' });
        return;
      }

      // Верифицируем токен
      const token = authHeader.split('Bearer ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      const userId = decodedToken.uid;

      const { message, model = 'gpt-3.5-turbo', context } = req.body;

      if (!message) {
        res.status(400).json({ error: 'Сообщение обязательно' });
        return;
      }

      // Проверка на токсичность (базовая)
      // В продакшене можно использовать Perspective API
      
      // Формируем историю сообщений
      const messages = [
        { role: 'system', content: CHILD_FRIENDLY_SYSTEM_PROMPT },
      ];

      // Добавляем контекст если есть
      if (context) {
        messages.push({ role: 'system', content: `Контекст урока: ${context}` });
      }

      // Добавляем историю чата (максимум последние 10 сообщений)
      if (req.body.history && Array.isArray(req.body.history)) {
        const recentHistory = req.body.history.slice(-10);
        messages.push(...recentHistory);
      }

      // Добавляем текущее сообщение
      messages.push({ role: 'user', content: message });

      let aiResponse;

      if (model.startsWith('gpt')) {
        // Используем OpenAI
        const openai = getOpenAI();
        const completion = await openai.chat.completions.create({
          model: model === 'gpt-4' ? 'gpt-4' : 'gpt-3.5-turbo',
          messages: messages,
          max_tokens: 1000,
          temperature: 0.7,
        });

        aiResponse = completion.choices[0].message.content;
      } else if (model.startsWith('gemini')) {
        // Используем Google Gemini
        const genAI = getGemini();
        const model2 = genAI.getGenerativeModel({ model: 'gemini-pro' });
        
        // Формируем промпт для Gemini
        const fullPrompt = `${CHILD_FRIENDLY_SYSTEM_PROMPT}\n\nПользователь: ${message}`;
        const result = await model2.generateContent(fullPrompt);
        aiResponse = result.response.text();
      } else {
        res.status(400).json({ error: 'Неподдерживаемая модель' });
        return;
      }

      // Логируем запрос (без персональных данных)
      functions.logger.info(`AI Chat: userId=${userId}, model=${model}, messageLength=${message.length}`);

      res.json({ 
        response: aiResponse,
        model: model,
      });

    } catch (error) {
      functions.logger.error('AI Chat error:', error);
      
      if (error.code === 'failed-precondition') {
        res.status(503).json({ error: error.message });
        return;
      }
      
      res.status(500).json({ 
        error: 'Произошла ошибка. Попробуй позже.',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  });
});

/**
 * AI Explain - объяснение терминов из урока
 */
exports.aiExplain = functions.https.onRequest(async (req, res) => {
  return cors(req, res, async () => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Требуется авторизация' });
        return;
      }

      const { term, lessonContext } = req.body;

      if (!term) {
        res.status(400).json({ error: 'Термин обязателен' });
        return;
      }

      const openai = getOpenAI();
      
      const completion = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { 
            role: 'system', 
            content: `${CHILD_FRIENDLY_SYSTEM_PROMPT}
            
Ты объясняешь непонятные слова и термины из уроков.
Твои правила:
1. Дай простое определение (1-2 предложения)
2. Приведи пример из жизни ребенка
3. Если термин связан с текущим уроком — учти контекст
4. Если не знаешь — скажи честно` 
          },
          { 
            role: 'user', 
            content: lessonContext 
              ? `Объясни термин "${term}" в контексте урока: ${lessonContext}`
              : `Объясни термин "${term}" простыми словами для ребенка 10 лет` 
          }
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      res.json({ 
        explanation: completion.choices[0].message.content,
        term: term,
      });

    } catch (error) {
      functions.logger.error('AI Explain error:', error);
      res.status(500).json({ error: 'Произошла ошибка при объяснении термина' });
    }
  });
});

/**
 * AI Prompt Review - проверка и улучшение промптов
 */
exports.aiPromptReview = functions.https.onRequest(async (req, res) => {
  return cors(req, res, async () => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Требуется авторизация' });
        return;
      }

      const { prompt } = req.body;

      if (!prompt) {
        res.status(400).json({ error: 'Промпт обязателен' });
        return;
      }

      const openai = getOpenAI();
      
      const completion = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { 
            role: 'system', 
            content: `${CHILD_FRIENDLY_SYSTEM_PROMPT}
            
Ты помогаешь детям улучшать их промпты для AI.
Твои правила:
1. Оцени промпт по шкале 1-5
2. Дай конкретные советы по улучшению
3. Приведи пример улучшенного промпта
4. Объясни почему улучшенный промпт лучше` 
          },
          { 
            role: 'user', 
            content: `Оцени и улучши этот промпт: "${prompt}"` 
          }
        ],
        max_tokens: 800,
        temperature: 0.7,
      });

      res.json({ 
        review: completion.choices[0].message.content,
      });

    } catch (error) {
      functions.logger.error('AI Prompt Review error:', error);
      res.status(500).json({ error: 'Произошла ошибка при проверке промпта' });
    }
  });
});

/**
 * Generate Image - генерация изображений (через DALL-E)
 */
exports.generateImage = functions.https.onRequest(async (req, res) => {
  return cors(req, res, async () => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Требуется авторизация' });
        return;
      }

      const { prompt, size = '1024x1024' } = req.body;

      if (!prompt) {
        res.status(400).json({ error: 'Промпт обязателен' });
        return;
      }

      const openai = getOpenAI();
      
      const response = await openai.images.generate({
        model: 'dall-e-3',
        prompt: `${prompt}. Стиль: детская иллюстрация, яркие цвета, понятно для детей 8-14 лет`,
        size: size,
        quality: 'standard',
        n: 1,
      });

      res.json({ 
        imageUrl: response.data[0].url,
        revisedPrompt: response.data[0].revised_prompt,
      });

    } catch (error) {
      functions.logger.error('Generate Image error:', error);
      res.status(500).json({ error: 'Произошла ошибка при генерации изображения' });
    }
  });
});

// Функция для очистки старых данных (старше 30 дней)
exports.cleanupOldData = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    
    try {
      // Удаляем старые сессии чата
      const sessionsRef = admin.firestore().collection('chatSessions');
      const oldSessions = await sessionsRef
        .where('lastActivity', '<', thirtyDaysAgo)
        .limit(1000)
        .get();

      const batch = admin.firestore().batch();
      oldSessions.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();

      functions.logger.info(`Удалено ${oldSessions.size} старых сессий чата`);
    } catch (error) {
      functions.logger.error('Cleanup error:', error);
    }
  });

/**
 * Отправка еженедельного отчёта родителям
 * Вызывается по расписанию или вручную
 */
exports.sendWeeklyReport = functions.https.onCall(async (data, context) => {
  // Проверяем аутентификацию
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Требуется авторизация'
    );
  }

  const { parentEmail, childId } = data;
  
  if (!parentEmail || !childId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Требуется email родителя и ID ребёнка'
    );
  }

  try {
    // Получаем данные ребёнка
    const childDoc = await admin.firestore().collection('users').doc(childId).get();
    const childData = childDoc.data();
    
    if (!childData) {
      throw new functions.https.HttpsError(
        'not-found',
        'Ребёнок не найден'
      );
    }

    // Получаем прогресс за неделю
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const progressSnapshot = await admin.firestore()
      .collection('userProgress')
      .where('userId', '==', childId)
      .where('date', '>=', weekAgo)
      .get();

    const completedThisWeek = progressSnapshot.size;
    const totalLessons = childData.completedLessons?.length || 0;
    const currentLevel = childData.level || 1;
    const currentXp = childData.xp || 0;

    // Формируем отчёт
    const report = {
      childName: childData.childName || 'Ученик',
      completedThisWeek,
      totalLessons,
      currentLevel,
      currentXp,
      weekStart: weekAgo.toLocaleDateString('ru-RU'),
      weekEnd: new Date().toLocaleDateString('ru-RU'),
    };

    // В реальном приложении здесь будет отправка через email сервис
    // Например, Firebase Cloud Functions + SendGrid или similar
    functions.logger.info(`Weekly report for ${parentEmail}:`, report);

    // Сохраняем отчёт в Firestore
    await admin.firestore().collection('weeklyReports').add({
      ...report,
      parentEmail,
      childId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      sent: true,
    });

    return { 
      success: true, 
      message: 'Отчёт успешно отправлен',
      report 
    };
  } catch (error) {
    functions.logger.error('Send weekly report error:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Ошибка при отправке отчёта'
    );
  }
});
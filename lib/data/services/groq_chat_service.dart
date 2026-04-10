import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';

class GroqChatService {
  static final GroqChatService _instance = GroqChatService._internal();
  factory GroqChatService() => _instance;
  GroqChatService._internal();

  List<Map<String, dynamic>> _chatHistory = [];
  int _messageCountToday = 0;
  DateTime _lastResetDate = DateTime.now();

  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Твои ключи Groq
  static const List<String> _apiKeys = [
    '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',
    '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',
  ];
  
  int _currentKeyIndex = 0;

  // Лимиты
  static const int _dailyLimit = 50; // 50 сообщений в день бесплатно
  static const int _unlimitedLimit = 999999; // Безлимит для подписчиков с AI
  
  // Список заблокированных тем для детей
  static const List<String> _blockedTopics = [
    'убийство', 'убить', 'смерть', 'насилие', 'наркотики', 'алкоголь',
    'оружие', 'взрывчатка', 'террор', 'экстремизм', 'порно', 'секс',
    'расизм', 'дискриминация', 'суицид', 'самоубийство', 'вымогательство',
    'шантаж', 'хакер', 'взлом', 'кража', 'мошенничество', 'обман',
  ];
  
  static const String _systemPrompt = '''Ты — дружелюбный учитель для детей 10-14 лет.
 Твои правила:
 1. Используй простые слова, понятные детям
 2. Объясняй сложные темы через примеры из жизни
 3. Блокируй взрослые темы (насилие, политика, сексуальный контент)
 4. Не пиши код за ребёнка — объясняй логику
 5. Поощряй творчество и любопытство
 6. Будь терпеливым и поддерживающим
 7. Если не знаешь ответ — честно скажи
 8. Не используй сложные термины без объяснений''';

  bool _isContentAllowed(String message) {
    final lowerMessage = message.toLowerCase();
    for (final topic in _blockedTopics) {
      if (lowerMessage.contains(topic)) {
        return false;
      }
    }
    return true;
  }

  String _getBlockedMessage() {
    return 'Извини, но я не могу обсуждать эту тему. Давай поговорим о чём-нибудь интересном о нейросетях или технологиях?';
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    if (_lastResetDate.day != now.day) {
      _messageCountToday = 0;
      _lastResetDate = now;
    }
  }

  bool get canSendMessage {
    _checkDailyReset();
    final hasAI = SubscriptionService().getSubscriptionInfo()['hasAIAssistant'] as bool? ?? false;
    final effectiveLimit = hasAI ? _unlimitedLimit : _dailyLimit;
    return _messageCountToday < effectiveLimit;
  }

  int get remainingMessages {
    _checkDailyReset();
    final hasAI = SubscriptionService().getSubscriptionInfo()['hasAIAssistant'] as bool? ?? false;
    final effectiveLimit = hasAI ? _unlimitedLimit : _dailyLimit;
    return effectiveLimit - _messageCountToday;
  }

  String getLimitMessage() {
    _checkDailyReset();
    return 'Дневной лимит исчерпан. Чтобы продолжить общение с AI, купи подписку с безлимитными сообщениями!';
  }

  String getRemainingMessage() {
    _checkDailyReset();
    final hasAI = SubscriptionService().getSubscriptionInfo()['hasAIAssistant'] as bool? ?? false;
    if (hasAI) {
      return 'Безлимитные сообщения включены!';
    }
    return 'Осталось: $remainingMessages сообщений на сегодня. Купи подписку для безлимитного общения!';
  }

  String _getNextKey() {
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    return _apiKeys[_currentKeyIndex];
  }

  Future<String> sendMessage(String message, {String? context}) async {
    _checkDailyReset();
    
    if (!canSendMessage) {
      return getLimitMessage();
    }
    
    // Проверка на запрещённые темы
    if (!_isContentAllowed(message)) {
      return _getBlockedMessage();
    }

    try {
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
      ];

      if (context != null) {
        messages.add({'role': 'system', 'content': 'Контекст урока: $context'});
      }

      // Добавляем историю (последние 10 сообщений)
      final historyStart = _chatHistory.length > 10 ? _chatHistory.length - 10 : 0;
      for (int i = historyStart; i < _chatHistory.length; i++) {
        messages.add(_chatHistory[i]);
      }

      messages.add({'role': 'user', 'content': message});

      String lastError = '';
      
      // Пробуем каждый ключ
      for (int attempt = 0; attempt < _apiKeys.length; attempt++) {
        try {
          final apiKey = _apiKeys[_currentKeyIndex];
          
          final response = await http.post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.1-8b-instant',
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 1024,
            }),
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final assistantMessage = data['choices'][0]['message']['content'];

            _chatHistory.add({'role': 'user', 'content': message});
            _chatHistory.add({'role': 'assistant', 'content': assistantMessage});
            
            if (_chatHistory.length > 20) {
              _chatHistory = _chatHistory.sublist(_chatHistory.length - 20);
            }

            _messageCountToday++;
            return assistantMessage;
          } else if (response.statusCode == 429) {
            // Rate limit - пробуем следующий ключ
            _getNextKey();
            lastError = 'Rate limit';
            continue;
          } else {
            lastError = 'Error: ${response.statusCode}';
            break;
          }
        } catch (e) {
          lastError = e.toString();
          _getNextKey();
        }
      }

      return 'Временная ошибка. Попробуй через минуту. ($lastError)';
    } catch (e) {
      debugPrint('Groq Chat error: $e');
      return 'Произошла ошибка. Попробуй позже.';
    }
  }

  Future<String> explainTerm(String term, {String? lessonContext}) async {
    String context = lessonContext ?? '';
    String prompt = 'Объясни термин "$term" простыми словами для ребенка 10 лет';
    if (context.isNotEmpty) {
      prompt += '. Контекст: $context';
    }
    return sendMessage(prompt);
  }

  void clearHistory() {
    _chatHistory = [];
  }

  Map<String, dynamic> getStats() {
    _checkDailyReset();
    return {
      'messageCountToday': _messageCountToday,
      'remainingMessages': remainingMessages,
      'dailyLimit': _dailyLimit,
    };
  }
}

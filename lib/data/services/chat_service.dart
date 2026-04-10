import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  String? _currentUserId;
  List<Map<String, dynamic>> _onlineUsers = [];
  Map<String, List<Map<String, dynamic>>> _conversations = {};
  Map<String, List<Map<String, dynamic>>> _offlineMessages = {};

  // Лимиты сообщений AI чата
  static const int freeDailyLimit = 10; // Бесплатный лимит в день
  static const int premiumDailyLimit = 100; // Премиум лимит (безлимитный по сути)
  
  // История сообщений для AI чата
  List<Map<String, dynamic>> _aiChatHistory = [
    // Демонстрационные данные для родительского кабинета
    {'role': 'user', 'content': 'Что такое нейросеть простыми словами?'},
    {'role': 'assistant', 'content': 'Представь, что это мозг компьютера...'},
    {'role': 'user', 'content': 'А как нейросеть рисует картинки?'},
    {'role': 'assistant', 'content': 'Она учится на миллионах изображений...'},
    {'role': 'user', 'content': 'Может ли ИИ написать музыку?'},
  ];
  bool _isFirebaseConfigured = false;

  // Слова для модерации (заблокированные темы для детей)
  static const List<String> _blockedWords = [
    'оружие', 'убийство', 'наркотики', 'алкоголь', 'сигареты',
    'суицид', 'самоубийство', 'насилие', 'порно', 'секс',
    'обман', 'мошенничество', 'кража', 'взлом', 'террор',
  ];

  // Проверенные темы для детей
  static const List<String> _allowedTopics = [
    'нейросеть', 'искусственный интеллект', 'программирование',
    'музыка', 'рисование', 'математика', 'школа', 'учёба',
    'игры', 'спорт', 'наука', 'технологии', 'робот',
  ];

  // URL Firebase Functions - замените на ваш проект
  static const String _functionsBaseUrl =
      'https://us-central1-YOUR_PROJECT.cloudfunctions.net';

  Future<void> initialize(String userId, String userName) async {
    _currentUserId = userId;

    // Проверяем Firebase
    try {
      final apps = Firebase.apps;
      _isFirebaseConfigured = apps.isNotEmpty;
    } catch (e) {
      _isFirebaseConfigured = false;
    }
  }

  /// Возвращает историю диалога с AI для отображения в родительском кабинете.
  List<Map<String, dynamic>> getAiChatHistory() {
    return _aiChatHistory;
  }

  /// Проверка лимита сообщений на сегодня
  static bool checkMessageLimit({required bool isPremium}) {
    // В реальном приложении - получить из SharedPreferences
    // Здесь заглушка
    return true;
  }

  /// Получить количество оставшихся сообщений на сегодня
  static int getRemainingMessages({required bool isPremium}) {
    final limit = isPremium ? premiumDailyLimit : freeDailyLimit;
    // В реальном приложении - получить из SharedPreferences
    // Здесь возвращаем примерное значение
    return limit - 3; // Демо: 3 уже использовано
  }

  /// Проверка контента на безопасность
  static Map<String, dynamic> checkContentSafety(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Проверка на заблокированные слова
    for (final blockedWord in _blockedWords) {
      if (lowerMessage.contains(blockedWord)) {
        return {
          'isSafe': false,
          'reason': 'Содержимое не подходит для детей',
          'suggestion': 'Давай поговорим на другую тему? Я могу помочь с учёбой, творчеством или интересными фактами о технологиях!',
        };
      }
    }
    
    // Проверка длины сообщения
    if (message.length > 2000) {
      return {
        'isSafe': false,
        'reason': 'Сообщение слишком длинное',
        'suggestion': 'Попробуй разбить сообщение на несколько частей',
      };
    }
    
    return {'isSafe': true};
  }

  /// Проверка, является ли пользователь премиум
  bool isUserPremium() {
    // В реальном приложении - проверка подписки из Firebase/Storage
    return false; // Для демо - бесплатный пользователь
  }

  /// Увеличить счётчик сообщений
  Future<void> incrementMessageCount() async {
    // В реальном приложении - сохранение в SharedPreferences
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int count = prefs.getInt('daily_message_count') ?? 0;
    // await prefs.setInt('daily_message_count', count + 1);
  }

  /// Сбросить счётчик (вызывать в полночь)
  Future<void> resetDailyCount() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('daily_message_count', 0);
  }

  String generateUserId(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return name.toUpperCase().substring(0, 3) +
        timestamp.substring(timestamp.length - 4);
  }

  /// Отправка сообщения AI ассистенту через Firebase Functions
  Future<String> sendAIChatMessage(String message,
      {String? context, String model = 'gpt-3.5-turbo'}) async {
    if (!_isFirebaseConfigured) {
      // Локальная заглушка для MVP
      return _getMockAIResponse(message);
    }

    try {
      // Получаем ID токен пользователя
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      final idToken = await user.getIdToken();

      // Вызываем Firebase Function
      // Для реального проекта используйте firebase_functions package
      final functionsUrl = '$_functionsBaseUrl/aiChat';

      // Создаём тело запроса
      final body = jsonEncode({
        'message': message,
        'model': model,
        'context': context,
        'history': _aiChatHistory.take(10).toList(),
      });

      // Используем HttpClient для запроса
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(functionsUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $idToken');
      request.write(body);

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Ошибка AI: ${response.statusCode}');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);

      // Добавляем в историю
      _aiChatHistory.add({'role': 'user', 'content': message});
      _aiChatHistory.add({'role': 'assistant', 'content': data['response']});

      // Ограничиваем историю 20 сообщениями
      if (_aiChatHistory.length > 20) {
        _aiChatHistory = _aiChatHistory.sublist(_aiChatHistory.length - 20);
      }

      return data['response'] as String;
    } catch (e) {
      debugPrint('AI Chat error: $e');
      return _getMockAIResponse(message);
    }
  }

  /// Объяснение термина через AI
  Future<String> explainTerm(String term, {String? lessonContext}) async {
    if (!_isFirebaseConfigured) {
      return _getMockExplanation(term);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      final idToken = await user.getIdToken();
      final functionsUrl = '$_functionsBaseUrl/aiExplain';

      final body = jsonEncode({
        'term': term,
        'lessonContext': lessonContext,
      });

      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(functionsUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $idToken');
      request.write(body);

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Ошибка AI: ${response.statusCode}');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      return data['explanation'] as String;
    } catch (e) {
      debugPrint('AI Explain error: $e');
      return _getMockExplanation(term);
    }
  }

  /// Проверка и улучшение промпта
  Future<String> reviewPrompt(String prompt) async {
    if (!_isFirebaseConfigured) {
      return _getMockPromptReview(prompt);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      final idToken = await user.getIdToken();
      final functionsUrl = '$_functionsBaseUrl/aiPromptReview';

      final body = jsonEncode({'prompt': prompt});

      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(functionsUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $idToken');
      request.write(body);

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Ошибка AI: ${response.statusCode}');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      return data['review'] as String;
    } catch (e) {
      debugPrint('AI Prompt Review error: $e');
      return _getMockPromptReview(prompt);
    }
  }

  /// Очистка истории чата
  void clearAIChatHistory() {
    _aiChatHistory = [];
  }

  // Mock методы для MVP режима
  String _getMockAIResponse(String message) {
    final lowercaseMessage = message.toLowerCase();

    if (lowercaseMessage.contains('привет') ||
        lowercaseMessage.contains('здравствуй')) {
      return 'Привет! Я твой AI помощник. Чем могу помочь сегодня?';
    } else if (lowercaseMessage.contains('что такое') ||
        lowercaseMessage.contains('объясни')) {
      return 'Отличный вопрос! Давай разберёмся вместе. Расскажи подробнее, что именно тебе непонятно?';
    } else if (lowercaseMessage.contains('помоги') ||
        lowercaseMessage.contains('помощь')) {
      return 'Конечно помогу! Я могу:\n- Объяснить непонятные термины\n- Помочь с написанием промпта\n- Ответить на вопросы об AI\n\nЧто тебе нужно?';
    } else {
      return 'Интересный вопрос! Расскажи подробнее, и я постараюсь помочь. Если что-то непонятно из урока — укажи, что именно, и я объясню простыми словами.';
    }
  }

  String _getMockExplanation(String term) {
    return 'Термин "$term" — это понятие из мира технологий и AI. Давай объясню простыми словами: это как если бы ты объяснял что-то младшему брату — понятно и с примерами из жизни!';
  }

  String _getMockPromptReview(String prompt) {
    return 'Оценка твоего промпта: 4/5\n\nХорошо: Ты указал конкретную тему.\n\nСовет: Добавь больше деталей о том, какой результат хочешь получить.\n\nУлучшенный промпт: "Напиши историю про робота, который хочет стать музыкантом. История должна быть смешной и для детей 10 лет."';
  }

  Future<List<Map<String, dynamic>>> searchUsers({
    String? query,
    int? age,
    String? userId,
  }) async {
    final mockUsers = [
      {
        'id': 'NER001',
        'name': 'Алиса',
        'age': 12,
        'avatar': 'robot_1',
        'season': 3,
        'online': true,
      },
      {
        'id': 'NER002',
        'name': 'Миша',
        'age': 11,
        'avatar': 'rocket',
        'season': 2,
        'online': false,
      },
      {
        'id': 'NER003',
        'name': 'Данил',
        'age': 13,
        'avatar': 'brain',
        'season': 4,
        'online': true,
      },
      {
        'id': 'NER004',
        'name': 'Маша',
        'age': 12,
        'avatar': 'star',
        'season': 3,
        'online': false,
      },
    ];

    if (query != null && query.isNotEmpty) {
      return mockUsers
          .where((u) =>
              u['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (age != null) {
      return mockUsers.where((u) => u['age'] == age).toList();
    }

    if (userId != null && userId.isNotEmpty) {
      return mockUsers.where((u) => u['id'] == userId).toList();
    }

    return mockUsers;
  }

  Future<void> sendMessage(String receiverId, String message) async {
    if (_currentUserId == null) return;

    final msg = {
      'from': _currentUserId,
      'to': receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    _conversations[receiverId] ??= [];
    _conversations[receiverId]!.add(msg);

    _offlineMessages[receiverId] ??= [];
    _offlineMessages[receiverId]!.add(msg);
  }

  List<Map<String, dynamic>> getConversation(String userId) {
    return _conversations[userId] ?? [];
  }

  List<Map<String, dynamic>> getRecentChats() {
    final chats = <Map<String, dynamic>>[];
    for (final entry in _conversations.entries) {
      if (entry.value.isNotEmpty) {
        final lastMsg = entry.value.last;
        chats.add({
          'userId': entry.key,
          'lastMessage': lastMsg['message'],
          'timestamp': lastMsg['timestamp'],
        });
      }
    }
    return chats;
  }

  int getUnreadCount(String userId) {
    final messages = _offlineMessages[userId];
    if (messages == null) return 0;
    return messages.where((m) => m['read'] == false).length;
  }

  void markAsRead(String userId) {
    final messages = _offlineMessages[userId];
    if (messages != null) {
      for (var i = 0; i < messages.length; i++) {
        messages[i]['read'] = true;
      }
    }
  }

  Map<String, dynamic> getProfile(String userId) {
    return {
      'id': userId,
      'name': 'Пользователь',
      'age': 12,
      'avatar': 'robot_1',
      'season': 1,
      'xp': 500,
      'level': 5,
    };
  }
}

import 'package:flutter/material.dart';
import '../data/services/groq_chat_service.dart';

class AIAssistantWidget extends StatefulWidget {
  final String? childName;
  final String? assistantName;
  final VoidCallback? onMinimize;
  final VoidCallback? onSubscribe;

  const AIAssistantWidget({
    super.key,
    this.childName,
    this.assistantName,
    this.onMinimize,
    this.onSubscribe,
  });

  @override
  State<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends State<AIAssistantWidget> {
  bool _isExpanded = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final GroqChatService _groqService = GroqChatService();

  final List<String> _defaultNames = [
    'Ассистент',
    'Помощник',
    'Проводник',
    'Друг',
  ];

  final List<String> _greetings = [
    'Привет! Я здесь, чтобы помочь тебе с прохождением уроков!',
    'Приветик! Готов начать исследование мира ИИ?',
    'Привет! Я буду твоим проводником в мир нейросетей!',
  ];

  final List<String> _hints = [
    'Подсказка: Попробуй начать с простого промпта, например "объясни как ребёнку"',
    'Не забывай, что чем точнее запрос - тем лучше ответ!',
    'Помни: ИИ учится на примерах, покажи ему больше контекста!',
    'Если что-то непонятно - просто спроси меня!',
  ];

  final List<String> _encouragement = [
    'Отлично! Продолжай в том же духе!',
    'Ты молодец! ИИ - это действительно интересно!',
    'Здорово! Давай узнаем ещё больше!',
    'Потрясающе! Ты настоящий исследователь!',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text': _greetings[DateTime.now().second % _greetings.length],
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (!_groqService.canSendMessage) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': _groqService.getLimitMessage(),
        });
      });
      return;
    }

    final userText = _controller.text.trim();
    
    setState(() {
      _messages.add({
        'role': 'user',
        'text': userText,
      });
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await _groqService.sendMessage(userText);
      
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': response,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Произошла ошибка. Попробуй ещё раз.',
        });
        _isLoading = false;
      });
    }
  }

  String _generateResponse(String userText) {
    if (userText.contains('подсказк') || userText.contains('помоги')) {
      return _hints[DateTime.now().second % _hints.length];
    } else if (userText.contains('что такое') ||
        userText.contains('как работа')) {
      return 'Отличный вопрос! Нейросети учатся на примерах, как ты учишься в школе. Чем больше примеров видят, тем лучше учатся!';
    } else if (userText.contains('затрудняюсь') ||
        userText.contains('не знаю') ||
        userText.contains('сложно')) {
      return 'Не переживай! Давай разберём пошагово. Расскажи, что именно вызывает трудности?';
    } else if (userText.contains('привет') || userText.contains('здравствуй')) {
      return 'Привет! Рад видеть тебя! Г��тов продолжить исследование?';
    } else if (userText.contains('спасибо') || userText.contains('понял')) {
      return 'Пожалуйста! Ты отлично справляешься! Продолжай учиться!';
    }

    return _encouragement[DateTime.now().second % _encouragement.length];
  }

  @override
  Widget build(BuildContext context) {
    final assistantName = widget.assistantName ?? 'Ассистент';
    final avatarColors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange
    ];
    final avatarColor =
        avatarColors[(assistantName.length) % avatarColors.length];

    if (_isExpanded) {
      return Container(
        width: 320,
        height: 400,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: avatarColor,
                    radius: 20,
                    child: Text(
                      assistantName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assistantName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Твой помощник',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.minimize),
                    onPressed: () => setState(() => _isExpanded = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? avatarColor.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6),
                      child: Text(msg['text']!),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _groqService.canSendMessage 
                      ? 'Осталось: ${_groqService.remainingMessages}/день'
                      : 'Лимит исчерпан!',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onSubscribe?.call();
                    },
                    child: Text(
                      _groqService.canSendMessage ? 'Купить подписку' : 'Купить',
                      style: TextStyle(fontSize: 10, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Спроси меня...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: avatarColor),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: avatarColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: avatarColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.psychology, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  assistantName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Нажми для помощи',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class AIAssistantDialog extends StatefulWidget {
  const AIAssistantDialog({super.key});

  @override
  State<AIAssistantDialog> createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends State<AIAssistantDialog> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant', 
            'content': _getAIResponse(text)
          });
        });
      }
    });
    _controller.clear();
  }

  String _getAIResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('подсказ') || lower.contains('помощ')) {
      return 'Конечно! Вот подсказка: Начни с первого урока и внимательно читай теорию. После каждого урока выполняй задания - так знания лучше запомнятся! 🎓';
    }
    if (lower.contains('что такое') || lower.contains('нейро')) {
      return 'Нейросеть - это программа, которая учится как человек! она смотрит на много примеров и сама находит правила. как ребёнок учится говорить - так и компьютер учится думать! 🧠';
    }
    if (lower.contains('как') || lower.contains('работа')) {
      return 'Нейросеть работает так: получает данные → обрабатывает → выдаёт результат! Чем больше примеров - тем умнее она становится! 📊';
    }
    return 'Отличный вопрос! Продолжай учиться - каждый урок приближает тебя к пониманию ИИ! Ты молодец! 🌟';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.deepPurple, size: 24),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '🤖 ИИ-Помощник',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            // Messages
            Flexible(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👋 Привет!', style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 8),
                          const Text('Спроси меня о нейросетях!', textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(label: const Text('Подскажи'), onPressed: () => _sendMessage('дай подсказку')),
                              ActionChip(label: const Text('Что такое ИИ?'), onPressed: () => _sendMessage('что такое нейросеть')),
                              ActionChip(label: const Text('Как учить?'), onPressed: () => _sendMessage('как учить нейросеть')),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.deepPurple : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['content']!,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            // Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Спроси меня...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

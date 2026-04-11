import 'package:flutter/material.dart';
import '../data/services/groq_chat_service.dart';

class AIChatFullScreen extends StatefulWidget {
  final String userName;

  const AIChatFullScreen({super.key, required this.userName});

  @override
  State<AIChatFullScreen> createState() => _AIChatFullScreenState;
}

class _AIChatFullScreenState extends State<AIChatFullScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final GroqChatService _groqService = GroqChatService();

  final List<String> _greetings = [
    'Привет! Я здесь, чтобы помочь тебе с прохождением уроков!',
    'Приветик! Готов начать исследование мира ИИ?',
    'Привет! Я буду твоим проводником в мир нейросетей!',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text': _greetings[DateTime.now().second % _greetings.length],
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
      _scrollToBottom();
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
    _scrollToBottom();
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
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Произошла ошибка. Попробуй ещё раз.',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Быстрые вопросы:', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Что такое нейросеть?'),
                  onPressed: () {
                    Navigator.pop(context);
                    _controller.text = 'Что такое нейросеть?';
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text('Как это работает?'),
                  onPressed: () {
                    Navigator.pop(context);
                    _controller.text = 'Как работают нейросети?';
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.quiz_outlined, size: 18),
                  label: const Text('Давай тест'),
                  onPressed: () {
                    Navigator.pop(context);
                    _controller.text = 'Дай мне тест по уроку';
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.explore, size: 18),
                  label: const Text('Интересные факты'),
                  onPressed: () {
                    Navigator.pop(context);
                    _controller.text = 'Расскажи интересный факт';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.cyan.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessages()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.cyan.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🤖 AI Помощник',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _groqService.canSendMessage 
                      ? 'Осталось: ${_groqService.remainingMessages}/50 сообщений'
                      : 'Лимит исчерпан',
                  style: TextStyle(
                    fontSize: 12,
                    color: _groqService.canSendMessage 
                        ? Colors.grey.shade600
                        : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showQuickActions,
            tooltip: 'Быстрые вопросы',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildTypingIndicator();
        }
        
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return _buildMessageBubble(msg['text']!, isUser);
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? Colors.blue.shade500 
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy, size: 16, color: Colors.cyan.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'AI Помощник',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.cyan.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, size: 16, color: Colors.cyan.shade700),
            const SizedBox(width: 8),
            Text('Печатает', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(width: 4),
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 200),
      builder: (context, value, child) {
        return Opacity(
          opacity: value > 0 ? (value < 0.5 ? value * 2 : 2 - value * 2) : 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.cyan.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildInputArea() {
    final canSend = _groqService.canSendMessage;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                enabled: canSend,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: canSend 
                      ? 'Напиши вопрос...'
                      : 'Лимит сообщений исчерпан',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: canSend ? Colors.blue.shade500 : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                canSend ? Icons.send : Icons.block,
                color: Colors.white,
              ),
              onPressed: canSend ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
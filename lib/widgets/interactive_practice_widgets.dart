import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InteractivePracticeButton extends StatelessWidget {
  final String label;
  final String url;
  final IconData icon;
  final Color? color;
  final bool isExternal;

  const InteractivePracticeButton({
    super.key,
    required this.label,
    required this.url,
    this.icon = Icons.open_in_new,
    this.color,
    this.isExternal = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  buttonColor.withOpacity(0.1),
                  buttonColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: buttonColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: buttonColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        isExternal
                            ? 'Откроется в новой вкладке'
                            : 'Интерактивное задание',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: buttonColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось открыть ссылку')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}

class InlinePromptDemo extends StatefulWidget {
  final String title;
  final String placeholder;
  final String? prefilledPrompt;
  final VoidCallback? onDemoComplete;

  const InlinePromptDemo({
    super.key,
    required this.title,
    required this.placeholder,
    this.prefilledPrompt,
    this.onDemoComplete,
  });

  @override
  State<InlinePromptDemo> createState() => _InlinePromptDemoState();
}

class _InlinePromptDemoState extends State<InlinePromptDemo> {
  late TextEditingController _controller;
  bool _isSubmitted = false;
  String? _response;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.prefilledPrompt);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitted ? null : _simulateResponse,
              icon: const Icon(Icons.send, size: 18),
              label: Text(_isSubmitted ? 'Отправлено' : 'Попробовать'),
            ),
          ),
          if (_isSubmitted && _response != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Ответ ИИ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_response!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _simulateResponse() {
    setState(() {
      _isSubmitted = true;
      _response = _generateDemoResponse(_controller.text);
    });
    widget.onDemoComplete?.call();
  }

  String _generateDemoResponse(String prompt) {
    if (prompt.toLowerCase().contains('привет') ||
        prompt.toLowerCase().contains('hello')) {
      return 'Привет! Я — демонстрация ответа нейросети. В реальном приложении здесь будет настоящий ответ от ИИ!';
    } else if (prompt.toLowerCase().contains('кто ты') ||
        prompt.toLowerCase().contains('что ты')) {
      return 'Я — демонстрация работы нейросети. Настоящий ИИ ответил бы на твой вопрос более подробно.';
    } else if (prompt.toLowerCase().contains('помоги') ||
        prompt.toLowerCase().contains('help')) {
      return 'Конечно! Я здесь, чтобы помогать. В реальном режиме я бы дал тебе полезный ответ на твой запрос.';
    }
    return 'Это демонстрация ответа. В реальном приложении здесь будет ответ от настоящей нейросети на твой запрос: "${prompt.substring(0, prompt.length > 20 ? 20 : prompt.length)}..."';
  }
}

class QuickTryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String url;

  const QuickTryCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _launchUrl(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class AIFeaturesShowcase extends StatelessWidget {
  const AIFeaturesShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                'Попробуй сам!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Нажми на любой сервис ниже, чтобы попробовать технологии в действии:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          QuickTryCard(
            title: 'ChatGPT',
            description: 'Поговори с ИИ-помощником',
            icon: Icons.chat,
            color: Colors.green,
            url: 'https://chat.openai.com',
          ),
          const SizedBox(height: 8),
          QuickTryCard(
            title: 'Midjourney',
            description: 'Создай картинки из текста',
            icon: Icons.image,
            color: Colors.blue,
            url: 'https://www.midjourney.com',
          ),
          const SizedBox(height: 8),
          QuickTryCard(
            title: 'Teachable Machine',
            description: 'Обучи ИИ распознавать образы',
            icon: Icons.school,
            color: Colors.orange,
            url: 'https://teachablemachine.withgoogle.com/train/image',
          ),
        ],
      ),
    );
  }
}

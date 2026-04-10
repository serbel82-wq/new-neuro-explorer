import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  final String userName;

  const OnboardingScreen({
    super.key,
    required this.userName,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _agreedToTerms = false;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      icon: Icons.rocket_launch,
      title: 'Добро пожаловать в НейроИсследователь!',
      description: 'Ты отправишься в увлекательное путешествие по миру нейросетей. Узнай, как работает искусственный интеллект и научись использовать его с пользой!',
      color: Colors.deepPurple,
      subtitle: 'Приключение начинается',
    ),
    const OnboardingPage(
      icon: Icons.security,
      title: 'Правила безопасности',
      description: 'Важно помнить несколько простых правил, чтобы оставаться в безопасности. Ознакомьтесь с полными правилами безопасности перед началом обучения.',
      color: Colors.orange,
      subtitle: 'Безопасность прежде всего',
      bulletPoints: [
        'Никогда не делись своими паролями',
        'Не пиши личные данные (адрес, телефон)',
        'Не отправляй свои фотографии незнакомцам',
        'Если что-то смутит — расскажи родителям',
      ],
      hasLink: true,
    ),
    const OnboardingPage(
      icon: Icons.lightbulb,
      title: 'Как учиться',
      description: 'Следуй этим советам, чтобы получить максимум от обучения',
      color: Colors.green,
      subtitle: 'Эффективное обучение',
      bulletPoints: [
        'Читай теорию внимательно',
        'Выполняй все задания',
        'Не бойся экспериментировать',
        'Задавай вопросы ИИ — он поможет!',
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, согласись с правилами'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.levels,
      arguments: widget.userName,
    );
  }

  Future<void> _openSafetyRules() async {
    final url = Uri.parse('https://serbel82-wq.github.io/new-neuro-explorer/docs/Правила_безопасности_для_родителей.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
              _pages[_currentPage].color.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _buildPage(_pages[index]),
                ),
              ),
              _buildPageIndicator(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_currentPage == _pages.length - 1) ...[
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                          ),
                          Expanded(
                            child: Text(
                              'Я согласен с правилами безопасности',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nextPage,
                        icon: Icon(_currentPage < _pages.length - 1 ? Icons.arrow_forward : Icons.rocket_launch),
                        label: Text(
                          _currentPage < _pages.length - 1
                              ? 'Далее'
                              : 'Начать обучение!',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.2),
                  page.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: page.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  page.icon,
                  size: 64,
                  color: page.color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              page.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: page.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (page.bulletPoints != null) ...[
            const SizedBox(height: 24),
            ...page.bulletPoints!.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: page.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (page.hasLink) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _openSafetyRules(),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Открыть полные правила безопасности'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _pages[index].color
                : _pages[index].color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final String subtitle;
  final Color color;
  final List<String>? bulletPoints;
  final bool hasLink;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.subtitle,
    required this.color,
    this.bulletPoints,
    this.hasLink = false,
  });
}
import 'package:flutter/material.dart';

import '../data/models/lesson.dart';
import '../data/models/task.dart';
import '../data/services/storage_service.dart';
import '../data/services/lesson_data_provider.dart';
import '../data/services/gamification_service.dart';
import '../widgets/task_widget.dart';
import '../widgets/gamification_widgets.dart';
import '../app_routes.dart';

class LessonScreen extends StatefulWidget {
  final int lessonId;
  final String userName;
  final VoidCallback? onComplete;

  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.userName,
    this.onComplete,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Lesson? _lesson;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  bool _isCompleting = false;
  final Set<String> _completedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _lesson = LessonDataProvider.getLessonById(widget.lessonId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // --- Новая логика геймификации ---

  void _handleTaskAnswered(Task task) {
    // Используем ID задачи или ее заголовок как уникальный идентификатор
    final taskId = task.id.isNotEmpty ? task.id : task.title;
    if (_completedTaskIds.contains(taskId)) {
      return; // Награда за это задание уже выдана
    }

    setState(() {
      _completedTaskIds.add(taskId);
    });

    final xp = task.totalPoints;
    // TODO: Добавить в GamificationService метод для сохранения XP за задание, например:
    // GamificationService.addTaskXp(xp);
    
    _showXpToast(xp);
  }

  void _showXpToast(int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            XpBadge(xp: xp, showPlus: true),
            const SizedBox(width: 8),
            const Text('Отлично!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.fromLTRB(15, 5, 15, 30),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // --- Конец новой логики ---

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeLesson() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    await StorageService.addCompletedLesson(widget.lessonId);

    // Gamification - add XP for lesson completion
    final xpEarned = await GamificationService.addLessonComplete();

    // Check for achievements
    if (widget.lessonId == 1) {
      await GamificationService.unlockAchievement('first_step');
    }

    if (mounted) {
      widget.onComplete?.call();
      _showCompletionDialog(xpEarned);
    }
  }

  void _showCompletionDialog(int xpEarned) {
    final nextLesson = LessonDataProvider.getNextLesson(widget.lessonId);
    final stats = GamificationService.getGamificationStats();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text('Урок пройден!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpEarned XP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  GamificationService.getLevelEmoji(stats['level'] as int),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  'Уровень ${stats['level']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if ((stats['currentStreak'] as int) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text('Серия: ${stats['currentStreak']} дней'),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Отлично, ${widget.userName}! Ты молодец!'),
            const SizedBox(height: 16),
            if (nextLesson != null)
              Text('Следующий урок: "${nextLesson.title}"')
            else
              const Text('Ты завершил первый сезон!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (nextLesson != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(
                      lessonId: nextLesson.id,
                      userName: widget.userName,
                      onComplete: widget.onComplete,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
                nextLesson != null ? 'К следующему уроку' : 'Назад к урокам'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Урок')),
        body: const Center(child: Text('Урок не найден')),
      );
    }

    final pages = [
      _buildTheoryPage(),
      _buildTasksPage(),
      _buildCompletionPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Урок ${_lesson!.order}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: pages.length,
              itemBuilder: (context, index) => pages[index],
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildTheoryPage() {
    final lessonColors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lessonColor.withOpacity(0.2),
                  lessonColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lessonColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getLessonIcon(_lesson!.id),
                        color: lessonColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Урок ${_lesson!.order}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: lessonColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(
                            _lesson!.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _lesson!.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.menu_book, color: lessonColor),
              const SizedBox(width: 8),
              Text(
                'Теория',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _lesson!.theoryText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${_lesson!.durationMinutes} минут',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLessonIcon(int id) {
    if (id > 100) {
      final season2Icons = [
        Icons.music_note,
        Icons.record_voice_over,
        Icons.video_library,
        Icons.podcasts,
        Icons.animation,
        Icons.movie,
      ];
      return season2Icons[(id - 101) % season2Icons.length];
    }
    final icons = [
      Icons.school,
      Icons.psychology,
      Icons.edit_note,
      Icons.image,
      Icons.fact_check,
      Icons.security,
      Icons.menu_book,
      Icons.smart_toy,
    ];
    return icons[(id - 1) % icons.length];
  }

  Widget _buildTasksPage() {
    final lessonColors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    List<Widget> taskWidgetList = [];

    if (_lesson!.tasks.isNotEmpty) {
      taskWidgetList = _lesson!.tasks
          .map((task) => TaskWidget(
                task: task,
                onAnswered: (answers) {
                  _handleTaskAnswered(task);
                },
              ))
          .toList();
    } else if (_lesson!.taskStrings != null &&
        _lesson!.taskStrings!.isNotEmpty) {
      for (int i = 0; i < _lesson!.taskStrings!.length; i++) {
        // Создаем временную задачу для передачи в обработчик
        final legacyTask = Task(
          id: 'legacy_${_lesson!.id}_$i', 
          title: _lesson!.taskStrings![i], 
          totalPoints: 10, // Назначаем стандартные очки для старых задач
          type: TaskType.text, 
          description: '', 
          instruction: '',
        );
        taskWidgetList.add(TaskWidget.fromLegacy(
          title: _lesson!.taskStrings![i],
          instruction: i < (_lesson!.taskInstructions?.length ?? 0)
              ? _lesson!.taskInstructions![i]
              : '',
          onAnswered: (answers) {
            _handleTaskAnswered(legacyTask);
          },
        ));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: lessonColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: lessonColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.assignment, color: lessonColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Задания',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Выполни задания, чтобы закрепить материал',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...taskWidgetList,
          const SizedBox(height: 16),
          Card(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Совет: Не бойся экспериментировать! ИИ — это инструмент для тренировки твоих навыков.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPage() {
    final lessonColors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lessonColor.withOpacity(0.2),
                  Colors.green.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Готов к завершению?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ты изучил теорию и выполнил задания. Теперь можешь отметить этот урок как пройденный!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: lessonColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.school, color: lessonColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _lesson!.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_lesson!.durationMinutes} минут',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(Icons.format_list_bulleted,
                          color: Colors.purple, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_lesson!.tasks.length} заданий',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isCompleting ? null : _completeLesson,
              icon: _isCompleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.emoji_events),
              label: Text(_isCompleting
                  ? 'Сохранение...'
                  : 'Отметить урок как пройденный'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Сохранить и выйти'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              TextButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Назад'),
              )
            else
              const SizedBox(width: 100),
            const Spacer(),
            if (_currentPage < 2)
              FilledButton.icon(
                onPressed: _nextPage,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentPage == 1 ? 'Далее' : 'К заданиям'),
              )
            else
              const SizedBox(width: 100),
          ],
        ),
      ),
    );
  }
}

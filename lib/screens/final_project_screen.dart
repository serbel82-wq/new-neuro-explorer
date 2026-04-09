import 'package:flutter/material.dart';

import '../data/services/storage_service.dart';

class FinalProjectScreen extends StatefulWidget {
  final int seasonId;
  final String userName;
  final VoidCallback? onComplete;

  const FinalProjectScreen({
    super.key,
    required this.seasonId,
    required this.userName,
    this.onComplete,
  });

  @override
  State<FinalProjectScreen> createState() => _FinalProjectScreenState();
}

class _FinalProjectScreenState extends State<FinalProjectScreen> {
  int? _selectedTrack;
  bool _isSubmitting = false;

  final List<ProjectTrack> _tracks = [
    ProjectTrack(
      id: 'A',
      title: 'Исследователь',
      subtitle: 'Мини-презентация',
      description: 'Создай 5 слайдов с идеями о том, как ИИ меняет одну сферу жизни (школа, спорт, творчество, путешествия или другое)',
      icon: Icons.analytics,
      color: Colors.blue,
      requirements: [
        'Выбери тему',
        'Найди 3 примера использования ИИ',
        'Добавь свои мысли',
        'Сделай вывод',
      ],
    ),
    ProjectTrack(
      id: 'B',
      title: 'Творец',
      subtitle: 'История с иллюстрациями',
      description: 'Создай набор из 3 картинок и напиши короткую историю (200 слов) объединяющую их',
      icon: Icons.palette,
      color: Colors.purple,
      requirements: [
        'Придумай историю',
        'Создай 3 иллюстрации',
        'Напиши текст',
        'Объедини в историю',
      ],
    ),
    ProjectTrack(
      id: 'C',
      title: 'Организатор',
      subtitle: 'План недели',
      description: 'Создай план своей недели с напоминаниями, используя помощь ИИ',
      icon: Icons.calendar_month,
      color: Colors.green,
      requirements: [
        'Определи цели на неделю',
        'Добавь задачи',
        'Распредели по дням',
        'Добавь напоминания',
      ],
    ),
  ];

  ProjectTrack get _currentSeasonProject {
    return _tracks[0];
  }

  @override
  Widget build(BuildContext context) {
    final project = _currentSeasonProject;
    final seasonTitle = widget.seasonId == 1 
        ? 'Сезон 1: Первый контакт' 
        : 'Сезон 2: Мир звука и видео';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              project.color.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: project.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: project.color,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Финальный проект',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: project.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    seasonTitle,
                    style: TextStyle(
                      color: project.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Поздравляем! Ты прошёл все уроки сезона. Теперь создай свой проект, чтобы закрепить знания!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Выбери трек проекта',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_tracks.length, (index) {
                  final track = _tracks[index];
                  final isSelected = _selectedTrack == index;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTrack = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? track.color.withOpacity(0.15)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? track.color : Colors.grey.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: track.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                track.id,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: track.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  track.subtitle,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: track.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: track.color),
                        ],
                      ),
                    ),
                  );
                }),
                if (_selectedTrack != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_tracks[_selectedTrack!].icon, 
                                   color: _tracks[_selectedTrack!].color),
                              const SizedBox(width: 8),
                              Text(
                                'Описание',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tracks[_selectedTrack!].description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Что нужно сделать:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._tracks[_selectedTrack!].requirements.map((req) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check, 
                                     size: 18, 
                                     color: _tracks[_selectedTrack!].color),
                                const SizedBox(width: 8),
                                Expanded(child: Text(req)),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submitProject,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isSubmitting ? 'Сохранение...' : 'Завершить проект'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _tracks[_selectedTrack!].color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitProject() async {
    setState(() => _isSubmitting = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    final projectKey = 'season${widget.seasonId}_project';
    await StorageService.addCompletedLesson(widget.seasonId * 100);
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              const Text('Проект готов!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Поздравляем, ${widget.userName}! 🎉'),
              const SizedBox(height: 12),
              const Text('Ты завершил финальный проект сезона. Теперь ты настоящий НейроИсследователь!'),
              const SizedBox(height: 12),
              const Text('Можешь вернуться к списку уроков или продолжить изучение новых тем.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('К урокам'),
            ),
          ],
        ),
      );
    }
    
    setState(() => _isSubmitting = false);
  }
}

class ProjectTrack {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> requirements;

  ProjectTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.requirements,
  });
}
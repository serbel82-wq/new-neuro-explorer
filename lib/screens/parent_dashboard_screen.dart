import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_screen.dart';
import '../data/services/chat_service.dart';
import '../data/services/gamification_service.dart';
import '../data/services/lesson_data_provider.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  static SharedPreferences? _prefs;
  static SharedPreferences get prefs => _prefs!;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _getTimeLimitText() {
    if (_prefs == null) return 'Не установлено';
    final minutes = _prefs!.getInt(_timeLimitKey) ?? 0;
    if (minutes == 0) return 'Без ограничений';
    if (minutes < 60) return '$minutes минут';
    return '${minutes ~/ 60} час${minutes >= 120 ? 'а' : ''}';
  }

  Widget build(BuildContext context) {
    final profile = GamificationService.getProfile();
    final stats = GamificationService.getGamificationStats();
    final completedLessons = profile.totalLessonsCompleted;
    final seasons = LessonDataProvider.getSeasons();
    final unlockedAchievements = GamificationService.getUnlockedAchievements();
    final aiChatHistory = ChatService().getAiChatHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Родительский кабинет'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Прогресс ребёнка'),
              const SizedBox(height: 12),
              _buildProgressCard(context, stats, completedLessons),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Звёзды'),
              const SizedBox(height: 12),
              _buildStarsCard(context, stats, seasons),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Любознательность ребёнка'),
              const SizedBox(height: 12),
              _buildAiTopicsCard(context, aiChatHistory),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Достижения'),
              const SizedBox(height: 12),
              _buildAchievementsCard(context, unlockedAchievements, stats),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Сезоны'),
              const SizedBox(height: 12),
              _buildSeasonsCard(context, seasons),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Подписка'),
              const SizedBox(height: 12),
              _buildSubscriptionCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Настройки'),
              const SizedBox(height: 12),
              _buildSettingsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, Map<String, dynamic> stats, int completedLessons) {
    final level = stats['level'] as int;
    final totalXp = stats['totalXpEarned'] as int;
    final streak = stats['currentStreak'] as int;
    final tasksCompleted = stats['tasksCompleted'] as int;
    final levelTitle = GamificationService.getLevelTitle(level);
    final levelEmoji = GamificationService.getLevelEmoji(level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child:
                        Text(levelEmoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Уровень $level',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        levelTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    context, Icons.school, '$completedLessons', 'Уроков'),
                _buildStatItem(
                    context, Icons.assignment, '$tasksCompleted', 'Заданий'),
                _buildStatItem(context, Icons.star, '$totalXp', 'Всего XP'),
                if (streak > 0)
                  _buildStatItem(context, Icons.local_fire_department,
                      '$streak', 'Серия дней'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTopicsCard(
      BuildContext context, List<Map<String, dynamic>> history) {
    final userQuestions =
        history.where((msg) => msg['role'] == 'user').toList().reversed.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.purple, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Темы, которые интересовали ребёнка',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (userQuestions.isEmpty)
              const Center(child: Text('Ребенок еще не общался с AI-помощником.'))
            else
              ...userQuestions.take(3).map((question) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.question_answer_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"${question['content']}"',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStarsCard(
      BuildContext context, Map<String, dynamic> stats, List seasons) {
    final totalStars = stats['totalStars'] as int? ?? 0;
    final seasonStars = stats['seasonStars'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stars, color: Colors.amber, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalStars звёзд собрано',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'За прохождение уроков',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Звёзды по сезонам',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: seasons.take(8).map((season) {
                final stars = seasonStars[season.id.toString()] as int? ?? 0;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'S${season.id}: $stars',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context,
      List<Achievement> unlocked, Map<String, dynamic> stats) {
    final total = stats['totalAchievements'] as int;
    final unlockedCount = unlocked.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events,
                      color: Colors.amber, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unlockedCount из $total достижений',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: unlockedCount / total,
                          minHeight: 8,
                          backgroundColor: Colors.amber.withOpacity(0.2),
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (unlocked.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unlocked
                    .take(6)
                    .map((a) => Chip(
                          avatar: Icon(_getAchievementIcon(a.iconName),
                              size: 16, color: Colors.amber),
                          label: Text(a.title,
                              style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.amber.withOpacity(0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonsCard(BuildContext context, List seasons) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: seasons
              .take(4)
              .map((season) => ListTile(
                    leading: Icon(
                      _getSeasonIcon(season.iconName),
                      color: season.isUnlocked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: Text(season.title),
                    subtitle: Text('${season.lessonsCount} уроков'),
                    trailing: season.isUnlocked
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.lock_outline, color: Colors.grey),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.card_membership,
                      color: Colors.green, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Премиум',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Активна до 15 мая 2026',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  );
                },
                child: const Text('Управление подпиской'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Правила безопасности'),
            subtitle: const Text('Просмотреть для родителей'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openSafetyRules(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Ограничение времени'),
            subtitle: Text(_getTimeLimitText()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimeLimitDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Уведомления'),
            subtitle: const Text('Включены'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNotificationsDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email-отчёты'),
            subtitle: const Text('Раз в неделю'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEmailReportsDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Поддержка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSupportDialog(context),
          ),
        ],
      ),
    );
  }

  static const String _timeLimitKey = 'parent_time_limit_minutes';
  static const String _notificationsEnabledKey = 'parent_notifications';
  static const String _emailReportsKey = 'parent_email_reports';

  Future<void> _saveTimeLimit(int minutes) async {
    await init();
    await _prefs!.setInt(_timeLimitKey, minutes);
  }

  void _showTimeLimitDialog(BuildContext context) {
    if (_prefs == null) {
      init().then((_) => _showTimeLimitDialog(context));
      return;
    }
    final currentLimit = _prefs!.getInt(_timeLimitKey) ?? 0;
    
    final options = [
      {'label': 'Без ограничений', 'minutes': 0},
      {'label': '15 минут', 'minutes': 15},
      {'label': '30 минут', 'minutes': 30},
      {'label': '1 час', 'minutes': 60},
      {'label': '2 часа', 'minutes': 120},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ограничение времени'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Текущее: ${_getTimeLimitText()}'),
              const SizedBox(height: 16),
              const Text('Установите дневной лимит времени для ребёнка:'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((opt) {
                  final isSelected = (opt['minutes'] as int) == currentLimit;
                  return ChoiceChip(
                    label: Text(opt['label'] as String),
                    selected: isSelected,
                    onSelected: (selected) async {
                      await _saveTimeLimit(opt['minutes'] as int);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Установлено: ${opt['label']}')),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Уведомления'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Уведомления о прогрессе'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Напоминания об уроках'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Новости и обновления'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showEmailReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email-отчёты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите частоту отчётов:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                'Ежедневно', 'Раз в неделю', 'Раз в месяц', 'Выкл'
              ].map((option) => ChoiceChip(
                label: Text(option),
                selected: option == 'Раз в неделю',
                onSelected: (selected) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Установлено: $option')),
                  );
                },
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поддержка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('support@neuroexplorer.ru'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.telegram),
              title: const Text('Telegram'),
              subtitle: const Text('@neuroexplorer'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Телефон'),
              subtitle: const Text('+7 (999) 123-45-67'),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSafetyRules(BuildContext context) async {
    final url = Uri.parse('https://serbel82-wq.github.io/new-neuro-explorer/docs/Правила_безопасности_для_родителей.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть правила безопасности')),
        );
      }
    }
  }

  IconData _getSeasonIcon(String iconName) {
    switch (iconName) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'music_note':
        return Icons.music_note;
      case 'code':
        return Icons.code;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'search':
        return Icons.search;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'rocket':
        return Icons.rocket;
      case 'build':
        return Icons.build;
      default:
        return Icons.star;
    }
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'psychology':
        return Icons.psychology;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'quiz':
        return Icons.quiz;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'music_note':
        return Icons.music_note;
      case 'explore':
        return Icons.explore;
      case 'school':
        return Icons.school;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }
}

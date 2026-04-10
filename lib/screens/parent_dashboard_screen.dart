import 'package:flutter/material.dart';
import 'subscription_screen.dart';
import '../data/services/chat_service.dart';
import '../data/services/gamification_service.dart';
import '../data/services/lesson_data_provider.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
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
            leading: const Icon(Icons.timer),
            title: const Text('Ограничение времени'),
            subtitle: const Text('Не установлено'),
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

  void _showTimeLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ограничение времени'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Установите дневной лимит времени для ребёнка:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                'Без ограничений', '15 минут', '30 минут', '1 час', '2 часа'
              ].map((option) => ChoiceChip(
                label: Text(option),
                selected: false,
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

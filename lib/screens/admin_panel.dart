import 'package:flutter/material.dart';
import '../data/services/lesson_data_provider.dart';
import '../data/models/lesson.dart';
import '../data/models/season.dart';
import '../widgets/premium_animations.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель управления'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Сезоны'),
            Tab(icon: Icon(Icons.article), text: 'Уроки'),
            Tab(icon: Icon(Icons.settings), text: 'Настройки'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SeasonsTab(),
          _LessonsTab(),
          _SettingsTab(),
        ],
      ),
    );
  }
}

class _SeasonsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seasons = LessonDataProvider.getSeasons();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final season = seasons[index];
        return _SeasonExpandableCard(season: season);
      },
    );
  }
}

class _SeasonExpandableCard extends StatefulWidget {
  final Season season;

  const _SeasonExpandableCard({required this.season});

  @override
  State<_SeasonExpandableCard> createState() => _SeasonExpandableCardState();
}

class _SeasonExpandableCardState extends State<_SeasonExpandableCard> {
  bool _isExpanded = false;

  List<Lesson> _getSeasonLessons() {
    switch (widget.season.id) {
      case 1:
        return LessonDataProvider.getSeason1Lessons();
      case 2:
        return LessonDataProvider.getSeason2Lessons();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final seasonColors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final color = seasonColors[(widget.season.id - 1) % seasonColors.length];
    final lessons = _getSeasonLessons();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSeasonIcon(widget.season.iconName),
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.season.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${lessons.length} уроков',
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
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    'Уроки в сезоне:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...lessons.asMap().entries.map((entry) {
                    final i = entry.key;
                    final lesson = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  lesson.subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${lesson.durationMinutes} мин',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
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
      default:
        return Icons.star;
    }
  }
}

class _LessonsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lessons = LessonDataProvider.getSeason1Lessons();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(context, lesson);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(lesson.subtitle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${lesson.durationMinutes} мин'),
                    const SizedBox(width: 16),
                    Icon(Icons.code,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${lesson.taskStrings?.length ?? 0} заданий'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать: ${lesson.title}'),
        content: const Text(
            'Функция редактирования будет доступна в полной версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsSection(
          context,
          'Основные',
          [
            _buildSettingsTile(
                context, Icons.language, 'Язык приложения', 'Русский'),
            _buildSettingsTile(
                context, Icons.palette, 'Тема оформления', 'Светлая'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          context,
          'Контент',
          [
            _buildSettingsTile(
                context, Icons.school, 'Управление сезонами', ''),
            _buildSettingsTile(
                context, Icons.article, 'Управление уроками', ''),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          context,
          'Оплата',
          [
            _buildSettingsTile(context, Icons.payment, 'Способы оплаты', ''),
            _buildSettingsTile(context, Icons.discount, 'Промокоды', ''),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          context,
          'Поддержка',
          [
            _buildSettingsTile(
                context, Icons.telegram, 'Telegram бот', 'Настроить'),
            _buildSettingsTile(context, Icons.email, 'Email уведомления', ''),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: value.isNotEmpty
          ? Text(value, style: const TextStyle(color: Colors.grey))
          : const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

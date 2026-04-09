import 'package:flutter/material.dart';
import '../data/services/gamification_service.dart';

class Avatar {
  final String id;
  final String name;
  final IconData icon;
  final int cost;
  final bool isDefault;

  const Avatar({
    required this.id,
    required this.name,
    required this.icon,
    this.cost = 0,
    this.isDefault = false,
  });
}

class AvatarSelectionScreen extends StatefulWidget {
  final Function(String)? onSelect;

  const AvatarSelectionScreen({super.key, this.onSelect});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  static const List<Avatar> _allAvatars = [
    // Free avatars
    Avatar(id: 'robot_1', name: '🤖 Робот', icon: Icons.smart_toy, isDefault: true),
    Avatar(id: 'kid', name: '👋 Новичок', icon: Icons.waving_hand, cost: 0),
    // Premium avatars - buy with stars
    Avatar(id: 'scientist', name: '🔬 Учёный', icon: Icons.science, cost: 50),
    Avatar(id: 'coder', name: '💻 Программист', icon: Icons.code, cost: 80),
    Avatar(id: 'rocket', name: '🚀 Космонавт', icon: Icons.rocket_launch, cost: 100),
    Avatar(id: 'brain', name: '🧠 Гений', icon: Icons.psychology, cost: 120),
    Avatar(id: 'alien', name: '👽 Пришелец', icon: Icons.face, cost: 150),
    Avatar(id: 'robot_bot', name: '🤖 Дроид', icon: Icons.smart_toy, cost: 180),
    Avatar(id: 'star', name: '⭐ Суперзвезда', icon: Icons.star, cost: 200),
    Avatar(id: 'bolt', name: '⚡ Молния', icon: Icons.bolt, cost: 220),
    Avatar(id: 'dragon', name: '🐉 Дракон', icon: Icons.pets, cost: 250),
    Avatar(id: 'wizard', name: '🧙 Волшебник', icon: Icons.auto_fix_high, cost: 300),
    Avatar(id: 'ninja', name: '🥷 Ниндзя', icon: Icons.visibility, cost: 350),
    Avatar(id: 'astronaut', name: '🌙 Астронавт', icon: Icons.nightlight, cost: 400),
    Avatar(id: 'king', name: '👑 Король', icon: Icons.workspace_premium, cost: 450),
    Avatar(id: 'diamond', name: '💎 Алмаз', icon: Icons.diamond, cost: 500),
    Avatar(id: 'superhero', name: '🦸 Супергерой', icon: Icons.shield, cost: 550),
    Avatar(id: 'magic', name: '✨ Магия', icon: Icons.auto_awesome, cost: 600),
    Avatar(id: 'android', name: '🤖 Битбот', icon: Icons.android, cost: 650),
    Avatar(id: 'happy', name: '😀 Весёлый', icon: Icons.sentiment_very_satisfied, cost: 700),
    Avatar(id: 'cat', name: '🐱 Котенок', icon: Icons.pets, cost: 750),
    Avatar(id: 'robot2', name: '🦾 Терминатор', icon: Icons.smart_toy, cost: 800),
    Avatar(id: 'lightning', name: '💥 Молния', icon: Icons.flash_on, cost: 850),
    Avatar(id: 'castle', name: '🏰 Принцесса', icon: Icons.castle, cost: 900),
    Avatar(id: 'sports', name: '🏆 Чемпион', icon: Icons.emoji_events, cost: 1000),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = GamificationService.getProfile();
    final stats = GamificationService.getGamificationStats();
    final currentXp = stats['totalXpEarned'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбери аватар'),
        centerTitle: true,
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Доступно XP: $currentXp',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _allAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _allAvatars[index];
                  final isOwned = avatar.isDefault || currentXp >= avatar.cost;
                  final isSelected = profile.avatarId == avatar.id;

                  return _AvatarCard(
                    avatar: avatar,
                    isOwned: isOwned,
                    isSelected: isSelected,
                    onTap: isOwned
                        ? () => _selectAvatar(avatar.id)
                        : () => _showNotEnoughXpDialog(avatar),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAvatar(String avatarId) async {
    await GamificationService.setAvatar(avatarId);
    if (mounted) {
      setState(() {});
      widget.onSelect?.call(avatarId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Аватар выбран!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNotEnoughXpDialog(Avatar avatar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(avatar.icon, size: 32),
            const SizedBox(width: 8),
            Text(avatar.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Для этого аватара нужно больше XP!'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${avatar.cost} XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понял'),
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final Avatar avatar;
  final bool isOwned;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.avatar,
    required this.isOwned,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : isOwned
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOwned
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.grey.withOpacity(0.3),
              ),
              child: Icon(
                avatar.icon,
                size: 32,
                color: isOwned
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              avatar.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isOwned ? null : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (!avatar.isDefault) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond,
                    size: 12,
                    color: isOwned ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${avatar.cost}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isOwned ? Colors.amber : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            if (isSelected) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

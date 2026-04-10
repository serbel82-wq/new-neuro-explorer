class UserProfile {
  final String name;
  final int xp;
  final int level;
  final String avatarId;
  final int totalLessonsCompleted;
  final int totalTasksCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLoginDate;
  final int totalXpEarned;
  final int totalStars; // Звёзды за уроки
  final Map<int, int> seasonStars; // Звёзды по сезонам (seasonId -> stars)

  UserProfile({
    required this.name,
    this.xp = 0,
    this.level = 1,
    this.avatarId = 'default',
    this.totalLessonsCompleted = 0,
    this.totalTasksCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLoginDate,
    this.totalXpEarned = 0,
    this.totalStars = 0,
    Map<int, int>? seasonStars,
  }) : seasonStars = seasonStars ?? {};

  UserProfile copyWith({
    String? name,
    int? xp,
    int? level,
    String? avatarId,
    int? totalLessonsCompleted,
    int? totalTasksCompleted,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLoginDate,
    int? totalXpEarned,
    int? totalStars,
    Map<int, int>? seasonStars,
  }) {
    return UserProfile(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      avatarId: avatarId ?? this.avatarId,
      totalLessonsCompleted:
          totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      totalStars: totalStars ?? this.totalStars,
      seasonStars: seasonStars ?? this.seasonStars,
    );
  }

  int get xpForNextLevel => level * 100;

  int get xpProgress => xp;

  double get levelProgressPercent => xp / xpForNextLevel;
}

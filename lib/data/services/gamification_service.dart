import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

enum XpSource {
  lessonComplete(50),
  taskComplete(20),
  quizPerfectScore(30),
  dailyLogin(10),
  achievementUnlock(25),
  seasonComplete(100),
  firstLessonOfDay(15),
  streakBonus(5),
  perfectQuiz(40),
  creativeTaskComplete(35),
  referralBonus(100);

  final int xpValue;
  const XpSource(this.xpValue);
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isRare;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isRare = false,
  });
}

class GamificationService {
  static const String _profileKey = 'user_profile';
  static const String _unlockedAchievementsKey = 'unlocked_achievements';
  static const String _pendingRewardsKey = 'pending_rewards';
  static const String _seasonStarsKey = 'season_stars'; // Новый ключ для звёзд по сезонам

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('GamificationService not initialized');
    }
    return _prefs!;
  }

  static const List<Achievement> _allAchievements = [
    Achievement(
        id: 'first_step',
        title: 'Первый шаг',
        description: 'Пройди первый урок',
        iconName: 'star',
        isRare: false),
    Achievement(
        id: 'curious_mind',
        title: 'Любопытный ум',
        description: 'Начни 5 разных уроков',
        iconName: 'psychology',
        isRare: false),
    Achievement(
        id: 'week_streak',
        title: 'Недельная серия',
        description: 'Занимайся 7 дней подряд',
        iconName: 'local_fire_department',
        isRare: false),
    Achievement(
        id: 'month_streak',
        title: 'Месячная серия',
        description: 'Занимайся 30 дней подряд',
        iconName: 'whatshot',
        isRare: true),
    Achievement(
        id: 'quiz_master',
        title: 'Мастер квизов',
        description: 'Ответь правильно на 50 вопросов',
        iconName: 'quiz',
        isRare: false),
    Achievement(
        id: 'perfect_score',
        title: 'Отличник',
        description: 'Получи 100% в квизе 5 раз',
        iconName: 'emoji_events',
        isRare: false),
    Achievement(
        id: 'season_1_complete',
        title: 'Первый контакт',
        description: 'Заверши сезон 1',
        iconName: 'rocket_launch',
        isRare: false),
    Achievement(
        id: 'season_2_complete',
        title: 'Мир звука и видео',
        description: 'Заверши сезон 2',
        iconName: 'music_note',
        isRare: false),
    Achievement(
        id: 'creative_wizard',
        title: 'Творческий маг',
        description: 'Выполни 10 творческих заданий',
        iconName: 'auto_fix_high',
        isRare: false),
    Achievement(
        id: 'explorer',
        title: 'Исследователь',
        description: 'Пройди уроки в 3 разных сезонах',
        iconName: 'explore',
        isRare: false),
    Achievement(
        id: 'dedicated_student',
        title: 'Усердный ученик',
        description: 'Пройди 20 уроков',
        iconName: 'school',
        isRare: false),
    Achievement(
        id: 'streak_legend',
        title: 'Легенда серий',
        description: 'Достигни серии 50 дней',
        iconName: 'military_tech',
        isRare: true),
    Achievement(
        id: 'xp_collector',
        title: 'Коллекционер XP',
        description: 'Набери 1000 XP',
        iconName: 'diamond',
        isRare: false),
    Achievement(
        id: 'level_10',
        title: 'Новичок-исследователь',
        description: 'Достигни 10 уровня',
        iconName: 'trending_up',
        isRare: false),
    Achievement(
        id: 'level_25',
        title: 'Опытный исследователь',
        description: 'Достигни 25 уровня',
        iconName: 'workspace_premium',
        isRare: true),
    Achievement(
        id: 'level_50',
        title: 'Мастер нейросетей',
        description: 'Достигни 50 уровня',
        iconName: 'blocks',
        isRare: true),
    Achievement(
        id: 'first_creative',
        title: 'Первое творение',
        description: 'Выполни первое творческое задание',
        iconName: 'palette',
        isRare: false),
    Achievement(
        id: 'prompt_master',
        title: 'Мастер промптов',
        description: 'Создай 5 хороших промптов',
        iconName: 'edit_note',
        isRare: false),
    Achievement(
        id: 'safe_user',
        title: 'Безопасный пользователь',
        description: 'Пройди урок о безопасности',
        iconName: 'security',
        isRare: false),
    Achievement(
        id: 'parent_approved',
        title: 'Семейный герой',
        description: 'Пригласи родителя в кабинет',
        iconName: 'family_restroom',
        isRare: false),
    Achievement(
        id: 'star_collector_10',
        title: 'Сборщик звёзд',
        description: 'Собери 10 звёзд',
        iconName: 'stars',
        isRare: false),
    Achievement(
        id: 'star_collector_50',
        title: 'Звёздный охотник',
        description: 'Собери 50 звёзд',
        iconName: 'auto_awesome',
        isRare: false),
    Achievement(
        id: 'star_collector_100',
        title: 'Звездочёт',
        description: 'Собери 100 звёзд',
        iconName: 'nightlight_round',
        isRare: true),
    Achievement(
        id: 'ai_conversation_starter',
        title: 'Первый разговор',
        description: 'Начни первый диалог с ИИ',
        iconName: 'chat_bubble_outline',
        isRare: false),
    Achievement(
        id: 'ai_explorer',
        title: 'Исследователь ИИ',
        description: 'Задай 10 вопросов ИИ',
        iconName: 'help_outline',
        isRare: false),
    Achievement(
        id: 'daily_goal_achiever',
        title: 'Целеустремлённый',
        description: 'Выполни дневную цель 7 дней подряд',
        iconName: 'flag',
        isRare: false),
    Achievement(
        id: 'social_share',
        title: 'Популяризатор',
        description: 'Поделился результатом с друзьями',
        iconName: 'share',
        isRare: false),
  ];

  static UserProfile _getEmptyProfile(String name) {
    return UserProfile(
      name: name,
      xp: 0,
      level: 1,
      avatarId: 'robot_1',
      totalLessonsCompleted: 0,
      totalTasksCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastLoginDate: DateTime.now(),
      totalXpEarned: 0,
    );
  }

  static UserProfile getProfile() {
    final String? data = prefs.getString(_profileKey);
    if (data == null) {
      final name = _getUserName() ?? 'Путник';
      return _getEmptyProfile(name);
    }
    final Map<String, dynamic> json = jsonDecode(data);
    
    // Загрузка звёзд по сезонам
    Map<int, int> seasonStars = {};
    if (json['seasonStars'] != null) {
      final starsData = json['seasonStars'] as Map<String, dynamic>;
      seasonStars = Map.fromEntries(
        starsData.entries.map((e) => MapEntry(int.parse(e.key), e.value as int)),
      );
    }
    
    return UserProfile(
      name: json['name'] ?? 'Путник',
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      avatarId: json['avatarId'] ?? 'robot_1',
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'])
          : null,
      totalXpEarned: json['totalXpEarned'] ?? 0,
      totalStars: json['totalStars'] ?? 0,
      seasonStars: seasonStars,
    );
  }

  static String? _getUserName() {
    final String? data = prefs.getString('user_name');
    return data;
  }

  static Future<void> _saveProfile(UserProfile profile) async {
    final Map<String, dynamic> json = {
      'name': profile.name,
      'xp': profile.xp,
      'level': profile.level,
      'avatarId': profile.avatarId,
      'totalLessonsCompleted': profile.totalLessonsCompleted,
      'totalTasksCompleted': profile.totalTasksCompleted,
      'currentStreak': profile.currentStreak,
      'longestStreak': profile.longestStreak,
      'lastLoginDate': profile.lastLoginDate?.toIso8601String(),
      'totalXpEarned': profile.totalXpEarned,
      'totalStars': profile.totalStars,
      'seasonStars': Map.fromEntries(
        profile.seasonStars.entries.map((e) => MapEntry(e.key.toString(), e.value)),
      ),
    };
    await prefs.setString(_profileKey, jsonEncode(json));
  }

  static Future<int> addXp(XpSource source, {int multiplier = 1}) async {
    final profile = getProfile();
    int xpEarned = source.xpValue * multiplier;

    int newXp = profile.xp + xpEarned;
    int newLevel = profile.level;
    int remainingXp = newXp;

    while (remainingXp >= newLevel * 100) {
      remainingXp -= newLevel * 100;
      newLevel++;
    }

    final updatedProfile = profile.copyWith(
      xp: remainingXp,
      level: newLevel,
      totalXpEarned: profile.totalXpEarned + xpEarned,
      lastLoginDate: DateTime.now(),
    );

    await _saveProfile(updatedProfile);

    await _checkLevelUpAchievements(newLevel);
    await _checkXpAchievements(updatedProfile.totalXpEarned);

    return xpEarned;
  }

  static Future<void> _checkLevelUpAchievements(int newLevel) async {
    if (newLevel >= 10) {
      await unlockAchievement('level_10');
    }
    if (newLevel >= 25) {
      await unlockAchievement('level_25');
    }
    if (newLevel >= 50) {
      await unlockAchievement('level_50');
    }
  }

  static Future<void> _checkXpAchievements(int totalXp) async {
    if (totalXp >= 1000) {
      await unlockAchievement('xp_collector');
    }
  }

  static Future<int> addLessonComplete() async {
    final profile = getProfile();
    final updatedProfile = profile.copyWith(
      totalLessonsCompleted: profile.totalLessonsCompleted + 1,
    );
    await _saveProfile(updatedProfile);

    final xp = await addXp(XpSource.lessonComplete);

    if (updatedProfile.totalLessonsCompleted == 1) {
      await unlockAchievement('first_step');
    }
    if (updatedProfile.totalLessonsCompleted >= 20) {
      await unlockAchievement('dedicated_student');
    }

    return xp;
  }

  static Future<int> addTaskComplete({bool isCreative = false}) async {
    final profile = getProfile();
    final updatedProfile = profile.copyWith(
      totalTasksCompleted: profile.totalTasksCompleted + 1,
    );
    await _saveProfile(updatedProfile);

    final source =
        isCreative ? XpSource.creativeTaskComplete : XpSource.taskComplete;
    final xp = await addXp(source);

    if (updatedProfile.totalTasksCompleted == 1) {
      await unlockAchievement('first_creative');
    }
    if (updatedProfile.totalTasksCompleted >= 10 && isCreative) {
      await unlockAchievement('creative_wizard');
    }
    if (updatedProfile.totalTasksCompleted >= 50) {
      await unlockAchievement('quiz_master');
    }

    return xp;
  }

  static Future<int> addPerfectQuiz() async {
    final xp = await addXp(XpSource.perfectQuiz);

    final profile = getProfile();
    final perfectQuizzes = prefs.getInt('perfect_quizzes_count') ?? 0;
    await prefs.setInt('perfect_quizzes_count', perfectQuizzes + 1);

    if (perfectQuizzes + 1 >= 5) {
      await unlockAchievement('perfect_score');
    }

    return xp;
  }

  static Future<int> processDailyLogin() async {
    final profile = getProfile();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (profile.lastLoginDate != null) {
      final lastLogin = DateTime(
        profile.lastLoginDate!.year,
        profile.lastLoginDate!.month,
        profile.lastLoginDate!.day,
      );

      final difference = today.difference(lastLogin).inDays;

      if (difference == 0) {
        return 0;
      }

      int newStreak = profile.currentStreak;
      if (difference == 1) {
        newStreak++;
        final streakBonus = newStreak * XpSource.streakBonus.xpValue;
        await addXp(XpSource.dailyLogin);
        await addXp(XpSource.streakBonus, multiplier: newStreak);

        if (newStreak >= 7) {
          await unlockAchievement('week_streak');
        }
        if (newStreak >= 30) {
          await unlockAchievement('month_streak');
        }
        if (newStreak > profile.longestStreak) {
          final updatedProfile = profile.copyWith(longestStreak: newStreak);
          await _saveProfile(updatedProfile);
        }
        if (newStreak >= 50) {
          await unlockAchievement('streak_legend');
        }
      } else if (difference > 1) {
        newStreak = 1;
        await addXp(XpSource.dailyLogin);
      }

      final updatedProfile = profile.copyWith(
        currentStreak: newStreak,
        lastLoginDate: now,
      );
      await _saveProfile(updatedProfile);
    } else {
      await addXp(XpSource.dailyLogin);
      final updatedProfile = profile.copyWith(
        currentStreak: 1,
        lastLoginDate: now,
      );
      await _saveProfile(updatedProfile);
    }

    return XpSource.dailyLogin.xpValue;
  }

  static Future<void> addFirstLessonOfDayXp() async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastFirstLesson = prefs.getString('last_first_lesson_date');

    if (lastFirstLesson != todayStr) {
      await prefs.setString('last_first_lesson_date', todayStr);
      await addXp(XpSource.firstLessonOfDay);
    }
  }

  static List<Achievement> getUnlockedAchievements() {
    final List<String> unlockedIds =
        prefs.getStringList(_unlockedAchievementsKey) ?? [];
    return _allAchievements.where((a) => unlockedIds.contains(a.id)).toList();
  }

  static List<Achievement> getLockedAchievements() {
    final List<String> unlockedIds =
        prefs.getStringList(_unlockedAchievementsKey) ?? [];
    return _allAchievements.where((a) => !unlockedIds.contains(a.id)).toList();
  }

  static Future<bool> unlockAchievement(String achievementId) async {
    final List<String> unlockedIds =
        prefs.getStringList(_unlockedAchievementsKey) ?? [];

    if (unlockedIds.contains(achievementId)) {
      return false;
    }

    unlockedIds.add(achievementId);
    await prefs.setStringList(_unlockedAchievementsKey, unlockedIds);

    await addXp(XpSource.achievementUnlock);

    return true;
  }

  static Future<void> setAvatar(String avatarId) async {
    final profile = getProfile();
    final updatedProfile = profile.copyWith(avatarId: avatarId);
    await _saveProfile(updatedProfile);
  }

  static Future<void> completeSeason(int seasonId) async {
    await addXp(XpSource.seasonComplete);

    if (seasonId == 1) {
      await unlockAchievement('season_1_complete');
    }
    if (seasonId == 2) {
      await unlockAchievement('season_2_complete');
    }
  }

  // Добавить звёзды за урок (1-3 звезды в зависимости от результата)
  static Future<void> addStars(int seasonId, int stars) async {
    final profile = getProfile();
    final currentSeasonStars = profile.seasonStars[seasonId] ?? 0;
    final newSeasonStars = currentSeasonStars + stars;
    final newTotalStars = profile.totalStars + stars;
    
    final newSeasonStarsMap = Map<int, int>.from(profile.seasonStars);
    newSeasonStarsMap[seasonId] = newSeasonStars;
    
    final updatedProfile = profile.copyWith(
      totalStars: newTotalStars,
      seasonStars: newSeasonStarsMap,
    );
    await _saveProfile(updatedProfile);
    
    // Проверка достижений по звёздам
    if (newTotalStars >= 10) {
      await unlockAchievement('star_collector_10');
    }
    if (newTotalStars >= 50) {
      await unlockAchievement('star_collector_50');
    }
    if (newTotalStars >= 100) {
      await unlockAchievement('star_collector_100');
    }
  }

  // Получить звёзды для конкретного сезона
  static int getSeasonStars(int seasonId) {
    final profile = getProfile();
    return profile.seasonStars[seasonId] ?? 0;
  }

  // Получить общее количество звёзд
  static int getTotalStars() {
    final profile = getProfile();
    return profile.totalStars;
  }

  // Добавить звёзды за прохождение урока с результатом
  static Future<int> addLessonWithStars(int seasonId, int taskScore) async {
    // taskScore от 0 до 100
    int stars = 1; // Минимум 1 звезда за завершение
    if (taskScore >= 60) stars = 2;
    if (taskScore >= 90) stars = 3;
    
    await addStars(seasonId, stars);
    return stars;
  }

  static Map<String, dynamic> getGamificationStats() {
    final profile = getProfile();
    final unlocked = getUnlockedAchievements();
    final totalAchievements = _allAchievements.length;

    return {
      'xp': profile.xp,
      'level': profile.level,
      'totalXpEarned': profile.totalXpEarned,
      'xpForNextLevel': profile.xpForNextLevel,
      'levelProgress': profile.levelProgressPercent,
      'currentStreak': profile.currentStreak,
      'longestStreak': profile.longestStreak,
      'lessonsCompleted': profile.totalLessonsCompleted,
      'tasksCompleted': profile.totalTasksCompleted,
      'achievementsUnlocked': unlocked.length,
      'totalAchievements': totalAchievements,
      'achievementProgress': unlocked.length / totalAchievements,
      'totalStars': profile.totalStars,
      'seasonStars': profile.seasonStars,
    };
  }

  static String getLevelTitle(int level) {
    if (level < 5) return 'Новичок';
    if (level < 10) return 'Ученик';
    if (level < 15) return 'Исследователь';
    if (level < 20) return 'Помощник';
    if (level < 25) return 'Навигатор';
    if (level < 30) return 'Эксперт';
    if (level < 35) return 'Мастер';
    if (level < 40) return 'Профи';
    if (level < 45) return 'Гуру';
    return 'Легенда';
  }

  static String getLevelEmoji(int level) {
    if (level < 5) return '🌱';
    if (level < 10) return '⭐';
    if (level < 15) return '🌟';
    if (level < 20) return '💫';
    if (level < 25) return '🚀';
    if (level < 30) return '🔥';
    if (level < 35) return '💎';
    if (level < 40) return '🏆';
    if (level < 45) return '👑';
    return '🌟✨';
  }

  static Future<void> clearAllGamificationData() async {
    await prefs.remove(_profileKey);
    await prefs.remove(_unlockedAchievementsKey);
    await prefs.remove(_pendingRewardsKey);
    await prefs.remove('perfect_quizzes_count');
    await prefs.remove('last_first_lesson_date');
  }
}

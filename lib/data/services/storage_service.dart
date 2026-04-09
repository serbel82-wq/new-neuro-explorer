import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _userNameKey = 'user_name';
  static const String _completedLessonsKey = 'completed_lessons';
  static const String _currentSeasonKey = 'current_season';
  static const String _currentLessonKey = 'current_lesson';
  static const String _lastActiveKey = 'last_active_date';
  static const String _achievementsKey = 'achievements';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _referralCodeKey = 'referral_code';
  static const String _referredByKey = 'referred_by';
  static const String _referralBonusKey = 'referral_bonus';

  static SharedPreferences? _prefs;
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Загружает данные из облака и обновляет локальное хранилище.
  /// Полезно при входе в аккаунт или переустановке приложения.
  static Future<void> loadFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      
      // Восстанавливаем имя
      if (data['userName'] != null) {
        await prefs.setString(_userNameKey, data['userName']);
      }
      
      // Восстанавливаем пройденные уроки
      if (data['completedLessons'] != null) {
        final List<dynamic> lessons = data['completedLessons'];
        await prefs.setString(_completedLessonsKey, jsonEncode(lessons.cast<int>()));
      }

      // Восстанавливаем текущую позицию
      if (data['currentSeason'] != null) {
        await prefs.setInt(_currentSeasonKey, data['currentSeason']);
      }
      if (data['currentLesson'] != null) {
        await prefs.setInt(_currentLessonKey, data['currentLesson']);
      }

      // Восстанавливаем достижения
      if (data['achievements'] != null) {
        final List<dynamic> achs = data['achievements'];
        await prefs.setStringList(_achievementsKey, achs.cast<String>());
      }

      // Статус онбординга
      if (data['onboardingCompleted'] != null) {
        await prefs.setBool(_onboardingCompletedKey, data['onboardingCompleted']);
      }

      debugPrint('StorageService: Прогресс успешно загружен из облака.');
    } catch (e) {
      debugPrint('StorageService: Ошибка загрузки из облака: $e');
    }
  }

  /// Синхронизирует локальные данные с облаком (Firestore).
  /// Работает тихо в фоне, не мешая пользователю.
  static Future<void> syncToCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final data = {
        'userName': getUserName(),
        'completedLessons': getCompletedLessons(),
        'currentSeason': getCurrentSeason(),
        'currentLesson': getCurrentLesson(),
        'achievements': getAchievements(),
        'onboardingCompleted': isOnboardingCompleted(),
        'lastActive': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Сохраняем в документ пользователя (merge: true не перезапишет другие поля)
      await _db.collection('users').doc(user.uid).set(
        data, 
        SetOptions(merge: true)
      );
      debugPrint('StorageService: Данные успешно синхронизированы с облаком.');
    } catch (e) {
      debugPrint('StorageService: Ошибка синхронизации (возможно нет сети или Google заблокирован): $e');
      // Мы ничего не делаем, так как локальные данные уже сохранены.
    }
  }

  // User Name
  static Future<void> setUserName(String name) async {
    await prefs.setString(_userNameKey, name);
    syncToCloud(); // Запуск синхронизации
  }

  static String? getUserName() {
    return prefs.getString(_userNameKey);
  }

  // Completed Lessons
  static Future<void> setCompletedLessons(List<int> lessons) async {
    await prefs.setString(_completedLessonsKey, jsonEncode(lessons));
    syncToCloud();
  }

  static List<int> getCompletedLessons() {
    final String? data = prefs.getString(_completedLessonsKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<int>();
  }

  static Future<void> addCompletedLesson(int lessonId) async {
    final lessons = getCompletedLessons();
    if (!lessons.contains(lessonId)) {
      lessons.add(lessonId);
      await setCompletedLessons(lessons);
    }
  }

  static bool isLessonCompleted(int lessonId) {
    return getCompletedLessons().contains(lessonId);
  }

  // Current Season & Lesson
  static Future<void> setCurrentPosition(int season, int lesson) async {
    await prefs.setInt(_currentSeasonKey, season);
    await prefs.setInt(_currentLessonKey, lesson);
  }

  static int getCurrentSeason() {
    return prefs.getInt(_currentSeasonKey) ?? 1;
  }

  static int getCurrentLesson() {
    return prefs.getInt(_currentLessonKey) ?? 1;
  }

  // Last Active Date
  static Future<void> setLastActiveDate(DateTime date) async {
    await prefs.setString(_lastActiveKey, date.toIso8601String());
  }

  static DateTime? getLastActiveDate() {
    final String? data = prefs.getString(_lastActiveKey);
    if (data == null) return null;
    return DateTime.parse(data);
  }

  // Achievements
  static Future<void> setAchievements(List<String> achievements) async {
    await prefs.setStringList(_achievementsKey, achievements);
  }

  static List<String> getAchievements() {
    return prefs.getStringList(_achievementsKey) ?? [];
  }

  static Future<void> addAchievement(String achievement) async {
    final achievements = getAchievements();
    if (!achievements.contains(achievement)) {
      achievements.add(achievement);
      await setAchievements(achievements);
    }
  }

  // Onboarding
  static Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  static bool isOnboardingCompleted() {
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // Get progress statistics
  static int getTotalCompletedLessons() {
    return getCompletedLessons().length;
  }

  static double getProgressPercent(int totalLessons) {
    if (totalLessons == 0) return 0;
    return (getTotalCompletedLessons() / totalLessons * 100).clamp(0, 100);
  }

  // Referral
  static Future<void> setReferralCode(String code) async {
    await prefs.setString(_referralCodeKey, code);
  }

  static String? getReferralCode() {
    return prefs.getString(_referralCodeKey);
  }

  static Future<void> setReferredBy(String code) async {
    await prefs.setString(_referredByKey, code);
    await prefs.setBool(_referralBonusKey, true);
  }

  static String? getReferredBy() {
    return prefs.getString(_referredByKey);
  }

  static bool hasReferralBonus() {
    return prefs.getBool(_referralBonusKey) ?? false;
  }
}

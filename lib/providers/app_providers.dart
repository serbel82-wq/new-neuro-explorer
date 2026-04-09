import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/firebase_service.dart';
import '../data/services/gamification_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/chat_service.dart';

/// Провайдер для AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Провайдер для текущего пользователя
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStatus.map((status) {
    return authService.currentUser;
  });
});

/// Провайдер для FirebaseService
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Провайдер для GamificationService
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

/// Провайдер для ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// Провайдер для прогресса пользователя
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressState>((ref) {
  return UserProgressNotifier();
});

class UserProgressState {
  final int currentSeason;
  final int currentLesson;
  final List<int> completedLessons;
  final int xp;
  final int level;
  final List<String> achievements;

  UserProgressState({
    this.currentSeason = 1,
    this.currentLesson = 1,
    this.completedLessons = const [],
    this.xp = 0,
    this.level = 1,
    this.achievements = const [],
  });

  UserProgressState copyWith({
    int? currentSeason,
    int? currentLesson,
    List<int>? completedLessons,
    int? xp,
    int? level,
    List<String>? achievements,
  }) {
    return UserProgressState(
      currentSeason: currentSeason ?? this.currentSeason,
      currentLesson: currentLesson ?? this.currentLesson,
      completedLessons: completedLessons ?? this.completedLessons,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      achievements: achievements ?? this.achievements,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  UserProgressNotifier() : super(UserProgressState()) {
    _loadProgress();
  }

  void _loadProgress() {
    state = state.copyWith(
      currentSeason: StorageService.getCurrentSeason(),
      currentLesson: StorageService.getCurrentLesson(),
      completedLessons: StorageService.getCompletedLessons(),
      achievements: StorageService.getAchievements(),
    );
  }

  Future<void> completeLesson(int lessonId) async {
    if (!state.completedLessons.contains(lessonId)) {
      final newCompleted = [...state.completedLessons, lessonId];
      await StorageService.setCompletedLessons(newCompleted);

      // Начисляем XP
      final xpEarned = GamificationService.calculateXPFoLesson(lessonId);
      final newXp = state.xp + xpEarned;
      final newLevel = GamificationService.calculateLevel(newXp);

      state = state.copyWith(
        completedLessons: newCompleted,
        xp: newXp,
        level: newLevel,
      );
    }
  }

  Future<void> addAchievement(String achievement) async {
    if (!state.achievements.contains(achievement)) {
      final newAchievements = [...state.achievements, achievement];
      await StorageService.setAchievements(newAchievements);
      state = state.copyWith(achievements: newAchievements);
    }
  }

  Future<void> setCurrentPosition(int season, int lesson) async {
    await StorageService.setCurrentPosition(season, lesson);
    state = state.copyWith(
      currentSeason: season,
      currentLesson: lesson,
    );
  }
}

/// Провайдер для AI чата
final aiChatProvider =
    StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier(ref.watch(chatServiceProvider));
});

class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIChatNotifier extends StateNotifier<AIChatState> {
  final ChatService _chatService;

  AIChatNotifier(this._chatService) : super(AIChatState());

  Future<void> sendMessage(String message, {String? context}) async {
    state = state.copyWith(isLoading: true, error: null);

    // Добавляем сообщение пользователя
    final userMessage = ChatMessage(role: 'user', content: message);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
    );

    try {
      final response =
          await _chatService.sendAIChatMessage(message, context: context);
      final aiMessage = ChatMessage(role: 'assistant', content: response);
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Произошла ошибка. Попробуй позже.',
      );
    }
  }

  void clearHistory() {
    _chatService.clearAIChatHistory();
    state = AIChatState();
  }
}

/// Провайдер для подписки
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionState {
  final bool isSubscribed;
  final bool isTrialActive;
  final DateTime? subscriptionEnd;
  final int trialDaysRemaining;

  SubscriptionState({
    this.isSubscribed = false,
    this.isTrialActive = true,
    this.subscriptionEnd,
    this.trialDaysRemaining = 7,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    bool? isTrialActive,
    DateTime? subscriptionEnd,
    int? trialDaysRemaining,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(SubscriptionState()) {
    _loadSubscription();
  }

  void _loadSubscription() {
    final service = SubscriptionService();
    final info = service.getSubscriptionInfo();
    state = SubscriptionState(
      isSubscribed: info['isSubscribed'] as bool,
      isTrialActive: info['isTrialActive'] as bool,
      subscriptionEnd: info['subscriptionEnd'] != null
          ? DateTime.parse(info['subscriptionEnd'] as String)
          : null,
      trialDaysRemaining: info['trialDaysRemaining'] as int,
    );
  }

  Future<void> activateTrial() async {
    final service = SubscriptionService();
    await service.activateTrial();
    _loadSubscription();
  }

  Future<void> subscribe({required int months}) async {
    final service = SubscriptionService();
    // В реальном приложении здесь будет интеграция с платежами
    await service.subscribe(months: months, paymentMethodId: 'mock');
    _loadSubscription();
  }

  Future<void> cancelSubscription() async {
    final service = SubscriptionService();
    await service.cancelSubscription();
    _loadSubscription();
  }
}

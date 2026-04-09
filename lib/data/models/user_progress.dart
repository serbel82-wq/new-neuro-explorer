class UserProgress {
  final String odUserName;
  final List<int> completedLessons;
  final int currentSeason;
  final int currentLesson;
  final DateTime? lastActiveDate;
  final List<String> achievements;

  UserProgress({
    required this.odUserName,
    List<int>? completedLessons,
    this.currentSeason = 1,
    this.currentLesson = 1,
    this.lastActiveDate,
    List<String>? achievements,
  })  : completedLessons = completedLessons ?? [],
        achievements = achievements ?? [];

  bool isLessonCompleted(int lessonId) => completedLessons.contains(lessonId);

  int get completedCount => completedLessons.length;

  double getProgressPercent(int totalLessons) {
    if (totalLessons == 0) return 0;
    return (completedCount / totalLessons * 100).clamp(0, 100);
  }

  UserProgress copyWith({
    String? odUserName,
    List<int>? completedLessons,
    int? currentSeason,
    int? currentLesson,
    DateTime? lastActiveDate,
    List<String>? achievements,
  }) {
    return UserProgress(
      odUserName: odUserName ?? this.odUserName,
      completedLessons: completedLessons ?? this.completedLessons,
      currentSeason: currentSeason ?? this.currentSeason,
      currentLesson: currentLesson ?? this.currentLesson,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      achievements: achievements ?? this.achievements,
    );
  }
}
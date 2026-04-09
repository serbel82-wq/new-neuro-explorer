class Season {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final int lessonsCount;
  final String iconName;
  final bool isUnlocked;
  final double progress;

  const Season({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.lessonsCount,
    required this.iconName,
    this.isUnlocked = false,
    this.progress = 0,
  });

  Season copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? description,
    int? lessonsCount,
    String? iconName,
    bool? isUnlocked,
    double? progress,
  }) {
    return Season(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
    );
  }
}
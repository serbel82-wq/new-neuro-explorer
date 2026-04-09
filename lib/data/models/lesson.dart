import 'task.dart';

class Lesson {
  final int id;
  final int seasonId;
  final int order;
  final String title;
  final String subtitle;
  final String theoryText;
  final List<Task> tasks;
  final List<String>? taskStrings;
  final List<String>? taskInstructions;
  final int durationMinutes;
  final String iconName;

  Lesson({
    required this.id,
    required this.seasonId,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.theoryText,
    this.tasks = const [],
    this.taskStrings,
    this.taskInstructions,
    required this.durationMinutes,
    required this.iconName,
  });
}
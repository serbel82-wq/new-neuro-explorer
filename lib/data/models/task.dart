enum TaskType {
  text,
  quiz,
  choice,
  code,
  creative,
}

class TaskQuestion {
  final String question;
  final TaskType type;
  final List<String>? options;
  final String? correctAnswer;
  final List<String>? correctAnswers;
  final String? hint;
  final int points;

  const TaskQuestion({
    required this.question,
    required this.type,
    this.options,
    this.correctAnswer,
    this.correctAnswers,
    this.hint,
    this.points = 10,
  });
}

class Task {
  final String? id;
  final String title;
  final String description;
  final TaskType type;
  final List<TaskQuestion>? questions;
  final String? instruction;
  final int totalPoints;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.questions,
    this.instruction,
    this.totalPoints = 10,
  });
}
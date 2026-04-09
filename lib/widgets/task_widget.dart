import 'package:flutter/material.dart';
import '../data/models/task.dart';

class TaskWidget extends StatefulWidget {
  final Task? task;
  final String? taskTitle;
  final String? taskInstruction;
  final Function(List<String>)? onAnswered;

  const TaskWidget({
    super.key,
    this.task,
    this.taskTitle,
    this.taskInstruction,
    this.onAnswered,
  });

  factory TaskWidget.fromLegacy({
    required String title,
    required String instruction,
    Function(List<String>)? onAnswered,
  }) {
    return TaskWidget(
      taskTitle: title,
      taskInstruction: instruction,
      onAnswered: onAnswered,
    );
  }

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final TextEditingController _textController = TextEditingController();
  int? _selectedOptionIndex;
  final Map<int, int> _quizAnswers = {};
  bool _showResults = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.quiz:
        return Icons.quiz;
      case TaskType.choice:
        return Icons.rule;
      case TaskType.text:
        return Icons.edit;
      case TaskType.code:
        return Icons.code;
      case TaskType.creative:
        return Icons.palette;
    }
  }

  Color _getTaskColor(TaskType type) {
    switch (type) {
      case TaskType.quiz:
        return Colors.blue;
      case TaskType.choice:
        return Colors.green;
      case TaskType.text:
        return Colors.orange;
      case TaskType.code:
        return Colors.purple;
      case TaskType.creative:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskType = widget.task?.type ?? TaskType.text;
    final taskTitle = widget.task?.title ?? widget.taskTitle ?? 'Задание';
    final taskDesc = widget.task?.description ?? '';
    final taskInstruction = widget.task?.instruction ?? widget.taskInstruction ?? '';
    final totalPoints = widget.task?.totalPoints ?? 10;
    
    final taskColor = _getTaskColor(taskType);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: taskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getTaskIcon(taskType), color: taskColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (taskDesc.isNotEmpty)
                        Text(
                          taskDesc,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '$totalPoints',
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
            const SizedBox(height: 16),
            if (taskInstruction.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        taskInstruction,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildTaskInput(taskType),
            if (_showResults) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInput(TaskType taskType) {
    switch (taskType) {
      case TaskType.quiz:
        return _buildQuiz();
      case TaskType.choice:
        return _buildChoice();
      case TaskType.text:
        return _buildTextInput();
      case TaskType.code:
      case TaskType.creative:
        return _buildTextInput();
    }
  }

  Widget _buildQuiz() {
    final questions = widget.task?.questions ?? [];
    
    if (questions.isEmpty) {
      return const Text('Нет вопросов');
    }

    return Column(
      children: List.generate(questions.length, (qIndex) {
        final question = questions[qIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${qIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${question.points}★',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              if (question.options != null && question.options!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...List.generate(question.options!.length, (optIndex) {
                  final isSelected = _quizAnswers[qIndex] == optIndex;
                  final isCorrect = question.correctAnswer == question.options![optIndex];
                  
                  Color? bgColor;
                  Color? borderColor;
                  
                  if (_showResults) {
                    if (isCorrect) {
                      bgColor = Colors.green.withOpacity(0.2);
                      borderColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Colors.red.withOpacity(0.2);
                      borderColor = Colors.red;
                    }
                  } else if (isSelected) {
                    bgColor = Theme.of(context).colorScheme.primaryContainer;
                    borderColor = Theme.of(context).colorScheme.primary;
                  }

                  return GestureDetector(
                    onTap: _showResults ? null : () {
                      setState(() {
                        _quizAnswers[qIndex] = optIndex;
                        widget.onAnswered?.call([question.options![optIndex]]);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgColor ?? Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor ?? Colors.grey.withOpacity(0.3),
                          width: isSelected || (_showResults && isCorrect) ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(question.options![optIndex]),
                          ),
                          if (_showResults && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              if (question.hint != null && !_showResults) ...[
                const SizedBox(height: 8),
                Text(
                  'Подсказка: ${question.hint}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChoice() {
    final choiceQuestions = widget.task?.questions ?? [];
    
    if (choiceQuestions.isEmpty) {
      return const Text('Нет вариантов');
    }

    final question = choiceQuestions.first;
    final options = question.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (index) {
            final isSelected = _selectedOptionIndex == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOptionIndex = index;
                  _showResults = true;
                });
                widget.onAnswered?.call([options[index]]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
        if (_showResults && question.correctAnswer != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Правильный ответ: ${question.correctAnswer}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Введи свой ответ здесь...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
    );
  }

  Widget _buildResults() {
    final resultQuestions = widget.task?.questions ?? [];
    
    if (resultQuestions.isEmpty) return const SizedBox();

    int correctCount = 0;
    int totalQuestions = resultQuestions.length;

    for (int i = 0; i < resultQuestions.length; i++) {
      final question = resultQuestions[i];
      final userAnswer = _quizAnswers[i];
      if (userAnswer != null && question.options != null) {
        if (question.options![userAnswer] == question.correctAnswer) {
          correctCount++;
        }
      }
    }

    final percentage = totalQuestions > 0 ? (correctCount / totalQuestions * 100).round() : 0;
    final isGood = percentage >= 70;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGood ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGood ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.celebration : Icons.sentiment_satisfied,
            color: isGood ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGood ? 'Отлично!' : 'Хорошая попытка!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isGood ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  '$correctCount из $totalQuestions правильных ответов ($percentage%)',
                  style: TextStyle(
                    color: isGood ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
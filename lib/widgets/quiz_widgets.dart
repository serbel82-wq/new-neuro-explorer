import 'package:flutter/material.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

class QuizWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String title;
  final Color color;
  final Function(int)? onComplete;

  const QuizWidget({
    super.key,
    required this.questions,
    required this.title,
    required this.color,
    this.onComplete,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  final List<int> _answers = [];

  void _answer(int index) {
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _answers.add(index);
      if (index == widget.questions[_currentQuestion].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      widget.onComplete?.call(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / widget.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.quiz, color: widget.color),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentQuestion + 1}/${widget.questions.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: widget.color.withOpacity(0.2),
            color: widget.color,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          question.question,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(question.options.length, (index) {
          final isSelected = _selectedAnswer == index;
          final isCorrect = index == question.correctIndex;
          
          Color? bgColor;
          Color? borderColor;
          
          if (_answered) {
            if (isCorrect) {
              bgColor = Colors.green.withOpacity(0.2);
              borderColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              bgColor = Colors.red.withOpacity(0.2);
              borderColor = Colors.red;
            }
          } else if (isSelected) {
            bgColor = widget.color.withOpacity(0.2);
            borderColor = widget.color;
          }

          return GestureDetector(
            onTap: _answered ? null : () => _answer(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (borderColor ?? widget.color)
                          : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (_answered && isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green),
                  if (_answered && isSelected && !isCorrect)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ),
            ),
          );
        }),
        if (_answered && question.explanation != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (_answered)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextQuestion,
              child: Text(
                _currentQuestion < widget.questions.length - 1
                    ? 'Следующий вопрос'
                    : 'Завершить квиз',
              ),
            ),
          ),
        if (!_answered && _score > 0)
          Center(
            child: Text(
              'Выбери ответ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class TrueFalseWidget extends StatefulWidget {
  final List<Map<String, dynamic>> statements;
  final String title;
  final Color color;
  final Function(int)? onComplete;

  const TrueFalseWidget({
    super.key,
    required this.statements,
    required this.title,
    required this.color,
    this.onComplete,
  });

  @override
  State<TrueFalseWidget> createState() => _TrueFalseWidgetState();
}

class _TrueFalseWidgetState extends State<TrueFalseWidget> {
  int _currentIndex = 0;
  int _score = 0;
  final List<bool?> _answers = [];

  void _answer(bool isTrue) {
    final isCorrect = isTrue == widget.statements[_currentIndex]['isTrue'];
    setState(() {
      _answers.add(isTrue);
      if (isCorrect) _score++;
      
      if (_currentIndex < widget.statements.length - 1) {
        _currentIndex++;
      } else {
        widget.onComplete?.call(_score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statement = widget.statements[_currentIndex];
    final progress = (_currentIndex + 1) / widget.statements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: widget.color),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1}/${widget.statements.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: widget.color.withOpacity(0.2),
            color: widget.color,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          statement['text'] as String,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: isCompleted 
                ? _buildResultButton(statement['isTrue'] as bool, statement, Colors.green)
                : FilledButton(
                    onPressed: () => _answer(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('Верно'),
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: isCompleted
                ? _buildResultButton(!(statement['isTrue'] as bool), statement, Colors.red)
                : FilledButton(
                    onPressed: () => _answer(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('Неверно'),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultButton(bool selected, Map<String, dynamic> statement, Color color) {
    final isCorrect = selected == (statement['isTrue'] as bool);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: color,
        ),
      ),
    );
  }

  bool get isCompleted => _answers.length > _currentIndex;
}
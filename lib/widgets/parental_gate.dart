import 'dart:math';
import 'package:flutter/material.dart';

/// Parental Gate - проверка для доступа к родительским функциям
/// Защищает детей от случайного доступа к настройкам оплаты
class ParentalGate extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPassed;
  final String title;
  final String description;

  const ParentalGate({
    super.key,
    required this.child,
    this.onPassed,
    this.title = 'Доступ для родителей',
    this.description = 'Решите пример, чтобы подтвердить, что вы взрослый',
  });

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  final _answerController = TextEditingController();
  int _num1 = 0;
  int _num2 = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    final random = Random();
    _num1 = random.nextInt(10) + 1;
    _num2 = random.nextInt(10) + 1;
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _num1 + _num2) {
      widget.onPassed?.call();
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = 'Неверный ответ. Попробуйте ещё раз.';
        _answerController.clear();
        _generateProblem();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_num1 + $_num2 = ?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: InputDecoration(
                hintText: 'Введите ответ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _checkAnswer,
                    child: const Text('Проверить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}

/// Функция для показа Parental Gate
Future<bool> showParentalGate(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ParentalGate(
      child: Container(),
      onPassed: () {
        Navigator.of(context).pop(true);
      },
    ),
  );
  return result ?? false;
}

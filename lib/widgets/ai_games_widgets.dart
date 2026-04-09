import 'dart:math';
import 'package:flutter/material.dart';
import '../data/services/gamification_service.dart';
import '../data/services/gamification_service.dart' show XpSource;

class NumberGuessGame extends StatefulWidget {
  const NumberGuessGame({super.key});

  @override
  State<NumberGuessGame> createState() => _NumberGuessGameState();
}

class _NumberGuessGameState extends State<NumberGuessGame> {
  final _random = Random();
  late int _targetNumber;
  int _attempts = 0;
  int? _guess;
  String _message = 'Угадай число от 1 до 100!';
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _targetNumber = _random.nextInt(100) + 1;
  }

  void _makeGuess(int guess) {
    setState(() {
      _guess = guess;
      _attempts++;
      if (guess == _targetNumber) {
        _won = true;
        _message = 'Поздравляю! Ты угадал за $_attempts попыток! 🎉';
        GamificationService.addXp(XpSource.taskComplete);
      } else if (guess < _targetNumber) {
        _message = 'Моё число больше! Попробуй ещё раз.';
      } else {
        _message = 'Моё число меньше! Попробуй ещё раз.';
      }
    });
  }

  void _reset() {
    setState(() {
      _targetNumber = _random.nextInt(100) + 1;
      _attempts = 0;
      _guess = null;
      _message = 'Новая игра! Угадай число от 1 до 100!';
      _won = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.psychology, size: 40, color: Colors.purple),
            const SizedBox(height: 12),
            const Text('Угадай число',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (!_won)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(10, (i) => i * 10 + 1)
                    .map((n) => FilledButton.tonal(
                          onPressed: () => _makeGuess(n),
                          child: Text('$n'),
                        ))
                    .toList(),
              ),
            if (_won)
              Column(
                children: [
                  const Icon(Icons.celebration, size: 40, color: Colors.amber),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Играть снова'),
                  ),
                ],
              ),
            Text('Попыток: $_attempts'),
          ],
        ),
      ),
    );
  }
}

class TrainingNeuralNetworkGame extends StatefulWidget {
  const TrainingNeuralNetworkGame({super.key});

  @override
  State<TrainingNeuralNetworkGame> createState() =>
      _TrainingNeuralNetworkGameState();
}

class _TrainingNeuralNetworkGameState extends State<TrainingNeuralNetworkGame> {
  final _random = Random();
  List<int> _trainingData = [];
  int _learningProgress = 0;
  bool _trained = false;
  String _status = 'Добавь примеры для обучения!';

  final List<String> _positiveExamples = [
    '🐱 Кот',
    '🐕 Собака',
    '🦊 Лиса',
    '🐰 Зайка'
  ];
  final List<String> _negativeExamples = [
    '🚗 Маши��а',
    '🏠 Дом',
    '🌳 Дерево',
    '📺 Телевизор'
  ];

  void _addExample(bool isPositive) {
    setState(() {
      if (isPositive) {
        _trainingData.add(1);
        _status = 'Добавлен положительный пример!';
      } else {
        _trainingData.add(0);
        _status = 'Добавлен отрицательный пример!';
      }
      if (_trainingData.length >= 4 && !_trained) {
        _train();
      }
    });
  }

  void _train() async {
    setState(() {
      _status = 'Обучение нейросети...';
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _trained = true;
      _learningProgress = 100;
      _status = 'Нейросеть обучена! Теперь она умеет отличать животных! 🎉';
    });
  }

  void _test() {
    final testInput = _random.nextBool();
    setState(() {
      if (testInput) {
        _status = 'Нейросеть видит: Это животное! (верно) ✓';
        GamificationService.addXp(XpSource.taskComplete);
      } else {
        _status = 'Нейросеть говорит: Это не животное! (верно) ✓';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.hub, size: 40, color: Colors.blue),
            const SizedBox(height: 12),
            const Text('Обучи нейросеть',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (!_trained) ...[
              const Text('Добавь примеры:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _addExample(true),
                    icon: const Icon(Icons.pets),
                    label: const Text('Животное'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _addExample(false),
                    icon: const Icon(Icons.not_interested),
                    label: const Text('Не животное'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Примеров: ${_trainingData.length}/4'),
              if (_trainingData.length >= 2)
                LinearProgressIndicator(value: _trainingData.length / 4),
            ],
            if (_trained) ...[
              const Icon(Icons.check_circle, size: 40, color: Colors.green),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _test,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Проверить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImageClassifierGame extends StatefulWidget {
  const ImageClassifierGame({super.key});

  @override
  State<ImageClassifierGame> createState() => _ImageClassifierGameState();
}

class _ImageClassifierGameState extends State<ImageClassifierGame> {
  final _random = Random();
  String _currentImage = '❓';
  String _prediction = '';
  String _status = 'Что изображено на картинке?';
  int _score = 0;

  final List<Map<String, String>> _images = [
    {'emoji': '🐱', 'label': 'Кошка'},
    {'emoji': '🐕', 'label': 'Собака'},
    {'emoji': '🚗', 'label': 'Машина'},
    {'emoji': '🍎', 'label': 'Яблоко'},
    {'emoji': '🌳', 'label': 'Дерево'},
    {'emoji': '📱', 'label': 'Телефон'},
  ];

  void _newImage() {
    setState(() {
      final idx = _random.nextInt(_images.length);
      _currentImage = _images[idx]['emoji']!;
      _prediction = '';
      _status = 'Что изображено на картинке?';
    });
  }

  void _predict(String label) {
    setState(() {
      _prediction = label;
      if (label ==
          _images.firstWhere((e) => e['emoji'] == _currentImage)['label']) {
        _status = 'Верно! Это $label ✓';
        _score++;
      } else {
        _status = 'Неверно! Попробуй ещё!';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _newImage();
  }

  @override
  Widget build(BuildContext context) {
    final labels = _images.map((e) => e['label']!).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.image, size: 40, color: Colors.orange),
            const SizedBox(height: 12),
            const Text('Классификатор изображений',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(_currentImage, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: labels
                  .map((l) => ChoiceChip(
                        label: Text(l),
                        selected: false,
                        onSelected: _prediction.isEmpty
                            ? (selected) => _predict(l)
                            : null,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Счёт: $_score'),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _newImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PatternRecognitionGame extends StatefulWidget {
  const PatternRecognitionGame({super.key});

  @override
  State<PatternRecognitionGame> createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  final _random = Random();
  List<int> _sequence = [];
  List<int> _userInput = [];
  int _level = 1;
  String _status = 'Запомни последовательность!';
  bool _playing = false;
  int _score = 0;

  void _startGame() {
    setState(() {
      _sequence = List.generate(_level, (_) => _random.nextInt(4));
      _userInput = [];
      _status = 'Запомни последовательность!';
    });
    Future.delayed(Duration(milliseconds: 500 * _level), () {
      if (mounted) {
        setState(() {
          _playing = true;
          _status = 'Повтори последовательность!';
        });
      }
    });
  }

  void _tap(int i) {
    if (!_playing) return;
    setState(() {
      _userInput.add(i);
      if (_userInput.last != _sequence[_userInput.length - 1]) {
        _status = 'Ошибка! Игра окончена.';
        _playing = false;
      } else if (_userInput.length == _sequence.length) {
        _score++;
        _level++;
        _status = 'Верно! Переходим к уровню $_level';
        _playing = false;
        Future.delayed(const Duration(seconds: 1), _startGame);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), _startGame);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.grid_4x4, size: 40, color: Colors.teal),
            const SizedBox(height: 12),
            const Text('Найди паттерн',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Уровень: $_level'),
            Text(_status),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(4, (i) {
                final isActive = _playing &&
                    _userInput.length < _sequence.length &&
                    _sequence.length > _userInput.length &&
                    i == _sequence[_userInput.length];
                return InkWell(
                  onTap: () => _tap(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        ['🔴', '🔵', '🟢', '🟡'][i],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text('Счёт: $_score'),
          ],
        ),
      ),
    );
  }
}

class AIGamesHub extends StatelessWidget {
  const AIGamesHub({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                'Игры с ИИ 🤖',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Играй и учись! Изучай искусственный интеллект.'),
          const SizedBox(height: 16),
          const NumberGuessGame(),
          const SizedBox(height: 12),
          const TrainingNeuralNetworkGame(),
          const SizedBox(height: 12),
          const ImageClassifierGame(),
          const SizedBox(height: 12),
          const PatternRecognitionGame(),
        ],
      ),
    );
  }
}

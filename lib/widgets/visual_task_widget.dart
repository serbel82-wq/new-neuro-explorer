import 'package:flutter/material.dart';

class VisualTaskWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<TaskItem> items;
  final Color color;
  final Function(int)? onComplete;

  const VisualTaskWidget({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.color,
    this.onComplete,
  });

  @override
  State<VisualTaskWidget> createState() => _VisualTaskWidgetState();
}

class _VisualTaskWidgetState extends State<VisualTaskWidget> {
  final Map<int, String> _answers = {};
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _saveAnswer(int index, String answer) {
    setState(() {
      _answers[index] = answer;
    });
  }

  bool _canProceed(int page) {
    if (widget.items[page].required) {
      return _answers.containsKey(page) && _answers[page]!.isNotEmpty;
    }
    return true;
  }

  void _nextPage() {
    if (_canProceed(_currentPage) && _currentPage < widget.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final filledCount = _answers.length;
      final score = (filledCount / widget.items.length * 100).round();
      widget.onComplete?.call(score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.2),
                widget.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.brush, color: widget.color),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / widget.items.length,
            backgroundColor: widget.color.withOpacity(0.2),
            color: widget.color,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _buildTaskItem(item, index);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_currentPage > 0)
              TextButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Назад'),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _canProceed(_currentPage) ? _nextPage : null,
              icon: Icon(
                _currentPage < widget.items.length - 1 
                  ? Icons.arrow_forward 
                  : Icons.check,
              ),
              label: Text(
                _currentPage < widget.items.length - 1 
                  ? 'Далее' 
                  : 'Завершить',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskItem(TaskItem item, int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          switch (item.type) {
            TaskItemType.text => _buildTextInput(item, index),
            TaskItemType.emoji => _buildEmojiPicker(item, index),
            TaskItemType.slider => _buildSlider(item, index),
            TaskItemType.matching => _buildMatching(item, index),
          },
        ],
      ),
    );
  }

  Widget _buildTextInput(TaskItem item, int index) {
    return Column(
      children: [
        TextField(
          maxLines: item.maxLines ?? 3,
          onChanged: (value) => _saveAnswer(index, value),
          decoration: InputDecoration(
            hintText: item.placeholder ?? 'Введи свой ответ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
        ),
        if (item.example != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, size: 18, color: widget.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Пример: ${item.example}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmojiPicker(TaskItem item, int index) {
    final emojis = ['😀', '🤔', '😎', '🙄', '😰', '🤩'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(emojis.length, (i) {
        final emoji = emojis[i];
        final isSelected = _answers[index] == emoji;
        return GestureDetector(
          onTap: () => _saveAnswer(index, emoji),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected 
                  ? widget.color.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? widget.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSlider(TaskItem item, int index) {
    final value = double.tryParse(_answers[index] ?? '5') ?? 5;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.minLabel ?? '1'),
            Text(
              value.round().toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
            Text(item.maxLabel ?? '10'),
          ],
        ),
        Slider(
          value: value,
          min: item.min?.toDouble() ?? 1,
          max: item.max?.toDouble() ?? 10,
          divisions: ((item.max ?? 10) - (item.min ?? 1)),
          activeColor: widget.color,
          onChanged: (v) => _saveAnswer(index, v.round().toString()),
        ),
      ],
    );
  }

  Widget _buildMatching(TaskItem item, int index) {
    return Column(
      children: item.options!.asMap().entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _answers[index] == entry.value
                ? widget.color.withOpacity(0.2)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _answers[index] == entry.value 
                  ? Icons.check_circle 
                  : Icons.circle_outlined,
                color: _answers[index] == entry.value ? widget.color : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(entry.value)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class TaskItem {
  final String title;
  final String instruction;
  final TaskItemType type;
  final bool required;
  final String? placeholder;
  final String? example;
  final List<String>? options;
  final int? min;
  final int? max;
  final String? minLabel;
  final String? maxLabel;
  final int? maxLines;

  const TaskItem({
    required this.title,
    required this.instruction,
    required this.type,
    this.required = true,
    this.placeholder,
    this.example,
    this.options,
    this.min,
    this.max,
    this.minLabel,
    this.maxLabel,
    this.maxLines,
  });
}

enum TaskItemType {
  text,
  emoji,
  slider,
  matching,
}
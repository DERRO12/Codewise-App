import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/learning_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// What the lesson player should do after the exercise closes.
enum ExerciseResult { nextLesson, myLearning, stay }

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.courseId,
    required this.lessonIndex,
  });

  final String courseId;
  final int lessonIndex;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _typed = TextEditingController();
  int _step = 0;
  String? _selected;
  bool _checked = false;
  bool _lastCorrect = false;
  int _correct = 0;
  bool _finished = false;
  bool _saving = false;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  String get _answer => _selected ?? _typed.text;

  void _check(Exercise exercise) {
    FocusScope.of(context).unfocus();
    final right = exercise.isCorrect(_answer);
    setState(() {
      _checked = true;
      _lastCorrect = right;
      if (right) _correct++;
    });
  }

  Future<void> _continue(Course course, Lesson lesson) async {
    if (_step < lesson.exercises.length - 1) {
      setState(() {
        _step++;
        _selected = null;
        _typed.clear();
        _checked = false;
      });
      return;
    }
    setState(() => _saving = true);
    await context.read<LearningController>().completeLesson(
          course,
          widget.lessonIndex,
          correct: _correct,
          total: lesson.exercises.length,
        );
    if (mounted) {
      setState(() {
        _saving = false;
        _finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = context.read<LearningController>().courseById(widget.courseId)!;
    final lesson = course.lessons[widget.lessonIndex];
    final total = lesson.exercises.length;

    if (_finished) {
      return _SummaryView(
        correct: _correct,
        total: total,
        hasNextLesson: widget.lessonIndex < course.lessons.length - 1,
      );
    }

    final exercise = lesson.exercises[_step];
    final canCheck = exercise.hasOptions
        ? _selected != null
        : _typed.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close exercise',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, ExerciseResult.stay),
        ),
        title: const Text('Exercise'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_step + 1} / $total',
                  style: const TextStyle(color: AppColors.grey)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          YellowProgressBar(value: (_step + (_checked ? 1 : 0)) / total),
          const SizedBox(height: 18),
          Text(exercise.type.label.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(exercise.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (exercise.code != null) ...[
            const SizedBox(height: 12),
            CodeBlock(exercise.code!),
          ],
          const SizedBox(height: 14),
          if (exercise.hasOptions)
            for (final option in exercise.options)
              _OptionTile(
                text: option,
                selected: _selected == option,
                checked: _checked,
                isAnswer: exercise.isCorrect(option),
                onTap: _checked ? null : () => setState(() => _selected = option),
              )
          else
            TextField(
              controller: _typed,
              enabled: !_checked,
              autocorrect: false,
              enableSuggestions: false,
              style: codeTextStyle.copyWith(fontSize: 15),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (canCheck && !_checked) _check(exercise);
              },
              decoration: const InputDecoration(
                hintText: 'Type the missing code',
                prefixIcon: Icon(Icons.code),
              ),
            ),
          if (_checked) ...[
            const SizedBox(height: 6),
            _FeedbackCard(
              correct: _lastCorrect,
              answer: exercise.answer,
              explanation: exercise.explanation,
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _saving
                ? null
                : _checked
                    ? () => _continue(course, lesson)
                    : canCheck
                        ? () => _check(exercise)
                        : null,
            child: _saving
                ? const ButtonSpinner()
                : Text(_checked
                    ? (_step == total - 1 ? 'FINISH' : 'CONTINUE')
                    : 'CHECK ANSWER'),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.checked,
    required this.isAnswer,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool checked;
  final bool isAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    var borderColor = AppColors.border;
    Color fill = Colors.transparent;
    var icon = Icons.radio_button_unchecked;
    var iconColor = AppColors.grey;

    if (checked && isAnswer) {
      borderColor = AppColors.green;
      fill = AppColors.greenBg;
      icon = Icons.check_circle;
      iconColor = AppColors.green;
    } else if (checked && selected) {
      borderColor = AppColors.red;
      fill = AppColors.redBg;
      icon = Icons.cancel;
      iconColor = AppColors.red;
    } else if (selected) {
      borderColor = AppColors.yellow;
      icon = Icons.radio_button_checked;
      iconColor = AppColors.yellow;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text,
                      style: codeTextStyle.copyWith(
                          color: AppColors.white, fontSize: 14.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.correct,
    required this.answer,
    required this.explanation,
  });

  final bool correct;
  final String answer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? AppColors.greenBg : AppColors.redBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check : Icons.close, color: color, size: 20),
              const SizedBox(width: 6),
              Text(correct ? 'Correct!' : 'Not quite',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          if (!correct)
            Text('Answer: $answer',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(explanation, style: const TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.correct,
    required this.total,
    required this.hasNextLesson,
  });

  final int correct;
  final int total;
  final bool hasNextLesson;

  @override
  Widget build(BuildContext context) {
    final perfect = correct == total;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(perfect ? Icons.emoji_events_rounded : Icons.task_alt_rounded,
                  size: 96, color: AppColors.yellow),
              const SizedBox(height: 18),
              const Text('Lesson complete!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'You got $correct of $total right.${perfect ? ' Perfect score!' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey, fontSize: 16),
              ),
              const Spacer(),
              if (hasNextLesson) ...[
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, ExerciseResult.nextLesson),
                  child: const Text('NEXT LESSON'),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => Navigator.pop(context, ExerciseResult.myLearning),
                child: const Text('Go to My Learning'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context, ExerciseResult.stay),
                child: const Text('Back to lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../routes.dart';
import '../state/home_tab_controller.dart';
import '../state/learning_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'exercise_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonIndex,
  });

  final String courseId;
  final int lessonIndex;

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen>
    with SingleTickerProviderStateMixin {
  // Placeholder playback: the real video player arrives with the backend.
  late final AnimationController _video = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() {});
    });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final learning = context.read<LearningController>();
      final course = learning.courseById(widget.courseId);
      if (course != null) learning.openLesson(course, widget.lessonIndex);
    });
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_video.isAnimating) {
        _video.stop();
      } else {
        if (_video.isCompleted) _video.reset();
        _video.forward();
      }
    });
  }

  void _goToLesson(int index) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) =>
          LessonPlayerScreen(courseId: widget.courseId, lessonIndex: index),
    ));
  }

  Future<void> _startExercise(Course course) async {
    _video.stop();
    final result = await Navigator.of(context).push<ExerciseResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ExerciseScreen(
            courseId: course.id, lessonIndex: widget.lessonIndex),
      ),
    );
    if (!mounted || result == null) return;
    switch (result) {
      case ExerciseResult.nextLesson:
        _goToLesson(widget.lessonIndex + 1);
      case ExerciseResult.myLearning:
        context.read<HomeTabController>().go(HomeTabController.myLearning);
        Navigator.of(context)
            .popUntil((route) => route.settings.name == Routes.home);
      case ExerciseResult.stay:
        setState(() {});
    }
  }

  Future<void> _markComplete(Course course) async {
    await context
        .read<LearningController>()
        .completeLesson(course, widget.lessonIndex, correct: 0, total: 0);
    if (mounted) showSnack(context, 'Lesson marked as complete.');
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningController>();
    final course = learning.courseById(widget.courseId);
    if (course == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Lesson not found.')));
    }
    final lesson = course.lessons[widget.lessonIndex];
    final total = course.lessons.length;
    final hasNext = widget.lessonIndex < total - 1;
    final nextUnlocked =
        hasNext && learning.isLessonUnlocked(course, widget.lessonIndex + 1);
    final completed = learning.isLessonCompleted(course, widget.lessonIndex);

    return Scaffold(
      appBar: AppBar(title: Text('Lesson ${widget.lessonIndex + 1} of $total')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _VideoBox(
            controller: _video,
            minutes: lesson.minutes,
            onTap: _togglePlay,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(lesson.title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                    if (completed)
                      const Chip(
                        avatar: Icon(Icons.check, size: 16, color: AppColors.green),
                        label: Text('Done'),
                        side: BorderSide(color: AppColors.green),
                        backgroundColor: AppColors.greenBg,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(course.title,
                    style: const TextStyle(color: AppColors.yellow, fontSize: 13)),
                const SizedBox(height: 12),
                Text(lesson.body,
                    style: const TextStyle(color: AppColors.grey, height: 1.5)),
                const SizedBox(height: 14),
                CodeBlock(lesson.code),
                if (lesson.tip != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 18, color: AppColors.yellow),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(lesson.tip!,
                            style: const TextStyle(
                                color: AppColors.grey, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                if (lesson.exercises.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _startExercise(course),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(completed ? 'PRACTISE AGAIN' : 'START EXERCISE'),
                  )
                else
                  ElevatedButton(
                    onPressed: completed ? null : () => _markComplete(course),
                    child: const Text('MARK COMPLETE'),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: widget.lessonIndex > 0
                          ? () => _goToLesson(widget.lessonIndex - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Previous'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.grey),
                    ),
                    if (hasNext)
                      TextButton.icon(
                        onPressed: () {
                          if (nextUnlocked) {
                            _goToLesson(widget.lessonIndex + 1);
                          } else {
                            showSnack(context,
                                'Finish this lesson\'s exercise to unlock the next one.');
                          }
                        },
                        iconAlignment: IconAlignment.end,
                        icon: Icon(nextUnlocked ? Icons.arrow_forward : Icons.lock_outline,
                            size: 16),
                        label: const Text('Next lesson'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoBox extends StatelessWidget {
  const _VideoBox({
    required this.controller,
    required this.minutes,
    required this.onTap,
  });

  final AnimationController controller;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final playing = controller.isAnimating;
        return Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Container(
                height: 190,
                width: double.infinity,
                color: AppColors.cardLight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 72,
                      color: AppColors.yellow,
                    ),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: Text(
                        playing
                            ? 'Playing preview…'
                            : 'VIDEO · $minutes min',
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LinearProgressIndicator(
              value: controller.value,
              minHeight: 4,
              backgroundColor: const Color(0xFF555555),
              color: AppColors.yellow,
            ),
          ],
        );
      },
    );
  }
}

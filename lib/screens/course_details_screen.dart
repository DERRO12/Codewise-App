import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/learning_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'lesson_player_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  void _openLesson(BuildContext context, Course course, int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LessonPlayerScreen(courseId: course.id, lessonIndex: index),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningController>();
    final course = learning.courseById(courseId);
    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course details')),
        body: const Center(child: Text('Course not found.')),
      );
    }

    final enrolled = learning.isEnrolled(course.id);
    final percent = learning.percentComplete(course);
    final current = learning.progressFor(course.id)?.currentLessonIndex ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Course details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Banner(course: course),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${course.summary} · ${course.hours} hours · ',
                      style: const TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                    RatingText(rating: course.rating),
                  ],
                ),
                const SizedBox(height: 12),
                Text(course.description,
                    style: const TextStyle(color: AppColors.grey, height: 1.45)),
                if (enrolled) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: YellowProgressBar(value: percent)),
                      const SizedBox(width: 10),
                      Text('${(percent * 100).round()}%',
                          style: const TextStyle(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                const SectionTitle('Lessons'),
                const SizedBox(height: 10),
                Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < course.lessons.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _LessonRow(
                          index: i,
                          lesson: course.lessons[i],
                          completed: learning.isLessonCompleted(course, i),
                          unlocked: learning.isLessonUnlocked(course, i),
                          onTap: () {
                            if (learning.isLessonUnlocked(course, i)) {
                              _openLesson(context, course, i);
                            } else {
                              showSnack(
                                  context,
                                  enrolled
                                      ? 'Finish the previous lesson to unlock this one.'
                                      : 'Enrol to unlock all lessons.');
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton(
          onPressed: () async {
            if (!enrolled) {
              await learning.enrol(course);
              if (!context.mounted) return;
              showSnack(context, "You're enrolled in ${course.title}!");
              _openLesson(context, course, 0);
            } else {
              _openLesson(context, course, percent >= 1 ? 0 : current);
            }
          },
          child: Text(!enrolled
              ? 'ENROL NOW'
              : percent >= 1
                  ? 'REVIEW COURSE'
                  : 'CONTINUE LEARNING'),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A3A3A), Color(0xFF1C1C1C)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -30,
            child: Text(
              '{ }',
              style: TextStyle(
                fontSize: 150,
                fontWeight: FontWeight.w900,
                color: AppColors.yellow.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LanguageBadge(language: course.language, size: 72),
                const SizedBox(height: 10),
                Text(course.language.toUpperCase(),
                    style: const TextStyle(
                        letterSpacing: 4, color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.index,
    required this.lesson,
    required this.completed,
    required this.unlocked,
    required this.onTap,
  });

  final int index;
  final Lesson lesson;
  final bool completed;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = completed
        ? const Icon(Icons.check_circle_rounded, color: AppColors.green)
        : unlocked
            ? const Icon(Icons.play_arrow_rounded, color: AppColors.yellow)
            : const Icon(Icons.lock_outline_rounded, color: AppColors.grey);
    return ListTile(
      onTap: onTap,
      minTileHeight: 52,
      leading: icon,
      title: Text(
        '${index + 1}. ${lesson.title}',
        style: TextStyle(
          fontSize: 14.5,
          color: unlocked ? AppColors.white : AppColors.grey,
        ),
      ),
      trailing: Text('${lesson.minutes} min',
          style: const TextStyle(color: AppColors.grey, fontSize: 12)),
    );
  }
}

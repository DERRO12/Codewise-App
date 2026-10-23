import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/home_tab_controller.dart';
import '../state/learning_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'course_details_screen.dart';
import 'lesson_player_screen.dart';

class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningController>();
    final resume = learning.continueLearning;
    final enrolled = learning.enrolledCourses;
    final score = learning.quizScorePercent;

    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              _StatCard(value: '🔥 ${learning.streakDays}', label: 'day streak'),
              const SizedBox(width: 10),
              _StatCard(value: '${learning.lessonsDone}', label: 'lessons done'),
              const SizedBox(width: 10),
              _StatCard(value: score == null ? '–' : '$score%', label: 'quiz score'),
            ],
          ),
          const SizedBox(height: 16),
          if (resume != null)
            _YellowCard(
              eyebrow: 'CONTINUE LEARNING',
              title:
                  '${resume.course.language} · Lesson ${resume.lessonIndex + 1}: ${resume.course.lessons[resume.lessonIndex].title}',
              action: 'Resume',
              icon: Icons.play_arrow_rounded,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LessonPlayerScreen(
                    courseId: resume.course.id, lessonIndex: resume.lessonIndex),
              )),
            )
          else
            _YellowCard(
              eyebrow: enrolled.isEmpty ? 'GET STARTED' : 'ALL CAUGHT UP',
              title: enrolled.isEmpty
                  ? 'Enrol in your first coding course'
                  : 'You finished every course you enrolled in!',
              action: 'Browse courses',
              icon: Icons.search,
              onTap: () =>
                  context.read<HomeTabController>().go(HomeTabController.home),
            ),
          const SizedBox(height: 22),
          const SectionTitle('My courses'),
          const SizedBox(height: 10),
          if (enrolled.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "You haven't enrolled in any courses yet.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            for (final course in enrolled)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CourseDetailsScreen(courseId: course.id),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(course.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ),
                              Text(
                                '${(learning.percentComplete(course) * 100).round()}%',
                                style: const TextStyle(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          YellowProgressBar(value: learning.percentComplete(course)),
                          const SizedBox(height: 8),
                          Text(
                            '${learning.completedCount(course)} of ${course.lessons.length} lessons',
                            style: const TextStyle(
                                color: AppColors.grey, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.yellow,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _YellowCard extends StatelessWidget {
  const _YellowCard({
    required this.eyebrow,
    required this.title,
    required this.action,
    required this.icon,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String action;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: AppColors.yellow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            iconAlignment: IconAlignment.end,
            icon: Icon(icon, size: 18),
            label: Text(action,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

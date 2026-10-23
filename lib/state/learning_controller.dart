import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../models/course.dart';
import '../models/progress.dart';

/// Course catalogue plus the signed-in learner's enrolments and results.
class LearningController extends ChangeNotifier {
  LearningController(this._courseRepo, this._progressRepo);

  final CourseRepository _courseRepo;
  final ProgressRepository _progressRepo;

  List<Course> _courses = [];
  bool _loading = false;
  String? _error;
  String? _userId;
  LearningProgress _progress = LearningProgress();

  List<Course> get courses => _courses;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadCourses() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _courses = await _courseRepo.fetchCourses();
    } catch (e) {
      _error = 'Could not load courses. Pull down to try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Called whenever the signed-in user changes.
  void setUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _progress = LearningProgress();
    if (userId != null) _loadProgress(userId);
  }

  Future<void> _loadProgress(String userId) async {
    final loaded = await _progressRepo.load(userId);
    if (userId != _userId) return;
    _progress = loaded;
    notifyListeners();
  }

  Future<void> _save() async {
    notifyListeners();
    final id = _userId;
    if (id != null) await _progressRepo.save(id, _progress);
  }

  Course? courseById(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ---- Enrolment and lessons ----

  bool isEnrolled(String courseId) => _progress.courses.containsKey(courseId);

  CourseProgress? progressFor(String courseId) => _progress.courses[courseId];

  List<Course> get enrolledCourses =>
      _courses.where((c) => isEnrolled(c.id)).toList();

  Future<void> enrol(Course course) async {
    _progress.courses.putIfAbsent(
        course.id, () => CourseProgress(courseId: course.id));
    _progress.lastCourseId = course.id;
    await _save();
  }

  bool isLessonCompleted(Course course, int index) =>
      progressFor(course.id)?.completedLessonIds.contains(course.lessons[index].id) ??
      false;

  /// Lesson 1 is always open as a preview; after that a lesson unlocks once the
  /// previous one is completed.
  bool isLessonUnlocked(Course course, int index) {
    if (index == 0) return true;
    if (!isEnrolled(course.id)) return false;
    return isLessonCompleted(course, index - 1) || isLessonCompleted(course, index);
  }

  Future<void> openLesson(Course course, int index) async {
    final cp = progressFor(course.id);
    if (cp == null) return;
    cp.currentLessonIndex = index;
    _progress.lastCourseId = course.id;
    await _save();
  }

  Future<void> completeLesson(
    Course course,
    int index, {
    required int correct,
    required int total,
  }) async {
    final cp = _progress.courses
        .putIfAbsent(course.id, () => CourseProgress(courseId: course.id));
    final firstTime = cp.completedLessonIds.add(course.lessons[index].id);
    if (firstTime) {
      cp.correctAnswers += correct;
      cp.totalAnswers += total;
    }
    cp.currentLessonIndex = min(index + 1, course.lessons.length - 1);
    _progress.lastCourseId = course.id;
    _markActiveToday();
    await _save();
  }

  Future<void> resetProgress() async {
    _progress = LearningProgress();
    await _save();
  }

  // ---- Dashboard figures ----

  double percentComplete(Course course) {
    final cp = progressFor(course.id);
    if (cp == null || course.lessons.isEmpty) return 0;
    return cp.completedLessonIds.length / course.lessons.length;
  }

  int completedCount(Course course) =>
      progressFor(course.id)?.completedLessonIds.length ?? 0;

  int get lessonsDone => _progress.courses.values
      .fold(0, (sum, cp) => sum + cp.completedLessonIds.length);

  /// Overall quiz score as a percentage, or null before any answers.
  int? get quizScorePercent {
    var correct = 0, total = 0;
    for (final cp in _progress.courses.values) {
      correct += cp.correctAnswers;
      total += cp.totalAnswers;
    }
    return total == 0 ? null : (correct * 100 / total).round();
  }

  /// The streak only counts if the learner was active today or yesterday.
  int get streakDays {
    final last = _progress.lastActiveDay;
    if (last == null) return 0;
    final gap = _today().difference(last).inDays;
    return gap <= 1 ? _progress.streakDays : 0;
  }

  /// Where "Continue learning" should take the learner.
  ({Course course, int lessonIndex})? get continueLearning {
    final candidates = <Course>[
      if (_progress.lastCourseId != null) ?courseById(_progress.lastCourseId!),
      ...enrolledCourses,
    ];
    for (final course in candidates) {
      if (!isEnrolled(course.id) || percentComplete(course) >= 1) continue;
      final index = progressFor(course.id)!
          .currentLessonIndex
          .clamp(0, course.lessons.length - 1);
      return (course: course, lessonIndex: index);
    }
    return null;
  }

  List<Course> get completedCourses =>
      enrolledCourses.where((c) => percentComplete(c) >= 1).toList();

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _markActiveToday() {
    final today = _today();
    final last = _progress.lastActiveDay;
    if (last != null && last == today) return;
    final continues = last != null && today.difference(last).inDays == 1;
    _progress.streakDays = continues ? _progress.streakDays + 1 : 1;
    _progress.lastActiveDay = today;
  }
}

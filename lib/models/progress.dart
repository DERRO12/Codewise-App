/// Progress of one learner in one course.
class CourseProgress {
  CourseProgress({
    required this.courseId,
    Set<String>? completedLessonIds,
    this.currentLessonIndex = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
  }) : completedLessonIds = completedLessonIds ?? <String>{};

  final String courseId;
  final Set<String> completedLessonIds;
  int currentLessonIndex;
  int correctAnswers;
  int totalAnswers;

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
        courseId: json['courseId'] as String,
        completedLessonIds:
            (json['completedLessonIds'] as List? ?? []).cast<String>().toSet(),
        currentLessonIndex: json['currentLessonIndex'] as int? ?? 0,
        correctAnswers: json['correctAnswers'] as int? ?? 0,
        totalAnswers: json['totalAnswers'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'completedLessonIds': completedLessonIds.toList(),
        'currentLessonIndex': currentLessonIndex,
        'correctAnswers': correctAnswers,
        'totalAnswers': totalAnswers,
      };
}

/// Everything the Progress Dashboard needs for one learner.
class LearningProgress {
  LearningProgress({
    Map<String, CourseProgress>? courses,
    this.streakDays = 0,
    this.lastActiveDay,
    this.lastCourseId,
  }) : courses = courses ?? {};

  final Map<String, CourseProgress> courses;
  int streakDays;
  DateTime? lastActiveDay;
  String? lastCourseId;

  factory LearningProgress.fromJson(Map<String, dynamic> json) =>
      LearningProgress(
        courses: (json['courses'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, CourseProgress.fromJson(v as Map<String, dynamic>)),
        ),
        streakDays: json['streakDays'] as int? ?? 0,
        lastActiveDay: json['lastActiveDay'] == null
            ? null
            : DateTime.parse(json['lastActiveDay'] as String),
        lastCourseId: json['lastCourseId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'courses': courses.map((k, v) => MapEntry(k, v.toJson())),
        'streakDays': streakDays,
        'lastActiveDay': lastActiveDay?.toIso8601String(),
        'lastCourseId': lastCourseId,
      };
}

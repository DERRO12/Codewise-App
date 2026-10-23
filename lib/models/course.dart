enum CourseLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const CourseLevel(this.label);
  final String label;

  static CourseLevel parse(String value) => CourseLevel.values.firstWhere(
        (l) => l.name == value.toLowerCase(),
        orElse: () => CourseLevel.beginner,
      );
}

enum ExerciseType {
  multipleChoice('Multiple choice'),
  fillInCode('Fill in the missing code'),
  predictOutput('Predict the output');

  const ExerciseType(this.label);
  final String label;
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.language,
    required this.level,
    required this.description,
    required this.rating,
    required this.hours,
    required this.lessons,
  });

  final String id;
  final String title;
  final String language;
  final CourseLevel level;
  final String description;
  final double rating;
  final int hours;
  final List<Lesson> lessons;

  String get summary => '${level.label} · ${lessons.length} lessons';

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'].toString(),
        title: json['title'] as String,
        language: json['language'] as String,
        level: CourseLevel.parse(json['level'] as String),
        description: json['description'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        hours: (json['hours'] as num?)?.toInt() ?? 0,
        lessons: (json['lessons'] as List? ?? [])
            .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
            .toList(),
      );
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.body,
    required this.code,
    this.tip,
    this.videoUrl,
    this.exercises = const [],
  });

  final String id;
  final String title;
  final int minutes;
  final String body;
  final String code;
  final String? tip;
  final String? videoUrl;
  final List<Exercise> exercises;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'].toString(),
        title: json['title'] as String,
        minutes: (json['minutes'] as num?)?.toInt() ?? 5,
        body: json['body'] as String? ?? '',
        code: json['code'] as String? ?? '',
        tip: json['tip'] as String?,
        videoUrl: json['video_url'] as String?,
        exercises: (json['exercises'] as List? ?? [])
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Exercise {
  const Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
    required this.explanation,
    this.code,
    this.options = const [],
  });

  final String id;
  final ExerciseType type;
  final String question;
  final String? code;
  final List<String> options;
  final String answer;
  final String explanation;

  bool get hasOptions => type != ExerciseType.fillInCode;

  bool isCorrect(String input) => _normalise(input) == _normalise(answer);

  static String _normalise(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'].toString(),
        type: ExerciseType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ExerciseType.multipleChoice,
        ),
        question: json['question'] as String,
        code: json['code'] as String?,
        options: (json['options'] as List? ?? []).cast<String>(),
        answer: json['answer'] as String,
        explanation: json['explanation'] as String? ?? '',
      );
}

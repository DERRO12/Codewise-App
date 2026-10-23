import 'package:code_wise_academy/app.dart';
import 'package:code_wise_academy/data/mock/mock_courses.dart';
import 'package:code_wise_academy/data/mock/mock_repositories.dart';
import 'package:code_wise_academy/models/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(CodeWiseApp(
    authRepository: MockAuthRepository(prefs),
    courseRepository: MockCourseRepository(),
    progressRepository: MockProgressRepository(prefs),
  ));
}

void main() {
  testWidgets('splash leads to login, demo login opens the catalog',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('ACADEMY'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
        find.byType(TextFormField).at(0), MockAuthRepository.demoEmail);
    await tester.enterText(
        find.byType(TextFormField).at(1), MockAuthRepository.demoPassword);
    await tester.tap(find.text('LOG IN'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('What will you code today?'), findsOneWidget);
    expect(find.text('Python for Beginners'), findsOneWidget);

    await tester.tap(find.text('My Learning'));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE LEARNING'), findsOneWidget);
  });

  test('every mock exercise has its answer among the options', () {
    for (final course in mockCourses) {
      for (final lesson in course.lessons) {
        expect(lesson.exercises, isNotEmpty, reason: lesson.id);
        for (final e in lesson.exercises) {
          if (e.type != ExerciseType.fillInCode) {
            expect(e.options, contains(e.answer), reason: e.id);
          }
        }
      }
    }
  });
}

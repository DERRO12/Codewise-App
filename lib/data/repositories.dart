import '../models/app_user.dart';
import '../models/course.dart';
import '../models/progress.dart';

/// Contracts the UI depends on. Phase 1 uses the mock implementations in
/// `data/mock/`; later an API implementation (Laravel backend) can be
/// dropped in by changing the wiring in `main.dart` only.

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// The signed-in user from a previous session, if any.
  Future<AppUser?> currentUser();

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> logIn({required String email, required String password});

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<AppUser> updateProfile(AppUser user);

  Future<void> logOut();
}

abstract class CourseRepository {
  Future<List<Course>> fetchCourses();
}

abstract class ProgressRepository {
  Future<LearningProgress> load(String userId);

  Future<void> save(String userId, LearningProgress progress);
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/progress.dart';
import '../repositories.dart';
import 'mock_courses.dart';

Future<void> _latency([int ms = 500]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

/// Accounts are kept on the device so the demo works offline.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;

  static const demoEmail = 'student@codewise.app';
  static const demoPassword = 'password123';
  static const _usersKey = 'mock.users';
  static const _sessionKey = 'mock.session';

  Map<String, dynamic> _users() {
    final raw = _prefs.getString(_usersKey);
    final users = raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    users.putIfAbsent(demoEmail, () => {
          'id': 'u_demo',
          'name': 'Student Name',
          'password': demoPassword,
        });
    return users;
  }

  Future<void> _saveUsers(Map<String, dynamic> users) =>
      _prefs.setString(_usersKey, jsonEncode(users));

  Future<AppUser> _startSession(AppUser user) async {
    await _prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<AppUser?> currentUser() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _latency();
    final key = email.trim().toLowerCase();
    final users = _users();
    if (users.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    users[key] = {'id': id, 'name': name.trim(), 'password': password};
    await _saveUsers(users);
    return _startSession(AppUser(id: id, name: name.trim(), email: key));
  }

  @override
  Future<AppUser> logIn({
    required String email,
    required String password,
  }) async {
    await _latency();
    final key = email.trim().toLowerCase();
    final record = _users()[key] as Map<String, dynamic>?;
    if (record == null || record['password'] != password) {
      throw const AuthException('Incorrect email or password.');
    }
    return _startSession(AppUser(
      id: record['id'] as String,
      name: record['name'] as String,
      email: key,
    ));
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await _latency(800);
    return _startSession(const AppUser(
      id: 'u_google_demo',
      name: 'Google Student',
      email: 'google.student@gmail.com',
    ));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _latency();
    if (!_users().containsKey(email.trim().toLowerCase())) {
      throw const AuthException('No account found for that email.');
    }
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _latency(300);
    final users = _users();
    final record = users[user.email] as Map<String, dynamic>?;
    if (record != null) {
      record['name'] = user.name;
      await _saveUsers(users);
    }
    return _startSession(user);
  }

  @override
  Future<void> logOut() => _prefs.remove(_sessionKey);
}

class MockCourseRepository implements CourseRepository {
  @override
  Future<List<Course>> fetchCourses() async {
    await _latency(400);
    return mockCourses;
  }
}

class MockProgressRepository implements ProgressRepository {
  MockProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  String _key(String userId) => 'mock.progress.$userId';

  @override
  Future<LearningProgress> load(String userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) {
      return userId == 'u_demo' ? demoProgress() : LearningProgress();
    }
    return LearningProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(String userId, LearningProgress progress) =>
      _prefs.setString(_key(userId), jsonEncode(progress.toJson()));
}

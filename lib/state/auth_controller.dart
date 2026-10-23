import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../models/app_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  AppUser? _user;
  bool _busy = false;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get busy => _busy;

  Future<void> restoreSession() async {
    _user = await _repo.currentUser();
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(() => _repo.signUp(name: name, email: email, password: password));

  Future<void> logIn({required String email, required String password}) =>
      _run(() => _repo.logIn(email: email, password: password));

  Future<void> signInWithGoogle() => _run(_repo.signInWithGoogle);

  Future<void> sendPasswordReset(String email) => _repo.sendPasswordReset(email);

  Future<void> updateName(String name) async {
    final current = _user;
    if (current == null) return;
    _user = await _repo.updateProfile(current.copyWith(name: name.trim()));
    notifyListeners();
  }

  Future<void> logOut() async {
    await _repo.logOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _run(Future<AppUser> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      _user = await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

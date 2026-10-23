import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/mock/mock_repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF111111),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF111111),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();

  // Phase 1: demo data stored on the device. Swap these for API-backed
  // repositories when the Laravel backend is ready.
  runApp(CodeWiseApp(
    authRepository: MockAuthRepository(prefs),
    courseRepository: MockCourseRepository(),
    progressRepository: MockProgressRepository(prefs),
  ));
}

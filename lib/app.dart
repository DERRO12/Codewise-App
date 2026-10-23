import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories.dart';
import 'routes.dart';
import 'screens/auth_screens.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'state/auth_controller.dart';
import 'state/home_tab_controller.dart';
import 'state/learning_controller.dart';
import 'theme/app_theme.dart';

class CodeWiseApp extends StatelessWidget {
  const CodeWiseApp({
    super.key,
    required this.authRepository,
    required this.courseRepository,
    required this.progressRepository,
  });

  final AuthRepository authRepository;
  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authRepository)),
        ChangeNotifierProvider(create: (_) => HomeTabController()),
        ChangeNotifierProxyProvider<AuthController, LearningController>(
          create: (_) =>
              LearningController(courseRepository, progressRepository)
                ..loadCourses(),
          update: (_, auth, learning) => learning!..setUser(auth.user?.id),
        ),
      ],
      child: MaterialApp(
        title: 'Code Wise Academy',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (_) => const SplashScreen(),
          Routes.login: (_) => const LoginScreen(),
          Routes.signUp: (_) => const SignUpScreen(),
          Routes.home: (_) => const HomeShell(),
        },
      ),
    );
  }
}

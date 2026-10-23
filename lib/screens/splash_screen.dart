import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1800);

  late final AnimationController _progress =
      AnimationController(vsync: this, duration: _duration)..forward();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final auth = context.read<AuthController>();
    await Future.wait([auth.restoreSession(), Future<void>.delayed(_duration)]);
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacementNamed(auth.isSignedIn ? Routes.home : Routes.login);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(size: 110),
            const SizedBox(height: 22),
            const Text.rich(
              TextSpan(children: [
                TextSpan(text: 'CODE '),
                TextSpan(
                    text: 'WISE', style: TextStyle(color: AppColors.yellow)),
              ]),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'ACADEMY',
              style: TextStyle(
                  fontSize: 15, letterSpacing: 8, color: AppColors.white),
            ),
            const SizedBox(height: 18),
            const Text('Learn to code, one lesson at a time',
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 40),
            SizedBox(
              width: 160,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, _) =>
                    YellowProgressBar(value: _progress.value, height: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

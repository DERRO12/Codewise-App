import 'package:flutter/material.dart';

/// Colour palette from the Code Wise Academy wireframes.
class AppColors {
  static const black = Color(0xFF111111);
  static const card = Color(0xFF2A2A2A);
  static const cardLight = Color(0xFF3A3A3A);
  static const border = Color(0xFF666666);
  static const yellow = Color(0xFFF5C518);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFFAAAAAA);
  static const green = Color(0xFF2ECC71);
  static const greenBg = Color(0xFF173D28);
  static const red = Color(0xFFE74C3C);
  static const redBg = Color(0xFF3D1A17);
  static const codeBg = Color(0xFF000000);
}

/// Monospace style used for code snippets.
const codeTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontFamilyFallback: ['RobotoMono', 'Courier New', 'Courier'],
  color: AppColors.yellow,
  fontSize: 13.5,
  height: 1.5,
);

ThemeData buildAppTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final radius10 = BorderRadius.circular(10);

  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: radius10,
        borderSide: BorderSide(color: color, width: 1.5),
      );

  return base.copyWith(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.yellow,
      onPrimary: Colors.black,
      secondary: AppColors.yellow,
      onSecondary: Colors.black,
      surface: AppColors.black,
      onSurface: AppColors.white,
      error: AppColors.red,
    ),
    scaffoldBackgroundColor: AppColors.black,
    canvasColor: AppColors.black,
    dividerColor: const Color(0xFF3A3A3A),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.yellow),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.yellow),
      errorBorder: border(AppColors.red),
      focusedErrorBorder: border(AppColors.red),
      border: border(AppColors.border),
      prefixIconColor: AppColors.grey,
      suffixIconColor: AppColors.grey,
      errorStyle: const TextStyle(color: AppColors.red),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.black,
        disabledBackgroundColor: AppColors.yellow.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.black54,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: radius10),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.yellow,
        side: const BorderSide(color: AppColors.yellow, width: 2),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: radius10),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.yellow),
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppColors.yellow, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.yellow
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(Colors.black),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.black
            : AppColors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.yellow
            : AppColors.cardLight,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.black,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.yellow),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: TextStyle(color: AppColors.white),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      showDragHandle: true,
    ),
  );
}

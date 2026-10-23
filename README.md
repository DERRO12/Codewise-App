# Code Wise Academy

Flutter mobile app for learning to code (MAD coursework). Phase 1 is frontend only: every screen works with demo data stored on the device.

Demo account: `student@codewise.app` / `password123` (or create a new account on the Sign Up screen).

## Run

```bash
flutter pub get
flutter run -d chrome          # quick preview in the browser
flutter run                    # on a connected Android phone or emulator
flutter build apk --release    # build/app/outputs/flutter-apk/app-release.apk
```

Android builds need a JDK (Android Studio includes one) and an Android phone with USB debugging, or an emulator.

## Screens

Splash, Sign Up, Login, Course Catalog (Home), Course Details, Lesson Player, Coding Exercise, Progress Dashboard (My Learning) and Profile, following the wireframes.

## Structure

```
lib/
  main.dart                 wires the repositories (swap mocks for the API here)
  app.dart                  providers, theme, routes
  theme/app_theme.dart      black #111111 + yellow #F5C518 theme
  models/                   AppUser, Course/Lesson/Exercise, progress (with fromJson)
  data/repositories.dart    AuthRepository, CourseRepository, ProgressRepository
  data/mock/                demo implementations and course content
  state/                    AuthController, LearningController, HomeTabController
  screens/                  one file per screen
  widgets/common.dart       shared widgets (course card, code block, progress bar…)
```

## Connecting the backend later

The UI only talks to the three repository interfaces in `lib/data/repositories.dart`. To use the Laravel API, add classes such as `ApiAuthRepository implements AuthRepository` that call the REST endpoints, then pass them to `CodeWiseApp` in `main.dart` instead of the mock ones. The models already have `fromJson` constructors for API responses.
"# Codewise-App" 

import 'package:flutter/foundation.dart';

/// Selected bottom-navigation tab: 0 Home, 1 My Learning, 2 Profile.
class HomeTabController extends ChangeNotifier {
  static const home = 0;
  static const myLearning = 1;
  static const profile = 2;

  int _index = home;
  int get index => _index;

  void go(int index) {
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }
}

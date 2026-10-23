import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/home_tab_controller.dart';
import 'catalog_screen.dart';
import 'profile_screen.dart';
import 'progress_dashboard_screen.dart';

/// Holds the three bottom-navigation tabs: Home, My Learning and Profile.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<HomeTabController>();
    return PopScope(
      canPop: tabs.index == HomeTabController.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) tabs.go(HomeTabController.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: tabs.index,
          children: const [
            CatalogScreen(),
            ProgressDashboardScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabs.index,
          onTap: tabs.go,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school_rounded),
                label: 'My Learning'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

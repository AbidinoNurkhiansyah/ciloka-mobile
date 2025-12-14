import 'package:flutter/material.dart';

import '../views/account_teacher_screen.dart';

import '../views/home_teacher_view.dart';
import '../views/leaderboard_teacher_view.dart';

class NavigationTeacherViewmodel extends ChangeNotifier {
  int _indexBottomNavbar = 0;
  final List<Widget> _screens = const [
    HomeTeacherView(),
    LeaderboardTeacherView(),
    AccountTeacherScreen(),
  ];

  int get currentIndex => _indexBottomNavbar;
  Widget get currentScreen => _screens[_indexBottomNavbar];

  void setIndexBottomNavbar(int values) {
    _indexBottomNavbar = values;
    notifyListeners();
  }
}

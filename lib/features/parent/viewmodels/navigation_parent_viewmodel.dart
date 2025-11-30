import 'package:flutter/material.dart';

import '../views/account_parent_view.dart';
import '../views/leaderboard_parent_view.dart';

class NavigationParentViewmodel extends ChangeNotifier {
  int _indexBottomNavbar = 0;
  final List<Widget> _screens = const [
    LeaderboardParentView(),
    AccountParentView(),
  ];

  int get currentIndex => _indexBottomNavbar;
  Widget get currentScreen => _screens[_indexBottomNavbar];

  void setIndexBottomNavbar(int values) {
    _indexBottomNavbar = values;
    notifyListeners();
  }
}


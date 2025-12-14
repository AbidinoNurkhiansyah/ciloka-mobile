import 'package:flutter/material.dart';
import '../views/book_student_view.dart';
import '../views/home_student_view.dart';
import '../views/leaderboard_student_view.dart';
import '../views/profile_student_view.dart';
import '../views/scanning_book.dart';

class NavigationStudentViewModel extends ChangeNotifier {
  int _indexBottomNavbar = 0;
  final List<Widget> _screens = [
    HomeStudentView(),
    const BookStudentView(),
    const ScanningBook(),
    const LeaderboardStudentView(),
    const ProfileStudentView(),
  ];

  int get currentIndex => _indexBottomNavbar;
  Widget get currentScreen => _screens[_indexBottomNavbar];

  void setIndexBottomNavbar(int values) {
    _indexBottomNavbar = values;
    notifyListeners();
  }
}

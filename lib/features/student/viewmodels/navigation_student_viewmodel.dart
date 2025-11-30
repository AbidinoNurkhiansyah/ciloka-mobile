import 'package:flutter/material.dart';

// Import-import ini harus lu benerin path-nya
import '../views/book_student_view.dart';
import '../views/home_student_view.dart';
import '../views/leaderboard_student_view.dart';
import '../views/profile_student_view.dart';

class NavigationStudentViewModel extends ChangeNotifier {
  int _indexBottomNavbar = 0;
  
  // --- INI YANG DIUBAH ---
  // Kata 'const' di depan list-nya ([...]) gw hapus.
  //
  // KENAPA? Karena 'const' di list-nya maksa SEMUA widget 
  // di dalemnya buat jadi 'const'. Kalo salah satu aja (misal BookStudentView)
  // nggak punya 'const' constructor, app-nya error.
  //
  // Solusinya: Hapus 'const' di list, tapi tambahin 'const'
  // di tiap widget-nya. 
  final List<Widget> _screens = [ 
     HomeStudentView(),
    const BookStudentView(),
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
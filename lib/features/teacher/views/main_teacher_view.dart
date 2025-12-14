import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/navigation_teacher_viewmodel.dart';

class MainTeacherView extends StatelessWidget {
  const MainTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavigationTeacherViewmodel>();
    return Scaffold(
      body: vm.currentScreen,
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: vm.currentIndex,
          onTap: vm.setIndexBottomNavbar,
          selectedItemColor: Theme.of(context).colorScheme.onSurface,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                vm.currentIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                vm.currentIndex == 1 ? Icons.class_ : Icons.class_outlined,
              ),
              label: "Kelas",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                vm.currentIndex == 2
                    ? Icons.leaderboard
                    : Icons.leaderboard_outlined,
              ),
              label: "Peringkat",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                vm.currentIndex == 3 ? Icons.person : Icons.person_outlined,
              ),
              label: "Akun",
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/navigation_parent_viewmodel.dart';

class MainParentView extends StatelessWidget {
  const MainParentView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavigationParentViewmodel>();
    return Scaffold(
      body: vm.currentScreen,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadiusGeometry.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        child: SizedBox(
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
                  vm.currentIndex == 0
                      ? Icons.leaderboard
                      : Icons.leaderboard_outlined,
                ),
                label: "Peringkat",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  vm.currentIndex == 1 ? Icons.person : Icons.person_outlined,
                ),
                label: "Akun",
              ),
            ],
          ),
        ),
      ),
    );
  }
}


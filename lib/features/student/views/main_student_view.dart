import 'package:ciloka_app/features/student/viewmodels/navigation_student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_student_viewmodel.dart';

class MainStudentView extends StatefulWidget {
  const MainStudentView({super.key});

  @override
  State<MainStudentView> createState() => _MainStudentViewState();
}

class _MainStudentViewState extends State<MainStudentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AuthStudentViewmodel>(
        context,
        listen: false,
      ).loadStudentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<NavigationStudentViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: vm.currentScreen,
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
            child: Container(
              height: 75,
              decoration: BoxDecoration(color: colorScheme.surface),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: vm.currentIndex,
                onTap: vm.setIndexBottomNavbar,
                selectedItemColor: colorScheme.onSurface,
                unselectedItemColor: colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: [
                  BottomNavigationBarItem(
                    icon: Opacity(
                      opacity: vm.currentIndex == 0 ? 1.0 : 0.6,
                      child: Image.asset(
                        'assets/img/icon_beranda.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.home, size: 24);
                        },
                      ),
                    ),
                    activeIcon: Image.asset(
                      'assets/img/icon_beranda.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.home, size: 28);
                      },
                    ),
                    label: "Beranda",
                  ),
                  BottomNavigationBarItem(
                    icon: Opacity(
                      opacity: vm.currentIndex == 1 ? 1.0 : 0.6,
                      child: Image.asset(
                        'assets/img/icon_kelas.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.school, size: 24);
                        },
                      ),
                    ),
                    activeIcon: Image.asset(
                      'assets/img/icon_kelas.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.school, size: 28);
                      },
                    ),
                    label: "Kelas",
                  ),
                  BottomNavigationBarItem(
                    icon: Opacity(
                      opacity: vm.currentIndex == 2 ? 1.0 : 0.6,
                      child: Image.asset(
                        'assets/img/icon_peringkat.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.emoji_events, size: 24);
                        },
                      ),
                    ),
                    activeIcon: Image.asset(
                      'assets/img/icon_peringkat.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.emoji_events, size: 28);
                      },
                    ),
                    label: "Peringkat",
                  ),
                  BottomNavigationBarItem(
                    icon: Opacity(
                      opacity: vm.currentIndex == 3 ? 1.0 : 0.6,
                      child: Image.asset(
                        'assets/img/icon_akun.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 24);
                        },
                      ),
                    ),
                    activeIcon: Image.asset(
                      'assets/img/icon_akun.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 28);
                      },
                    ),
                    label: "Akun",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

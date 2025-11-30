import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:ciloka_app/features/student/viewmodels/auth_student_viewmodel.dart';
import 'package:ciloka_app/features/student/viewmodels/navigation_student_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileStudentView extends StatelessWidget {
  const ProfileStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Belum login')));
    }

    final studentStream = StudentService().streamStudentProfile(uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: Icon(Icons.login),
          ),
        ],
      ),
      body: StreamBuilder<StudentModel?>(
        stream: studentStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                AppSpacing.vLg,
                // Owl character / Profile picture
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: student.photoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            student.photoUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.pets,
                          size: 60,
                          color: Color(0xFF0090D4),
                        ),
                ),
                AppSpacing.vMd,
                Text(
                  student.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  student.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vLg,
                // Stats card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            'Level',
                            '${student.currentLevel}/5',
                            Icons.flag,
                          ),
                          _buildStatItem(
                            context,
                            'Progress',
                            '${(student.levelProgress * 100).toInt()}%',
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.vLg,
                // Settings button
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle settings
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Pengaturan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.secondary),
        AppSpacing.vSm,
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text("Konfirmasi Keluar"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: Text(
                "Tidak",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // final prefs = await SharedPreferences.getInstance();
                // await prefs.clear();

                // Reset navigation index ke beranda
                Provider.of<NavigationStudentViewModel>(
                  context,
                  listen: false,
                ).setIndexBottomNavbar(0);

                await Provider.of<AuthStudentViewmodel>(
                  context,
                  listen: false,
                ).logout(context);
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }
}

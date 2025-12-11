import 'package:cached_network_image/cached_network_image.dart';
import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:ciloka_app/features/student/viewmodels/auth_student_viewmodel.dart';
import 'package:ciloka_app/features/student/viewmodels/navigation_student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/animated_widgets.dart';

class ProfileStudentView extends StatelessWidget {
  const ProfileStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStudentViewmodel>(
      builder: (context, authVm, _) {
        final uid = authVm.authUid;

        if (uid == null) {
          return const Scaffold(body: Center(child: Text('Belum login')));
        }

        final studentStream = StudentService().streamStudentProfile(uid);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: const Text(
              'Profil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                child: Column(
                  children: [
                    // Header Section with gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: student.photoUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: student.photoUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: Colors.white,
                                                child: const Icon(
                                                  Icons.pets,
                                                  size: 60,
                                                  color: Color(0xFF0090D4),
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.white,
                                          child: const Icon(
                                            Icons.pets,
                                            size: 60,
                                            color: Color(0xFF0090D4),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            student.studentName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Level Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Level ${student.currentLevel}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),

                    // Stats Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistik Belajar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats Cards Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernStatCard(
                                  context,
                                  icon: Icons.emoji_events_rounded,
                                  label: 'Level',
                                  value: student.currentLevel,
                                  suffix: '',
                                  subtitle: 'dari 5',
                                  color: const Color(0xFFFFB800),
                                  gradientColors: [
                                    const Color(0xFFFFB800),
                                    const Color(0xFFFF8C00),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModernStatCard(
                                  context,
                                  icon: Icons.trending_up_rounded,
                                  label: 'Progress',
                                  value: (student.currentLevel / 5 * 100)
                                      .toInt(),
                                  suffix: '%',
                                  subtitle: 'total',
                                  color: const Color(0xFF4CAF50),
                                  gradientColors: [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF2E7D32),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Progress Bar Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Progress Total',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    AnimatedCounter(
                                      targetValue:
                                          (student.currentLevel / 5 * 100)
                                              .toInt(),
                                      suffix: '%',
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AnimatedProgressBar(
                                  value: student.currentLevel / 5,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required String suffix,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            targetValue: value,
            suffix: suffix,
            textStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Konfirmasi Keluar",
                style: TextStyle(color: Color(0xff1e1e1e)),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar?",
            style: TextStyle(color: Color(0xff797979)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Tidak",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                await Provider.of<AuthStudentViewmodel>(
                  context,
                  listen: false,
                ).logout(context);

                Provider.of<NavigationStudentViewModel>(
                  context,
                  listen: false,
                ).setIndexBottomNavbar(0);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }
}

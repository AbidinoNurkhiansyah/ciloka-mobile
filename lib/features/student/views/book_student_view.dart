import 'package:cached_network_image/cached_network_image.dart';
import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:ciloka_app/features/student/viewmodels/auth_student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../widgets/animated_widgets.dart';

class BookStudentView extends StatelessWidget {
  const BookStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStudentViewmodel>(
      builder: (context, vm, _) {
        final uid = vm.authUid;

        // Jika belum login / reload
        if (uid == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Gunakan StreamBuilder agar data (Level & Poin) selalu real-time
        return StreamBuilder<StudentModel?>(
          stream: StudentService().streamStudentProfile(uid),
          builder: (context, snapshot) {
            // Kita bisa pakai data dari stream (terbaru) ATAU fallback ke data di VM (yg mungkin stale tapi ada)
            // Prioritas: Snapshot Data -> VM Data -> Default
            final streamData = snapshot.data;
            final vmData = vm.studentProfile;

            // Ambil data display dari Stream/VM
            final String photoUrl =
                streamData?.photoUrl ?? vmData?['photoUrl'] ?? '';
            final String studentName =
                streamData?.studentName ?? vmData?['studentName'] ?? 'Siswa';
            final int currentLevel =
                streamData?.currentLevel ?? vmData?['currentLevel'] ?? 1;
            final int points =
                streamData?.totalPoints ?? vmData?['points'] ?? 0;

            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- HEADER CARD ---
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF16C4FF), Color(0xFF3F83F8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF16C4FF,
                                ).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // FOTO PROFIL
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 38,
                                  backgroundColor: Colors.white,
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(photoUrl)
                                      : null,
                                  child: photoUrl.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                              ),

                              AppSpacing.hMd,

                              // TEKS NAMA & KELAS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hallo!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      'Selamat Datang di kelas',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      studentName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.vMd,

                        // --- CHAT CALLOUT ---
                        // Tetap pakai data dari VM karena ini data relasional (Teacher ID)
                        // yang jarang berubah dan tidak ada di StudentModel sederhana
                        if (vm.teacherId != null &&
                            vm.getConsistentStudentId() != null)
                          _ChatCallout(
                            teacherId: vm.teacherId!,
                            studentId: vm.getConsistentStudentId()!,
                          ),

                        AppSpacing.vMd,

                        // --- INFO GRID ---
                        // Pass level & point yang REALTIME dari stream
                        _InfoGrid(currentLevel: currentLevel, points: points),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatCallout extends StatelessWidget {
  final String teacherId;
  final String studentId;

  const _ChatCallout({this.teacherId = '', this.studentId = ''});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GlobalNavigator.pushNamed(
          AppRoutes.chatStudent,
          arguments: {'teacherId': teacherId, 'studentId': studentId},
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xff19DA3D),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.chat, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayo Berbincang!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Story Room siap untuk kamu dan gurumu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final int currentLevel;
  final int points;

  const _InfoGrid({required this.currentLevel, required this.points});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Consumer<AuthStudentViewmodel>(
                builder: (context, vm, _) {
                  final student = vm.studentProfile;
                  final grade = student?['grade']?.toString() ?? '-';
                  final className = student?['className'] ?? '-';

                  return _InfoCard(
                    title: 'Kelas',
                    subtitle: '$grade $className',
                    backgroundColor: const Color(0xffFF98B5),
                    icon: Icons.menu_book_rounded,
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Consumer<AuthStudentViewmodel>(
                builder: (context, vm, _) {
                  final teacherName = vm.studentProfile?['teacherName'] ?? '-';

                  return _InfoCard(
                    title: 'Wali kelas',
                    subtitle: teacherName,
                    backgroundColor: const Color(0xffAD8BDE),
                    icon: Icons.person_pin_circle_rounded,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                // Gunakan REALTIME data
                title: 'Level $currentLevel',
                subtitle: 'dari 5 level',
                backgroundColor: const Color(0xff60C0F3),
                icon: Icons.rocket_launch_rounded,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _AnimatedInfoCard(
                // Gunakan REALTIME data
                value: points,
                subtitle: 'Total Poin',
                backgroundColor: const Color(0xffF8E2B0),
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: colorScheme.secondary, size: 24),
          ),
          AppSpacing.vSm,
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center, // Biar rapi kalau panjang
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated version of InfoCard for numeric values
class _AnimatedInfoCard extends StatelessWidget {
  const _AnimatedInfoCard({
    required this.value,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
    this.iconColor,
  });

  final int value;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.secondary,
              size: 24,
            ),
          ),
          AppSpacing.vSm,
          AnimatedCounter(
            targetValue: value,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

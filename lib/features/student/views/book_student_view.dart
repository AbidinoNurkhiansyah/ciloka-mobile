import 'package:cached_network_image/cached_network_image.dart';
import 'package:ciloka_app/core/theme/app_spacing.dart';
// import 'package:ciloka_app/core/utils/global_navigator.dart'; // Nggak kepake di sini
import 'package:ciloka_app/features/student/viewmodels/auth_student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../../../core/routes/app_routes.dart'; // Nggak kepake di sini

class BookStudentView extends StatelessWidget {
  const BookStudentView({super.key});

  @override
  Widget build(BuildContext context) {
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
                        color: const Color(0xFF16C4FF).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Consumer<AuthStudentViewmodel>(
                    builder: (context, vm, _) {
                      // --- FIX: CEK DULU APAKAH DATA ADA ---
                      final student = vm.studentProfile;

                      if (student == null) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      // --- AMBIL DATA DENGAN FALLBACK (BIAR GAK NULL) ---
                      final String photoUrl = student['photoUrl'] ?? '';
                      final String studentName =
                          student['studentName'] ?? 'Siswa';
                      final String grade = student['grade']?.toString() ?? '';
                      final String className = student['className'] ?? '';
                      final String teacherName = student['teacherName'] ?? '-';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // FOTO PROFIL
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.white,
                              // Cek kalo URL kosong, tampilin icon user
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
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                Text(
                                  'Selamat Datang di kelas',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.92),
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
                      );
                    },
                  ),
                ),

                AppSpacing.vMd,

                // CHAT CALLOUT
                // Bungkus Consumer juga di sini kalau butuh data ID guru/siswa
                Consumer<AuthStudentViewmodel>(
                  builder: (context, vm, _) {
                    // Ambil ID dengan aman
                    final teacherId = vm.studentProfile?['teacherId'] ?? '';
                    final studentId =
                        vm.studentProfile?['studentId'] ??
                        ''; // Atau ambil dari Auth

                    return _ChatCallout(
                      teacherId: teacherId,
                      studentId: studentId,
                    );
                  },
                ),

                AppSpacing.vMd,

                // INFO GRID
                const _InfoGrid(),
              ],
            ),
          ),
        ),
      ),
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
        // TODO: Ganti pake AppRoutes.chatStudent yang bener
        // GlobalNavigator.pushNamed(
        //   AppRoutes.chatStudent,
        //   arguments: {'teacherId': teacherId, 'studentId': studentId},
        // );
        print("Chat diklik! Guru: $teacherId, Siswa: $studentId");
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
                      color: Colors.white.withOpacity(0.9),
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
  const _InfoGrid();

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
        const Row(
          // const karena isinya statis sementara
          children: [
            Expanded(
              child: _InfoCard(
                title: 'Level 2',
                subtitle: 'Level maksimum 2',
                backgroundColor: Color(0xff60C0F3),
                icon: Icons.rocket_launch_rounded,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _InfoCard(
                title: 'adada',
                subtitle: 'Jumlah bintangmu',
                backgroundColor: Color(0xffF8E2B0),
                icon: Icons.star_rate_rounded,
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
    this.iconColor,
  });

  final String title;
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
              color: colorScheme.onSurface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.secondary,
              size: 24,
            ),
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
              color: colorScheme.onSurface.withOpacity(0.85),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

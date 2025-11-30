import '../../../core/theme/app_spacing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_teacher_model.dart';
import '../services/profile_teacher_service.dart';

class HomeTeacherView extends StatelessWidget {
  const HomeTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Belum login'));
    }

    final teacherStream = ProfileTeacherService().streamTeacherProfile(uid);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/img/logo_ciloka.webp', width: 80),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, size: 32),
                onPressed: () {
                  // Aksi ketika ikon notifikasi ditekan
                },
              ),
              Positioned(
                right: 9,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<TeacherModel?>(
        stream: teacherStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data guru tidak ditemukan'));
          }
          final teacher = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: (teacher.photoUrl.isNotEmpty)
                            ? NetworkImage(teacher.photoUrl)
                            : null,
                        child: teacher.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),
                      AppSpacing.hMd,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Dashboard Guru',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Halo, ${teacher.username}',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(
                    left: AppSpacing.md,
                    top: AppSpacing.md,
                  ),
                  child: Text(
                    'Kelas Hari Ini',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(50),
        child: SizedBox(
          height: 74,
          width: 74,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: colorScheme.secondary,
            child: Icon(Icons.add, color: colorScheme.onSurface, size: 36),
          ),
        ),
      ),
    );
  }
}

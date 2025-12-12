import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import '../../student/services/chat_service.dart';
import '../services/upload_image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_teacher_model.dart';
import '../services/profile_teacher_service.dart';
import '../viewmodels/auth_teacher_viewmodel.dart';

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
        actions: [_buildChatIconWithBadge(context, colorScheme)],
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
                  padding: const EdgeInsets.all(AppSpacing.md),
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
                      const SizedBox(width: AppSpacing.md),
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
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    top: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kelas Hari Ini',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // Test Notification Button
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Test text notification
                            NotificationService().showChatNotification(
                              senderName: 'Budi Santoso',
                              message:
                                  'Halo Bu Guru, saya mau tanya PR matematika!',
                              isImage: false,
                            );

                            // Test image notification (delayed)
                            Future.delayed(const Duration(seconds: 2), () {
                              NotificationService().showChatImageNotification(
                                senderName: 'Siti Aisyah',
                                imageUrl: 'https://via.placeholder.com/300',
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.notifications_active,
                            size: 16,
                          ),
                          label: const Text('Test Notif'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
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
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(50),
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

  Widget _buildChatIconWithBadge(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    // Ambil teacherId
    String? teacherId = FirebaseAuth.instance.currentUser?.uid;

    if (teacherId == null) {
      final authVm = context.read<AuthTeacherViewmodel>();
      teacherId = authVm.currentTeacher?.uid;
    }

    if (teacherId == null || teacherId.isEmpty) {
      // Jika teacherId tidak ada, tampilkan icon tanpa badge
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          onPressed: () {
            GlobalSnackBar.showError(
              context,
              'Gagal memuat sesi guru. Silakan login ulang.',
            );
          },
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 28),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final chatService = ChatService(
      FirebaseFirestore.instance,
      UploadImageService(),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: chatService.getTeacherChatList(teacherId),
        builder: (context, snapshot) {
          int unreadCount = 0;

          if (snapshot.hasData) {
            final rooms = snapshot.data!.docs;
            // Hitung jumlah chat yang belum dibaca
            unreadCount = rooms.where((room) {
              final data = room.data() as Map<String, dynamic>;
              final isReadByTeacher = data['isReadByTeacher'] ?? true;
              return !isReadByTeacher;
            }).length;
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  GlobalNavigator.pushNamed(
                    AppRoutes.listChatStudent,
                    arguments: teacherId,
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 28),
                color: Colors.white,
              ),
              // Tampilkan badge hanya jika ada pesan belum dibaca
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252), // Red accent
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

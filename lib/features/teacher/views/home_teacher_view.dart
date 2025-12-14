import '../../../core/routes/app_routes.dart';

import '../../../core/static/class_color_static.dart';
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
import '../viewmodels/class_viewmodel.dart';

class HomeTeacherView extends StatelessWidget {
  const HomeTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Belum login'));
    }

    final teacherStream = ProfileTeacherService().streamTeacherProfile(uid);
    final viewModel = context.read<ClassViewModel>();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

                  _buildClassSummary(context),
                  const SizedBox(height: 8),
                  StreamBuilder(
                    stream: viewModel.classStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}'),
                        );
                      }
                      final classes = snapshot.data ?? [];
                      if (classes.isEmpty) {
                        return SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.6, // biar tetap di tengah layar
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.class_rounded,
                                  size: 120,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                AppSpacing.vSm,
                                Text(
                                  'Belum ada kelas!',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                AppSpacing.vSm,
                                Text(
                                  'Tambah Kelas terlebih dahulu',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: List.generate(classes.length, (index) {
                          final kelas = classes[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _buildClassCard(
                              context,
                              grade: kelas.grade,
                              className: kelas.className,
                              onTap: () {
                                GlobalNavigator.pushNamed(
                                  AppRoutes.classDataTeacher,
                                  arguments: {
                                    'classId': kelas.id,
                                    'grade': kelas.grade,
                                    'className': kelas.className,
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
        padding: const EdgeInsets.only(right: 16),
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
      padding: const EdgeInsets.only(right: 16),
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
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 32),
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

  Widget _buildClassSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ringkasan Kelas',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text(
            'Buat Kelas',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),

          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => _addClassDialog(dialogContext),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  // Widget untuk Card "Kelas 4 A"
  Widget _buildClassCard(
    BuildContext context, {
    required String grade,
    required String className,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: ClassColorHelper.getUniqueColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Text(
              'Kelas $grade $className',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _addClassDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final classNameController = TextEditingController();
    String? selectedGrade;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ClassViewModel>(
      builder: (context, viewModel, _) => AlertDialog(
        title: Align(
          alignment: AlignmentGeometry.center,
          child: Text(
            'Tambah Kelas',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: colorScheme.onSurface,
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih Tingkat',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurfaceVariant,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                ),
                dropdownColor: colorScheme.onSurface,

                style: TextStyle(color: Color(0xff1e1e1e)),
                items: List.generate(
                  6,
                  (index) => DropdownMenuItem(
                    value: '${index + 1}',
                    child: Text('Kelas ${index + 1}'),
                  ),
                ),
                onChanged: (value) => selectedGrade = value,
                validator: (value) =>
                    value == null ? 'Silakan pilih tingkat' : null,
              ),
              AppSpacing.vSm,
              TextFormField(
                controller: classNameController,
                style: TextStyle(color: colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: 'Nama Kelas',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurfaceVariant,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama kelas wajib diisi'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      viewModel.addClass(
                        className: classNameController.text,
                        grade: selectedGrade!,
                        context: context,
                      );
                    }
                  },
            child: viewModel.isLoading
                ? const CircularProgressIndicator()
                : Text(
                    'Tambah',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

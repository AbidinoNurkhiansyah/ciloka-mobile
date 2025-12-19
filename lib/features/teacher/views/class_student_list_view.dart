import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/global_error_handler.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import '../models/class_student_model.dart';
import '../viewmodels/student_list_viewmodel.dart';

class ClassStudentListView extends StatelessWidget {
  const ClassStudentListView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> safeArgs = (args is Map<String, dynamic>)
        ? args
        : {};
    final classId = safeArgs['classId'] as String? ?? '';
    final grade = safeArgs['grade'] as String? ?? '';
    final className = safeArgs['className'] as String? ?? '';

    final viewModel = context.read<StudentListViewmodel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: colorScheme.onSurface,
          onPressed: () => GlobalNavigator.pop(),
        ),
        title: Text(
          'Kelas $grade $className',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: const Text(
                    'Hapus Kelas?',
                    style: TextStyle(
                      color: Color(0xff1e1e1e),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Seluruh data siswa dan foto di dalam kelas ini akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
                    style: TextStyle(color: Color(0xff1e1e1e)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Tutup dialog konfirmasi
                        Navigator.pop(context);

                        // Tampilkan loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          debugPrint('⏳ Menjalankan deleteClass...');
                          await viewModel.deleteClass(classId: classId);
                          debugPrint('✅ deleteClass berhasil.');

                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) async {
                            debugPrint(
                              '🔄 PostFrameCallback: Menutup loading...',
                            );
                            GlobalNavigator.pop(); // Tutup loading dialog

                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );

                            if (GlobalNavigator.navigatorKey.currentContext !=
                                null) {
                              GlobalSnackBar.showSuccess(
                                GlobalNavigator.navigatorKey.currentContext!,
                                'Kelas dan semua data siswa berhasil dihapus',
                              );
                            }

                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );

                            debugPrint(
                              '⬅️ PostFrameCallback: Kembali ke list kelas...',
                            );
                            GlobalNavigator.pop(); // Kembali ke home
                          });
                        } catch (e, stack) {
                          debugPrint('❌ Error saat hapus: $e');
                          if (context.mounted) {
                            GlobalNavigator.pop();
                            GlobalErrorHandler.handle(
                              context,
                              e.toString(),
                              stack,
                            );
                          }
                        }
                      },
                      child: Text(
                        'Hapus',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete, size: 30, color: colorScheme.error),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<ClassStudentModel>>(
          stream: viewModel.getStudentsByClass(
            classId: classId,
            context: context,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}'),
              );
            }

            final students = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari NIS atau Nama Siswa',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      AppSpacing.hMd,
                      ElevatedButton.icon(
                        onPressed: () {
                          GlobalNavigator.pushNamed(
                            AppRoutes.addStudentTeacher,
                            arguments: {'classId': classId},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Tambah',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🧑‍🎓 Jika belum ada siswa
                  if (students.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_add,
                              size: 120,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada Siswa di kelas!',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah terlebih dahulu',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          colorScheme.secondary,
                        ),
                        columnSpacing: 24,
                        columns: [
                          DataColumn(
                            label: Text(
                              'No',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Foto',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nama Lengkap',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'NIS',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nama Orang Tua',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Aksi',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: List.generate(students.length, (index) {
                          final s = students[index];
                          final isEven = index.isEven;
                          return DataRow(
                            color: WidgetStateProperty.all(
                              isEven
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.grey.shade200,
                            ),
                            cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey.shade400,
                                    backgroundImage: (s.photoUrl.isNotEmpty)
                                        ? CachedNetworkImageProvider(s.photoUrl)
                                        : null,
                                    child: (s.photoUrl.isEmpty)
                                        ? Icon(
                                            Icons.person,
                                            color: colorScheme.onSurface,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    s.studentName,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    s.nis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    s.parentName,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        GlobalNavigator.pushNamed(
                                          AppRoutes.editStudentTeacher,
                                          arguments: {
                                            'student': s,
                                            'classId': classId,
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: colorScheme.error,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            title: const Text(
                                              'Hapus Siswa?',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff1e1e1e),
                                              ),
                                            ),
                                            content: Text(
                                              'Data siswa ${s.studentName} akan dihapus permanen.',
                                              style: const TextStyle(
                                                color: Color(0xff1e1e1e),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) =>
                                                        const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                  );
                                                  try {
                                                    debugPrint(
                                                      '⏳ Menjalankan deleteStudent...',
                                                    );
                                                    await viewModel
                                                        .deleteStudent(
                                                          classId: classId,
                                                          student: s,
                                                        );
                                                    debugPrint(
                                                      '✅ deleteStudent berhasil.',
                                                    );

                                                    WidgetsBinding.instance.addPostFrameCallback((
                                                      _,
                                                    ) async {
                                                      debugPrint(
                                                        '🔄 PostFrameCallback (Student): Menutup loading...',
                                                      );
                                                      GlobalNavigator.pop(); // Tutup loading dialog

                                                      await Future.delayed(
                                                        const Duration(
                                                          milliseconds: 300,
                                                        ),
                                                      );

                                                      if (GlobalNavigator
                                                              .navigatorKey
                                                              .currentContext !=
                                                          null) {
                                                        GlobalSnackBar.showSuccess(
                                                          GlobalNavigator
                                                              .navigatorKey
                                                              .currentContext!,
                                                          'Siswa berhasil dihapus',
                                                        );
                                                      }
                                                    });
                                                  } catch (e, stack) {
                                                    debugPrint(
                                                      '❌ Error saat hapus student: $e',
                                                    );
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          debugPrint(
                                                            '🔄 PostFrameCallback (Student Error): Menutup loading...',
                                                          );
                                                          GlobalNavigator.pop(); // Tutup loading dialog
                                                          GlobalErrorHandler.handle(
                                                            context,
                                                            e.toString(),
                                                            stack,
                                                          );
                                                        });
                                                  }
                                                },
                                                child: Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    color: colorScheme.error,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

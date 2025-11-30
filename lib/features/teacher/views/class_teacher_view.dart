import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/static/class_color_static.dart';
import '../../../core/utils/global_navigator.dart';
import '../viewmodels/class_viewmodel.dart';

class ClassTeacherView extends StatefulWidget {
  const ClassTeacherView({super.key});

  @override
  State<ClassTeacherView> createState() => _ClassTeacherViewState();
}

class _ClassTeacherViewState extends State<ClassTeacherView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ClassViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // --- Bagian Ringkasan Kelas ---
              _buildClassSummary(context),
              const SizedBox(height: 16),
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
            'TAMBAH KELAS',
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

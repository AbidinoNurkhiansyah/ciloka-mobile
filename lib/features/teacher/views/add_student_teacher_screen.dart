import 'package:ciloka_app/features/teacher/viewmodels/student_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../widgets/custom_textfield_widget.dart';

class AddStudentTeacherScreen extends StatefulWidget {
  const AddStudentTeacherScreen({super.key});

  @override
  State<AddStudentTeacherScreen> createState() =>
      _AddStudentTeacherScreenState();
}

class _AddStudentTeacherScreenState extends State<AddStudentTeacherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nisController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> safeArgs = (args is Map<String, dynamic>)
        ? args
        : {};
    final classId = safeArgs['classId'] as String? ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            GlobalNavigator.pop();
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        backgroundColor: colorScheme.secondary,
        title: Text(
          "Tambah Siswa",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PILIH FOTO PROFIL ---
            const Text(
              "Pilih Foto Profil",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),
            Consumer<StudentListViewmodel>(
              builder: (context, viewModel, _) {
                return GestureDetector(
                  onTap: viewModel.pickProfileImage,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      border: Border.all(
                        color: const Color.fromARGB(255, 206, 206, 206),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: viewModel.profileImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: colorScheme.secondary,
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: ElevatedButton(
                                  onPressed: viewModel.pickProfileImage,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                    ),
                                    backgroundColor: colorScheme.secondary,
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text("Pilih File"),
                                ),
                              ),

                              Text(
                                "Unggah Foto jpeg/jpg Max 1Mb",
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              viewModel.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                );
              },
            ),
            AppSpacing.vMd,

            // --- INPUT NAMA DAN NIM ---
            customTextField(
              controller: nameController,
              label: 'Nama Lengkap Siswa',
              hint: 'Masukkan Nama Lengkap Siswa',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Nama Lengkap Wajib diisi";
                }
                return null;
              },
            ),
            customTextField(
              controller: nisController,
              label: 'NIS',
              hint: 'Masukkan NIS siswa',
              prefixIcon: Icons.badge,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "NIS Wajib diisi";
                }
                return null;
              },
            ),

            customTextField(
              controller: parentNameController,
              label: 'Nama Orang Tua',
              hint: 'Masukkan Nama Orang tua',
              prefixIcon: Icons.person_3_sharp,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          child: Consumer<StudentListViewmodel>(
            builder: (context, viewModel, _) {
              return ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.addStudentClass(
                          classId: classId,
                          photoUrl: '',
                          studentName: nameController.text.trim(),
                          nis: nisController.text.trim(),
                          parentName: parentNameController.text.trim(),
                          context: context,
                        );
                        if (success && mounted) {
                          viewModel.clearProfileImage();
                          GlobalNavigator.pop();
                        }
                      },
                child: Text(
                  "Simpan",
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

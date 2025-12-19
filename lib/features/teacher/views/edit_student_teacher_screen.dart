import 'package:ciloka_app/features/teacher/models/class_student_model.dart';
import 'package:ciloka_app/features/teacher/viewmodels/student_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import '../../../widgets/custom_textfield_widget.dart';

class EditStudentTeacherScreen extends StatefulWidget {
  const EditStudentTeacherScreen({super.key});

  @override
  State<EditStudentTeacherScreen> createState() =>
      _EditStudentTeacherScreenState();
}

class _EditStudentTeacherScreenState extends State<EditStudentTeacherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nisController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isInit = false;
  late ClassStudentModel student;
  late String classId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StudentListViewmodel>().clearProfileImage();
      });
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        student = args['student'] as ClassStudentModel;
        classId = args['classId'] as String;

        nameController.text = student.studentName;
        nisController.text = student.nis;
        parentNameController.text = student.parentName;
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<StudentListViewmodel>().profileImage = null;
            GlobalNavigator.pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        backgroundColor: colorScheme.secondary,
        title: Text(
          "Ubah Data Siswa",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Foto Profil",
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // --- FOTO LAYER ---
                          viewModel.profileImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    viewModel.profileImage!,
                                    width: double.infinity,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (student.photoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: student.photoUrl,
                                          width: double.infinity,
                                          height: 300,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 80,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      )),

                          // --- OVERLAY LAYER ---
                          Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Sentuh untuk ganti foto",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              AppSpacing.vMd,
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
                        if (_formKey.currentState!.validate()) {
                          // Tampilkan dialog konfirmasi
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Text(
                                'Simpan Perubahan?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff1e1e1e),
                                ),
                              ),
                              content: const Text(
                                'Apakah Anda yakin ingin memperbarui data siswa ini?',
                                style: TextStyle(color: Color(0xff1e1e1e)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // Tutup konfirmasi

                                    // Tampilkan loading dialog
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );

                                    final success = await viewModel
                                        .updateStudent(
                                          classId: classId,
                                          studentId: student.id,
                                          oldNis: student.nis,
                                          studentName: nameController.text
                                              .trim(),
                                          nis: nisController.text.trim(),
                                          parentName: parentNameController.text
                                              .trim(),
                                          oldPhotoUrl: student.photoUrl,
                                          context: context,
                                        );

                                    if (mounted) {
                                      WidgetsBinding.instance.addPostFrameCallback((
                                        _,
                                      ) async {
                                        GlobalNavigator.pop(); // Tutup loading dialog
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        if (success) {
                                          await Future.delayed(
                                            const Duration(milliseconds: 300),
                                          );

                                          if (GlobalNavigator
                                                  .navigatorKey
                                                  .currentContext !=
                                              null) {
                                            GlobalSnackBar.showSuccess(
                                              GlobalNavigator
                                                  .navigatorKey
                                                  .currentContext!,
                                              'Data siswa berhasil diperbarui',
                                            );
                                          }

                                          await Future.delayed(
                                            const Duration(milliseconds: 300),
                                          );
                                          GlobalNavigator.pop();
                                          // Kembali ke list
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Update',
                                    style: TextStyle(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                child: Text(
                  "Update",
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

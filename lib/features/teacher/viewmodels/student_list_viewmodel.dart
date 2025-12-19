import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/static/student_class_status.dart';
import '../../../core/utils/global_error_handler.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import '../models/class_student_model.dart';
import '../services/student_class_service.dart';
import '../services/upload_image_service.dart';

class StudentListViewmodel extends ChangeNotifier {
  StudentClassService _studentFirestore;
  final UploadImageService _imageService;
  StudentListViewmodel(this._studentFirestore, this._imageService);

  void updateService(StudentClassService service) {
    _studentFirestore = service;
  }

  StudentClassStatus _status = StudentClassStatus.uncreated;
  StudentClassStatus get status => _status;

  File? profileImage;

  final ImagePicker picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> pickProfileImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && await image.length() <= 1024 * 1024) {
      profileImage = File(image.path);
      notifyListeners();
    } else {
      throw ('Foto Melebihi 1Mb');
    }
  }

  void setProfileImage(File file) {
    profileImage = file;
    notifyListeners();
  }

  Future<bool> addStudentClass({
    required String classId,
    required String photoUrl,
    required String studentName,
    required String nis,
    required String parentName,
    required BuildContext context,
  }) async {
    try {
      _status = StudentClassStatus.creating;
      _isLoading = true;
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      notifyListeners();

      final nisExists = await _studentFirestore.isNisExist(classId, nis);
      if (nisExists) {
        throw ("Siswa dengan NIS ini sudah terdaftar di kelas");
      }

      String photoUrl = '';
      if (profileImage != null) {
        try {
          photoUrl = await _imageService.uploadToCloudinary(profileImage!);
        } catch (e, stack) {
          debugPrint("Upload gagal: $e");
          GlobalErrorHandler.handle(context, e.toString(), stack);
        }
      }
      await _studentFirestore.addStudentClass(
        classId: classId,
        photoUrl: photoUrl,
        studentName: studentName,
        nis: nis,
        parentName: parentName,
      );

      _status = StudentClassStatus.created;
      _isLoading = false;
      notifyListeners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && _status == StudentClassStatus.created) {
          GlobalSnackBar.showSuccess(
            GlobalNavigator.navigatorKey.currentContext!,
            'Siswa berhasil ditambahkan',
          );
          GlobalNavigator.pop();
        }
      });

      return true;
    } catch (e, stack) {
      _isLoading = false;
      _status = StudentClassStatus.uncreated;
      notifyListeners();
      GlobalErrorHandler.handle(context, e.toString(), stack);
      return false;
    }
  }

  void clearProfileImage() {
    profileImage = null;
    notifyListeners();
  }

  Stream<List<ClassStudentModel>> getStudentsByClass({
    required String classId,
    required BuildContext context,
  }) {
    if (classId.isEmpty) {
      debugPrint('⚠️ getStudentsByClass dipanggil dengan classId kosong');
      return const Stream.empty();
    }
    try {
      return _studentFirestore.getStudentsByClass(classId);
    } catch (e, stack) {
      debugPrint('Error fetching students: $e');
      GlobalErrorHandler.handle(context, e.toString(), stack);
      return const Stream.empty();
    }
  }

  Future<void> deleteClass({required String classId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🚀 Memulai penghapusan kelas: $classId');

      // 1. Ambil semua siswa untuk mendapatkan URL foto mereka
      final students = await _studentFirestore.getStudentsList(classId);
      debugPrint(
        '📂 Ditemukan ${students.length} siswa untuk dihapus gambarnya.',
      );

      // 2. Hapus dari Cloudinary secara PARALEL (lebih cepat)
      if (students.isNotEmpty) {
        await Future.wait(
          students.where((s) => s.photoUrl.isNotEmpty).map((s) {
            debugPrint('🖼️ Menghapus foto: ${s.photoUrl}');
            return _imageService.deleteFromCloudinary(s.photoUrl);
          }),
        );
      }
      debugPrint('✅ Semua foto di Cloudinary telah diproses.');

      // 3. Hapus dari Firestore (Class, Students, StudentIndex)
      await _studentFirestore.deleteClass(classId);
      debugPrint('✅ Data Firestore telah dihapus.');

      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('❌ Terjadi kesalahan saat menghapus kelas: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

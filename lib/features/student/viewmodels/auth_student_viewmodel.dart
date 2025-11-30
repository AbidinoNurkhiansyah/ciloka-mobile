import 'dart:async';

import '../services/auth_student_service.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/static/firebase_auth_status.dart';
import '../../../core/utils/global_error_handler.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import 'package:flutter/material.dart';

class AuthStudentViewmodel extends ChangeNotifier {
  AuthStudentService _studentService;
  Map<String, dynamic>? studentProfile;

  AuthStudentViewmodel(this._studentService);
  Map<String, dynamic>? _currentStudentData;
  bool _isLoading = false;

  Map<String, dynamic>? get currentStudentData => _currentStudentData;
  bool get isLoading => _isLoading;

  void updateService(AuthStudentService service) {
    _studentService = service;
  }

  FirebaseAuthStatus _status = FirebaseAuthStatus.unauthenticated;
  FirebaseAuthStatus get status => _status;

  Future<bool> loginStudent(
    String studentName,
    String nis, {
    required BuildContext context,
  }) async {
    _isLoading = true;
    _status = FirebaseAuthStatus.authenticating;
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    notifyListeners();

    try {
      // --- PERBAIKAN DI SINI ---
      // Panggil method yang benar: loginStudent (bukan loginParent)
      final result = await _studentService.loginStudent(
        studentName: studentName,
        nis: nis,
      );

      _isLoading = false;
      if (result != null) {
        _status = FirebaseAuthStatus.authenticated;
        _currentStudentData = result;
        studentProfile = result;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Tutup loading dialog
          FocusManager.instance.primaryFocus?.unfocus();

          await Future.delayed(const Duration(milliseconds: 300));

          if (_status == FirebaseAuthStatus.authenticated) {
            GlobalSnackBar.showSuccess(
              GlobalNavigator.navigatorKey.currentContext!,
              'Berhasil Masuk, Selamat Datang👋',
            );

            await Future.delayed(const Duration(milliseconds: 400));
            GlobalNavigator.pushReplacementNamed(AppRoutes.mainStudent);
          }
        });

        notifyListeners();
        return true;
      } else {
        _status = FirebaseAuthStatus.unauthenticated;
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Tutup loading dialog
        FocusManager.instance.primaryFocus?.unfocus();
        GlobalSnackBar.showError(
          context,
          'NIS atau Nama Siswa tidak ditemukan!',
        );
        debugPrint("❌ Login gagal: NIS atau Nama Siswa tidak ditemukan");
        notifyListeners();
        return false;
      }
    } catch (e, stack) {
      _isLoading = false;
      _status = FirebaseAuthStatus.unauthenticated;
      Navigator.of(context, rootNavigator: true).pop(); // Tutup loading dialog
      GlobalErrorHandler.handle(context, e.toString(), stack);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _status = FirebaseAuthStatus.signingOut;
    notifyListeners();

    try {
      _currentStudentData = null;
      _status = FirebaseAuthStatus.unauthenticated;
      GlobalNavigator.pushReplacementNamed(AppRoutes.loginStudent);
    } catch (e, stack) {
      GlobalErrorHandler.handle(context, e, stack);
    } finally {
      notifyListeners();
    }
  }
}

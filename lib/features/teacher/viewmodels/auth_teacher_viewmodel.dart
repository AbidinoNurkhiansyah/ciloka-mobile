import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_teacher_model.dart';
import '../services/profile_teacher_service.dart';

import '../../../core/routes/app_routes.dart';
import '../services/firebase_auth_service.dart';
import '../../../core/static/firebase_auth_status.dart';
import '../../../core/utils/global_error_handler.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import 'package:flutter/material.dart';

class AuthTeacherViewmodel extends ChangeNotifier {
  FirebaseAuthService _authService;
  final ProfileTeacherService _teacherService = ProfileTeacherService();

  FirebaseAuthStatus _status = FirebaseAuthStatus.unauthenticated;
  FirebaseAuthStatus get status => _status;

  TeacherModel? _currentTeacher;
  TeacherModel? get currentTeacher => _currentTeacher;

  Stream<TeacherModel?>? _teacherStream;
  Stream<TeacherModel?>? get teacherStream => _teacherStream;

  StreamSubscription<TeacherModel?>? _teacherSubscription;

  AuthTeacherViewmodel(this._authService);

  void updateAuthService(FirebaseAuthService service) {
    _authService = service;
  }

  // Load teacher session dari SharedPreferences
  Future<void> loadTeacherSession() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherUid = prefs.getString('logged_teacher_uid');
    final userRole = prefs.getString('user_role');

    if (teacherUid != null && userRole == 'teacher') {
      _status = FirebaseAuthStatus.authenticated;

      await _teacherSubscription?.cancel();

      // Set stream realtime
      _teacherStream = _teacherService.streamTeacherProfile(teacherUid);
      notifyListeners();
      _teacherSubscription = _teacherStream!.listen((teacher) {
        _currentTeacher = teacher;
        notifyListeners();
      });
    }
  }

  Future<void> register(
    String username,
    String email,
    String password, {
    required BuildContext context,
  }) async {
    _status = FirebaseAuthStatus.creatingAccount;
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    notifyListeners();

    try {
      await _authService.createUser(
        username: username,
        email: email,
        password: password,
        photoUrl: '',
      );
      _status = FirebaseAuthStatus.accountCreated;
    } catch (e, stack) {
      GlobalErrorHandler.handle(context, e.toString(), stack);
      _status = FirebaseAuthStatus.unauthenticated;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Navigator.canPop(context)) {
          GlobalNavigator.pop();
        }
        FocusManager.instance.primaryFocus?.unfocus();

        await Future.delayed(const Duration(milliseconds: 300));

        if (_status == FirebaseAuthStatus.accountCreated) {
          GlobalSnackBar.showSuccess(
            GlobalNavigator.navigatorKey.currentContext!,
            'Pendaftaran Berhasil! Silahkan Masuk 👋',
          );

          await Future.delayed(const Duration(milliseconds: 500));
          GlobalNavigator.pushReplacementNamed(AppRoutes.loginTeacher);
        }

        notifyListeners();
      });
    }
  }

  Future<bool> login(
    String email,
    String password, {
    required BuildContext context,
  }) async {
    _status = FirebaseAuthStatus.authenticating;
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    notifyListeners();

    try {
      final userCredential = await _authService.signInUser(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User tidak ditemukan');
      _status = FirebaseAuthStatus.authenticated;

      // Simpan UID teacher ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_teacher_uid', user.uid);
      await prefs.setString('user_role', 'teacher');

      await _teacherSubscription?.cancel();

      // Set stream realtime
      _teacherStream = _teacherService.streamTeacherProfile(user.uid);
      notifyListeners();
      _teacherSubscription = _teacherStream!.listen((teacher) {
        _currentTeacher = teacher;
        notifyListeners();
      });

      return true;
    } catch (e, stack) {
      GlobalErrorHandler.handle(context, e.toString(), stack);
      _status = FirebaseAuthStatus.unauthenticated;
      return false;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Navigator.canPop(context)) {
          GlobalNavigator.pop();
        }
        FocusManager.instance.primaryFocus?.unfocus();

        await Future.delayed(const Duration(milliseconds: 400));

        if (_status == FirebaseAuthStatus.authenticated) {
          GlobalSnackBar.showSuccess(
            GlobalNavigator.navigatorKey.currentContext!,
            'Berhasil Masuk! Selamat Datang 👋',
          );

          await Future.delayed(const Duration(milliseconds: 500));
          GlobalNavigator.pushReplacementNamed(AppRoutes.mainTeacher);
        }

        notifyListeners();
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    _status = FirebaseAuthStatus.signingOut;
    notifyListeners();

    try {
      await _authService.signOut();

      // Hapus session dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logged_teacher_uid');
      await prefs.remove('user_role');

      _currentTeacher = null;
      _status = FirebaseAuthStatus.unauthenticated;

      // Navigate ke select role
      GlobalNavigator.pushReplacementNamed(AppRoutes.selectRole);
    } catch (e, stack) {
      GlobalErrorHandler.handle(context, e, stack);
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _teacherSubscription?.cancel();
    super.dispose();
  }
}

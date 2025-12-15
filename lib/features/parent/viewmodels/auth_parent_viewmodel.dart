import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_parent_service.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/static/firebase_auth_status.dart';
import '../../../core/utils/global_error_handler.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import 'package:flutter/material.dart';

class AuthParentViewmodel extends ChangeNotifier {
  AuthParentService _parentService;

  Map<String, dynamic>? _currentParentData;
  bool _isLoading = false;

  Map<String, dynamic>? get currentParentData => _currentParentData;
  bool get isLoading => _isLoading;

  AuthParentViewmodel(this._parentService);
  void updateService(AuthParentService service) {
    _parentService = service;
  }

  FirebaseAuthStatus _status = FirebaseAuthStatus.unauthenticated;
  FirebaseAuthStatus get status => _status;

  Future<void> loadParentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final nis = prefs.getString('logged_nis');

    if (nis == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _parentService.fetchByNis(nis);
      if (data != null) {
        _currentParentData = data;
        _status = FirebaseAuthStatus.authenticated;
      }
    } catch (e) {
      debugPrint("Error loading parent session: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginParent(
    String parentName,
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
      final result = await _parentService.loginParent(
        parentName: parentName,
        nis: nis,
      );

      _isLoading = false;
      if (result != null) {
        _status = FirebaseAuthStatus.authenticated;
        _currentParentData = result;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Navigator.of(context, rootNavigator: true).pop();
          FocusManager.instance.primaryFocus?.unfocus();

          await Future.delayed(const Duration(milliseconds: 300));

          if (_status == FirebaseAuthStatus.authenticated) {
            GlobalSnackBar.showSuccess(
              GlobalNavigator.navigatorKey.currentContext!,
              'Berhasil Masuk, Selamat Datang👋',
            );

            // Save Session
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_role', 'parent');
            await prefs.setString('logged_nis', nis);
            await prefs.setString('logged_parent_name', parentName);

            await Future.delayed(const Duration(milliseconds: 400));
            GlobalNavigator.pushReplacementNamed(AppRoutes.mainParent);
          }
        });
        notifyListeners();
        return true;
      } else {
        _status = FirebaseAuthStatus.unauthenticated;
        Navigator.of(context, rootNavigator: true).pop();
        FocusManager.instance.primaryFocus?.unfocus();
        GlobalSnackBar.showError(
          context,
          'NIS atau Nama Orang Tua tidak ditemukan!',
        );
        notifyListeners();
        return false;
      }
    } catch (e, stack) {
      _isLoading = false;
      _status = FirebaseAuthStatus.unauthenticated;
      Navigator.of(context, rootNavigator: true).pop();
      GlobalErrorHandler.handle(context, e.toString(), stack);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _status = FirebaseAuthStatus.signingOut;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role');
      await prefs.remove('logged_nis');
      await prefs.remove('logged_parent_name');

      _currentParentData = null;
      _status = FirebaseAuthStatus.unauthenticated;
      GlobalNavigator.pushReplacementNamed(
        AppRoutes.loginParent,
      ); // Assuming route exists or fallback
    } catch (e, stack) {
      GlobalErrorHandler.handle(context, e, stack);
    } finally {
      notifyListeners();
    }
  }
}

import 'package:ciloka_app/core/static/add_class_status.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/global_error_handler.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../core/utils/global_snackbar.dart';
import '../models/class_teacher_model.dart';
import '../services/class_teacher_service.dart';

class ClassViewModel extends ChangeNotifier {
  ClassTeacherService _firestoreService;

  ClassViewModel(this._firestoreService);
  void updateService(ClassTeacherService service) {
    _firestoreService = service;
  }

  AddClassStatus _status = AddClassStatus.uncreated;
  AddClassStatus get status => _status;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<ClassTeacherModel>> get classStream =>
      _firestoreService.getTeacherClasses();

  void resetStatus() {
    _status = AddClassStatus.uncreated;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addClass({
    required String grade,
    required String className,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _status = AddClassStatus.creating;
      notifyListeners();

      await _firestoreService.addClass(grade: grade, className: className);

      _isLoading = false;
      _status = AddClassStatus.created;
      return true;
    } catch (e, stack) {
      GlobalErrorHandler.handle(context, e.toString(), stack);
      _isLoading = false;
      _status = AddClassStatus.uncreated;
      return false;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted && _status == AddClassStatus.created) {
          GlobalSnackBar.showSuccess(
            GlobalNavigator.navigatorKey.currentContext!,
            'Kelas Berhasil Ditambahkan',
          );

          GlobalNavigator.pop();
        }

        notifyListeners();
      });
    }
  }
}

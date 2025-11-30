import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'global_snackbar.dart';

class GlobalErrorHandler {
  static void handle(
    BuildContext context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      print('🔴 Error: $error');
      if (stackTrace != null) print(stackTrace);
    }

    GlobalSnackBar.showError(context, error.toString());
  }
}

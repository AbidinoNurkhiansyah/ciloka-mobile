import 'package:flutter/foundation.dart';

class ErrorNotifier extends ChangeNotifier {
  static final global = ErrorNotifier();
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void handleError(Object error) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  void clear() {
    _errorMessage = null;
  }
}

import 'package:flutter/material.dart';

class GlobalSnackBar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.red);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.green);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.blue);
  }
}

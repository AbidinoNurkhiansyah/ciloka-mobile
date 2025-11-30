import 'package:flutter/material.dart';

class GlobalNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> pushReplacementNamed<T extends Object?>(
    String routeName,
  ) async {
    return navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }
}

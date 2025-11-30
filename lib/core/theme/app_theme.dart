import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFB0DAFD),
      primary: Color(0xFFB0DAFD),
      onPrimary: Colors.black,
      secondary: Color(0xFF0090D4),
      surface: Color(0xFF2ACCF0),
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xff6B6B6B),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: Color(0xFFB0DAFD),
    textTheme: const TextTheme(
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF0090D4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.all(14),
      floatingLabelStyle: TextStyle(color: Color(0xFF0090D4)),
      border: InputBorder.none,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Color(0xFF0090D4)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Color(0xFFB3261E), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Color(0xFFB3261E), width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Color(0xff0090D4),
      ),
    ),
  );
}

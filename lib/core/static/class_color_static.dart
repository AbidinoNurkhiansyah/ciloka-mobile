import 'dart:math';
import 'package:flutter/material.dart';

class ClassColorHelper {
  static final List<Color> _availableColors = [
    const Color(0xFFE9407A),
    const Color(0xFF5C6BC0),
    const Color(0xFF26A69A),
    const Color(0xFFEF6C00),
    const Color.fromARGB(255, 255, 221, 1),
    const Color(0xFF66BB6A),
    const Color(0xFFFF7043),
    const Color(0xFF42A5F5),
    const Color(0xFFAB47BC),
  ];

  static final List<Color> _usedColors = [];

  static Color getUniqueColor() {
    // Kalau semua warna sudah dipakai, reset ulang
    if (_usedColors.length == _availableColors.length) {
      _usedColors.clear();
    }

    // Ambil warna yang belum dipakai
    final remainingColors = _availableColors
        .where((color) => !_usedColors.contains(color))
        .toList();

    // Pilih acak dari sisa warna
    final randomColor =
        remainingColors[Random().nextInt(remainingColors.length)];
    _usedColors.add(randomColor);

    return randomColor;
  }
}

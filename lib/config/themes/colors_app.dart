import 'package:flutter/material.dart';

class ColorsApp {
  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.orange,
  ).copyWith(
    primary: const Color(0xFFFF7622),
    secondary: const Color(0xFF03DAC6),
    surface: Colors.white,
    onSurface: Colors.black,
    error: const Color(0xFFB00020),
  );
}

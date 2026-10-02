import 'package:flutter/material.dart';

/// Design tokens from docs/07 §8.
abstract final class AppColors {
  static const Color primaryLight = Color(0xFF174C3F);
  static const Color primaryDark = Color(0xFFB3945B);
  static const Color accent = Color(0xFFB3945B);

  static const Color surfaceLight = Color(0xFFF7F3E8);
  static const Color surfaceSepia = Color(0xFFF7F3E8);
  static const Color surfaceDark = Color(0xFF0B1416);

  static const Color onSurfaceLight = Color(0xFF202823);
  static const Color onSurfaceDark = Color(0xFFE8EEED);
  static const Color onSurfaceSepia = Color(0xFF3D3426);
}

abstract final class AppRadii {
  static const double card = 16;
  static const double sheet = 28;
}

abstract final class AppMotion {
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration highlightPulse = Duration(seconds: 4);
}

abstract final class AppTypography {
  static const double arabicDefault = 28;
  static const double arabicMin = 20;
  static const double arabicMax = 44;
}

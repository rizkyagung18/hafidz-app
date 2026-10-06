import 'package:flutter/material.dart';

/// Design tokens from docs/07 §8.
abstract final class AppColors {
  // Al-Qur'an library tokens from the approved Figma reference. The printed
  // Mushaf uses its own source-faithful palette and is not styled with these.
  static const Color libraryTeal = Color(0xFF0F766E);
  static const Color libraryTealBright = Color(0xFF2DD4BF);
  static const Color libraryGold = Color(0xFFB08D57);
  static const Color libraryDarkCard = Color(0xFF122326);
  static const Color libraryDarkBorder = Color(0xFF243638);
  static const Color libraryDarkText = Color(0xFFF5F6EF);
  static const Color libraryDarkMuted = Color(0xFFA0B2B2);

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

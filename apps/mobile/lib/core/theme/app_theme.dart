import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hafidz_app/core/theme/app_colors.dart';

/// App theme preference beyond Flutter's [ThemeMode] (adds sepia).
enum AppThemePreference { light, dark, sepia }

abstract final class AppTheme {
  static const String latinFontFamily = 'Plus Jakarta Sans';
  static const String arabicFontFamily = 'Me Quran';

  static ThemeData light() => _build(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
  );

  static ThemeData sepia() => _build(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    surface: AppColors.surfaceSepia,
    onSurface: AppColors.onSurfaceSepia,
    onTertiary: AppColors.onSurfaceSepia,
  );

  static ThemeData of(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.light => light(),
      AppThemePreference.dark => dark(),
      AppThemePreference.sepia => sepia(),
    };
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color onSurface,
    Color? onTertiary,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          primary: primary,
          surface: surface,
          onSurface: onSurface,
        ).copyWith(
          tertiary: AppColors.accent,
          onTertiary:
              onTertiary ??
              (brightness == Brightness.dark
                  ? AppColors.onSurfaceDark
                  : AppColors.onSurfaceLight),
        );

    final base = ThemeData(brightness: brightness).textTheme;
    final latinText = base.apply(
      fontFamily: latinFontFamily,
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: latinFontFamily,
      textTheme: latinText,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: latinText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: onSurface.withValues(alpha: 0.08)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStatePropertyAll(
          latinText.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Arabic body style for the local QUL Me Quran font.
  static TextStyle arabic({
    double fontSize = AppTypography.arabicDefault,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: arabicFontFamily,
      fontSize: fontSize.clamp(
        AppTypography.arabicMin,
        AppTypography.arabicMax,
      ),
      color: color,
      fontWeight: fontWeight,
      height: 1.8,
    );
  }
}

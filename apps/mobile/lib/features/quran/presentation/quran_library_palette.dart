import 'package:flutter/material.dart';
import 'package:hafidz_app/core/theme/app_colors.dart';

/// Colors for the Al-Qur'an library, separate from printed Mushaf styling.
class QuranLibraryPalette {
  const QuranLibraryPalette({
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.teal,
    required this.gold,
  });

  factory QuranLibraryPalette.from(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return const QuranLibraryPalette(
        background: AppColors.surfaceDark,
        card: AppColors.libraryDarkCard,
        border: AppColors.libraryDarkBorder,
        text: AppColors.libraryDarkText,
        muted: AppColors.libraryDarkMuted,
        teal: AppColors.libraryTealBright,
        gold: AppColors.libraryGold,
      );
    }
    return QuranLibraryPalette(
      background: theme.scaffoldBackgroundColor,
      card: const Color(0xFFFFFCF5),
      border: const Color(0xFFDCD6CA),
      text: theme.colorScheme.onSurface,
      muted: const Color(0xFF63706B),
      teal: AppColors.libraryTeal,
      gold: const Color(0xFF8C6833),
    );
  }

  final Color background;
  final Color card;
  final Color border;
  final Color text;
  final Color muted;
  final Color teal;
  final Color gold;
}

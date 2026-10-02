import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/i18n/locale_provider.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/core/theme/theme_preference_provider.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themePreference = ref.watch(themePreferenceProvider);
    final locale = ref.watch(localeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.themeSection,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SegmentedButton<AppThemePreference>(
            segments: [
              ButtonSegment(
                value: AppThemePreference.light,
                label: Text(l10n.themeLight),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemePreference.dark,
                label: Text(l10n.themeDark),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemePreference.sepia,
                label: Text(l10n.themeSepia),
                icon: const Icon(Icons.auto_stories_outlined),
              ),
            ],
            selected: {themePreference},
            onSelectionChanged: (selection) {
              ref
                  .read(themePreferenceProvider.notifier)
                  .setPreference(selection.single);
            },
          ),
          const SizedBox(height: 28),
          Text(
            l10n.languageSection,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'id', label: Text(l10n.languageId)),
              ButtonSegment(value: 'en', label: Text(l10n.languageEn)),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selection) {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(selection.single));
            },
          ),
        ],
      ),
    );
  }
}

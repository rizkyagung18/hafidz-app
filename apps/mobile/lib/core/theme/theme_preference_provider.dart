import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';

const _themeKey = 'theme_preference';

final themePreferenceProvider =
    NotifierProvider<ThemePreferenceNotifier, AppThemePreference>(
      ThemePreferenceNotifier.new,
    );

class ThemePreferenceNotifier extends Notifier<AppThemePreference> {
  @override
  AppThemePreference build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_themeKey);
    return AppThemePreference.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AppThemePreference.light,
    );
  }

  Future<void> setPreference(AppThemePreference preference) async {
    state = preference;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_themeKey, preference.name);
  }
}

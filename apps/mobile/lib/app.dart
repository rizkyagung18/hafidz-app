import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/i18n/locale_provider.dart';
import 'package:hafidz_app/core/router/app_router.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/core/theme/theme_preference_provider.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

class HafidzApp extends ConsumerStatefulWidget {
  const HafidzApp({super.key, this.router});

  /// Optional injected router for widget tests.
  final GoRouter? router;

  @override
  ConsumerState<HafidzApp> createState() => _HafidzAppState();
}

class _HafidzAppState extends ConsumerState<HafidzApp> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themePreference = ref.watch(themePreferenceProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Hafidz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(themePreference),
      themeMode: themePreference == AppThemePreference.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
    );
  }
}

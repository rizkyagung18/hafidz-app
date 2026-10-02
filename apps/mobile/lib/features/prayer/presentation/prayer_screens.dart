import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:hafidz_app/shared/widgets/placeholder_screen.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PlaceholderScreen(
      title: l10n.prayerTitle,
      actions: [
        OutlinedButton(
          onPressed: () => context.push('/prayer/month'),
          child: Text(l10n.prayerMonthTitle),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.push('/prayer/settings'),
          child: Text(l10n.prayerSettingsTitle),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.push('/prayer/location'),
          child: Text(l10n.prayerLocationTitle),
        ),
      ],
    );
  }
}

class PrayerMonthScreen extends StatelessWidget {
  const PrayerMonthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).prayerMonthTitle,
    );
  }
}

class PrayerSettingsScreen extends StatelessWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).prayerSettingsTitle,
    );
  }
}

class PrayerLocationScreen extends StatelessWidget {
  const PrayerLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).prayerLocationTitle,
    );
  }
}

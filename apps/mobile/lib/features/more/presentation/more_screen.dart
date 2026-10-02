import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = <({String label, String route, IconData icon})>[
      (
        label: l10n.qiblaTitle,
        route: '/qibla',
        icon: Icons.explore_outlined,
      ),
      (
        label: l10n.moreDoa,
        route: '/doa',
        icon: Icons.volunteer_activism_outlined,
      ),
      (
        label: l10n.moreAsmaulHusna,
        route: '/asmaul-husna',
        icon: Icons.auto_awesome_outlined,
      ),
      (
        label: l10n.moreTasbih,
        route: '/tasbih',
        icon: Icons.radio_button_checked,
      ),
      (
        label: l10n.moreHijri,
        route: '/hijri',
        icon: Icons.calendar_month_outlined,
      ),
      (
        label: l10n.moreSettings,
        route: '/settings',
        icon: Icons.settings_outlined,
      ),
      (label: l10n.moreAbout, route: '/about', icon: Icons.info_outline),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(item.route),
          );
        },
      ),
    );
  }
}

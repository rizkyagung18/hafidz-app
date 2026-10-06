import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/theme/app_colors.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark
        ? AppColors.libraryDarkCard
        : theme.scaffoldBackgroundColor;
    final inactive = isDark
        ? AppColors.libraryDarkMuted
        : theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final active = isDark ? AppColors.libraryTealBright : AppColors.libraryTeal;
    final destinations = [
      (Icons.menu_book_outlined, Icons.menu_book, l10n.tabQuran),
      (Icons.schedule_outlined, Icons.schedule, l10n.tabPrayer),
      (Icons.school_outlined, Icons.school, l10n.tabLearning),
      (Icons.more_horiz, Icons.more_horiz, l10n.tabMore),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.libraryDarkBorder
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: ColoredBox(
          color: barColor,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (var index = 0; index < destinations.length; index++)
                    Expanded(
                      child: _NavItem(
                        label: destinations[index].$3,
                        icon: destinations[index].$1,
                        selectedIcon: destinations[index].$2,
                        selected: navigationShell.currentIndex == index,
                        activeColor: active,
                        inactiveColor: inactive,
                        onTap: () => navigationShell.goBranch(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

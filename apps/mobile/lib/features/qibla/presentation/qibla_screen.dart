import 'package:flutter/material.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:hafidz_app/shared/widgets/placeholder_screen.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: AppLocalizations.of(context).qiblaTitle);
  }
}

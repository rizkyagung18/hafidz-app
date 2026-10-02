import 'package:flutter/material.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:hafidz_app/shared/widgets/placeholder_screen.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({this.shared = false, super.key});

  final bool shared;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScreen(
      title: l10n.voiceTitle,
      subtitle: shared ? 'shared=1' : l10n.comingSoonHint,
    );
  }
}

class VoiceResultScreen extends StatelessWidget {
  const VoiceResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).voiceResultTitle,
    );
  }
}

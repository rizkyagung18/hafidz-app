import 'package:flutter/material.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.learningTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_stories, size: 42, color: colors.onPrimary),
                const SizedBox(height: 24),
                Text(
                  l10n.learningTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.learningPreview,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.learningTitle),
              subtitle: Text(l10n.comingSoon),
            ),
          ),
        ],
      ),
    );
  }
}

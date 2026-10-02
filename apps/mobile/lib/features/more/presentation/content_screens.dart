import 'package:flutter/material.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:hafidz_app/shared/widgets/placeholder_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DoaListScreen extends StatelessWidget {
  const DoaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: AppLocalizations.of(context).doaTitle);
  }
}

class DoaDetailScreen extends StatelessWidget {
  const DoaDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).doaDetailTitle(id),
    );
  }
}

class HadithListScreen extends StatelessWidget {
  const HadithListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: AppLocalizations.of(context).hadithTitle);
  }
}

class HadithBookScreen extends StatelessWidget {
  const HadithBookScreen({required this.book, super.key});

  final String book;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).hadithBookTitle(book),
    );
  }
}

class HadithNumberScreen extends StatelessWidget {
  const HadithNumberScreen({
    required this.book,
    required this.number,
    super.key,
  });

  final String book;
  final String number;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).hadithNumberTitle(book, number),
    );
  }
}

class AsmaulHusnaScreen extends StatelessWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).asmaulHusnaTitle,
    );
  }
}

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: AppLocalizations.of(context).tasbihTitle);
  }
}

class HijriScreen extends StatelessWidget {
  const HijriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(title: AppLocalizations.of(context).hijriTitle);
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const sources = [
      ('QUL Qur’an resources', 'https://qul.tarteel.ai'),
      ('Tarteel AI ASR model', 'https://huggingface.co/tarteel-ai/whisper-base-ar-quran'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.aboutSources,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final source in sources)
            ListTile(
              title: Text(source.$1),
              subtitle: Text(source.$2),
              trailing: Tooltip(
                message: l10n.aboutOpenSource,
                child: const Icon(Icons.open_in_new),
              ),
              onTap: () => launchUrl(
                Uri.parse(source.$2),
                mode: LaunchMode.externalApplication,
              ),
            ),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
            ),
            child: Text(l10n.aboutLicenses),
          ),
        ],
      ),
    );
  }
}

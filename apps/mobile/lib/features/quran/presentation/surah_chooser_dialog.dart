import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/theme/app_colors.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/features/quran/presentation/quran_library_palette.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

void showSurahChooser(BuildContext context, SurahData surah) {
  final l10n = AppLocalizations.of(context);
  final palette = QuranLibraryPalette.from(context);
  final isMadinah = surah.revelationPlace == 'madinah';
  final image = isMadinah
      ? 'assets/images/madinah.jpeg'
      : 'assets/images/makkah.jpeg';
  final origin = isMadinah ? l10n.revelationMadinah : l10n.revelationMakkah;

  Widget action(
    BuildContext dialogContext, {
    required Key key,
    required IconData icon,
    required String label,
    required String route,
  }) => InkWell(
    key: key,
    onTap: () {
      Navigator.of(dialogContext).pop();
      if (context.mounted) context.push(route);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: palette.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: palette.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: palette.muted),
        ],
      ),
    ),
  );

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      key: const Key('surah-chooser'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: palette.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExcludeSemantics(
                      child: Image.asset(
                        image,
                        key: Key(
                          isMadinah ? 'madinah-photo' : 'makkah-photo',
                        ),
                        fit: BoxFit.cover,
                        alignment: isMadinah
                            ? const Alignment(0, -0.1)
                            : const Alignment(0, 0.1),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.40),
                            Colors.black.withValues(alpha: 0.82),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton.filledTonal(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close, size: 19),
                            ),
                          ),
                          const Spacer(),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              color: AppColors.libraryGold,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 38,
                              height: 38,
                              child: Center(
                                child: Text(
                                  surah.number.toString(),
                                  style: const TextStyle(
                                    color: AppColors.surfaceDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              surah.nameArabic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.arabic(
                                fontSize: 40,
                                color: AppColors.libraryGold,
                              ).copyWith(height: 1.15),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            surah.nameLatin,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$origin · ${l10n.quranAyahCount(surah.ayahCount)}',
                            style: const TextStyle(
                              color: Color(0xFFE5E8E4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              action(
                dialogContext,
                key: const Key('choose-mushaf'),
                icon: Icons.menu_book_outlined,
                label: l10n.quranMushafChoice,
                route: '/quran/page/${surah.firstPage}',
              ),
              Divider(height: 1, color: palette.border),
              action(
                dialogContext,
                key: const Key('choose-translation'),
                icon: Icons.translate_outlined,
                label: l10n.quranTranslationChoice,
                route: '/quran/surah/${surah.number}',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

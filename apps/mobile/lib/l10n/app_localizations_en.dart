// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hafidz App';

  @override
  String get tabHome => 'Home';

  @override
  String get tabQuran => 'Qur\'an';

  @override
  String get tabPrayer => 'Prayer';

  @override
  String get tabQibla => 'Qibla';

  @override
  String get tabMore => 'More';

  @override
  String get tabLearning => 'Learn';

  @override
  String get learningTitle => 'Memorization learning';

  @override
  String get learningPreview =>
      'Plan memorization and practice with recitation and Voice Ayah Finder. Coming soon.';

  @override
  String get quranChooseReader => 'Open surah';

  @override
  String get quranLibrarySubtitle => 'Read, understand, and draw closer.';

  @override
  String get quranHeaderBismillah => 'بِسْمِ اللَّهِ';

  @override
  String get quranBrand => 'Hafidz';

  @override
  String get quranSearchAction => 'Search surahs';

  @override
  String get quranClearSearch => 'Clear search';

  @override
  String get quranSearchHint => 'Search by surah number or name...';

  @override
  String get quranSearchJuzHint => 'Search by juz number...';

  @override
  String get quranSurahTab => 'Surah';

  @override
  String get quranJuzTab => 'Juz';

  @override
  String get quranSearchEmpty => 'No matching surah.';

  @override
  String get quranJuzEmpty => 'No matching juz.';

  @override
  String get quranJuzUnavailable =>
      'The start page for this juz is unavailable.';

  @override
  String get quranMushafChoice => 'Read Mushaf';

  @override
  String get quranTranslationChoice => 'Translation';

  @override
  String get quranTranslationReader => 'Surah & Translation';

  @override
  String get quranMurattal => 'Murattal';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonHint =>
      'This screen is a placeholder for the app shell.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About & Attribution';

  @override
  String get aboutSources => 'Data and font sources';

  @override
  String get aboutOpenSource => 'Open source';

  @override
  String get aboutLicenses => 'Software and font licenses';

  @override
  String get themeSection => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get languageSection => 'Language';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageEn => 'English';

  @override
  String get voiceTitle => 'Voice Ayah Finder';

  @override
  String get voiceResultTitle => 'Search results';

  @override
  String get voiceConnecting => 'Connecting Voice Finder…';

  @override
  String get voiceListening => 'Listening and following the recitation…';

  @override
  String get voiceFinding => 'Finding the recited ayah…';

  @override
  String get voiceFollowPaused =>
      'Follow is paused; the microphone is still active.';

  @override
  String get voicePauseFollow => 'Pause follow';

  @override
  String get voiceResumeFollow => 'Resume follow';

  @override
  String get voiceStop => 'Stop';

  @override
  String get voiceConnectFailed =>
      'Voice Finder could not connect. Check the backend and microphone permission.';

  @override
  String get voicePermissionDenied =>
      'Allow microphone access in Settings to use Voice Finder.';

  @override
  String get voiceStreamBusy =>
      'The connection could not keep up with your recitation. Try again.';

  @override
  String get voiceRetry => 'Retry';

  @override
  String get quranTitle => 'Qur\'an';

  @override
  String get quranLoadError => 'The Qur\'an could not be loaded.';

  @override
  String get quranNotFound => 'Surah not found.';

  @override
  String get retry => 'Try again';

  @override
  String get revelationMakkah => 'Meccan';

  @override
  String get revelationMadinah => 'Medinan';

  @override
  String quranAyahCount(int count) {
    return '$count ayahs';
  }

  @override
  String quranAyahNumber(int number) {
    return 'Ayah $number';
  }

  @override
  String get quranShowLatin => 'Transliteration';

  @override
  String get quranShowTranslation => 'Translation';

  @override
  String get quranMarkerUnavailable =>
      'The ayah number ornament is unavailable. The ayah text is still readable.';

  @override
  String get quranPlayAyah => 'Play ayah';

  @override
  String get quranAudioUnavailable =>
      'Recitation playback is coming in a later milestone.';

  @override
  String get quranBookmark => 'Bookmark ayah';

  @override
  String get quranRemoveBookmark => 'Remove bookmark';

  @override
  String get quranBookmarkSaved => 'Ayah bookmarked.';

  @override
  String get quranBookmarkRemoved => 'Bookmark removed.';

  @override
  String get quranShare => 'Share ayah';

  @override
  String get quranCopy => 'Copy ayah';

  @override
  String get quranCopied => 'Ayah copied.';

  @override
  String get quranTafsir => 'Kemenag tafsir';

  @override
  String get quranTafsirUnavailable => 'Tafsir is not available for this ayah.';

  @override
  String quranShareReference(String name, int surah, int ayah) {
    return 'Quran $name $surah:$ayah';
  }

  @override
  String quranSurahTitle(int number) {
    return 'Surah $number';
  }

  @override
  String quranPageTitle(int page) {
    return 'Page $page';
  }

  @override
  String get quranPageNotFound => 'Mushaf page not found.';

  @override
  String get quranPrintPackUnavailable =>
      'The local QUL print pack is unavailable. Stage the sources and try again.';

  @override
  String get quranAyahNotFound => 'Ayah not found.';

  @override
  String get quranMushafMode => 'Open Mushaf';

  @override
  String get quranJump => 'Jump to';

  @override
  String get quranJumpPage => 'Page';

  @override
  String get quranJumpJuz => 'Juz';

  @override
  String get quranJumpSurah => 'Surah';

  @override
  String get quranJumpAyah => 'Ayah';

  @override
  String get quranAyahReference => 'Surah:ayah reference';

  @override
  String quranJuzNumber(int number) {
    return 'Juz $number';
  }

  @override
  String get quranInvalidJump => 'Enter a valid destination.';

  @override
  String get quranJumpGo => 'Open';

  @override
  String quranAyahTitle(String key) {
    return 'Ayah $key';
  }

  @override
  String get prayerTitle => 'Prayer times';

  @override
  String get prayerMonthTitle => 'Monthly schedule';

  @override
  String get prayerSettingsTitle => 'Adzan settings';

  @override
  String get prayerLocationTitle => 'Prayer location';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get moreTitle => 'More';

  @override
  String get doaTitle => 'Daily du\'a';

  @override
  String doaDetailTitle(String id) {
    return 'Du\'a $id';
  }

  @override
  String get hadithTitle => 'Hadith';

  @override
  String hadithBookTitle(String book) {
    return '$book';
  }

  @override
  String hadithNumberTitle(String book, String number) {
    return '$book #$number';
  }

  @override
  String get asmaulHusnaTitle => 'Asmaul Husna';

  @override
  String get tasbihTitle => 'Tasbih';

  @override
  String get hijriTitle => 'Hijri calendar';

  @override
  String get homeVoiceCta => 'Find ayah by voice';

  @override
  String get moreDoa => 'Du\'a';

  @override
  String get moreHadith => 'Hadith';

  @override
  String get moreAsmaulHusna => 'Asmaul Husna';

  @override
  String get moreTasbih => 'Tasbih';

  @override
  String get moreHijri => 'Hijri calendar';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreAbout => 'About & Attribution';

  @override
  String get errorNetwork => 'Unable to reach the server.';

  @override
  String get errorTimeout => 'The request timed out.';

  @override
  String get errorCancelled => 'The request was cancelled.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorRateLimited => 'Too many requests. Please try again later.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get errorUpstream => 'Service temporarily unavailable.';

  @override
  String get quranGlyphUnavailable =>
      'QPC ayah lettering is unavailable. Showing readable QUL Arabic text.';

  @override
  String get voiceRecognitionPreview => 'Recognized recitation · may change';

  @override
  String get voiceSessionExpired =>
      'Listening session ended. Tap Retry to continue.';

  @override
  String get voiceInferenceFailed => 'Voice recognition failed. Try again.';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Nama aplikasi
  ///
  /// In id, this message translates to:
  /// **'Hafidz App'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get tabHome;

  /// No description provided for @tabQuran.
  ///
  /// In id, this message translates to:
  /// **'Al-Qur\'an'**
  String get tabQuran;

  /// No description provided for @tabPrayer.
  ///
  /// In id, this message translates to:
  /// **'Sholat'**
  String get tabPrayer;

  /// No description provided for @tabQibla.
  ///
  /// In id, this message translates to:
  /// **'Kiblat'**
  String get tabQibla;

  /// No description provided for @tabMore.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get tabMore;

  /// No description provided for @tabLearning.
  ///
  /// In id, this message translates to:
  /// **'Belajar'**
  String get tabLearning;

  /// No description provided for @learningTitle.
  ///
  /// In id, this message translates to:
  /// **'Belajar Hafalan'**
  String get learningTitle;

  /// No description provided for @learningPreview.
  ///
  /// In id, this message translates to:
  /// **'Rencanakan hafalan dan latihan bersama murottal dan pencarian ayat suara. Segera hadir.'**
  String get learningPreview;

  /// No description provided for @quranChooseReader.
  ///
  /// In id, this message translates to:
  /// **'Buka surah'**
  String get quranChooseReader;

  /// No description provided for @quranLibrarySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Baca, pahami, dan dekatkan hati.'**
  String get quranLibrarySubtitle;

  /// No description provided for @quranHeaderBismillah.
  ///
  /// In id, this message translates to:
  /// **'بِسْمِ اللَّهِ'**
  String get quranHeaderBismillah;

  /// No description provided for @quranBrand.
  ///
  /// In id, this message translates to:
  /// **'Hafidz'**
  String get quranBrand;

  /// No description provided for @quranSearchAction.
  ///
  /// In id, this message translates to:
  /// **'Cari surah'**
  String get quranSearchAction;

  /// No description provided for @quranClearSearch.
  ///
  /// In id, this message translates to:
  /// **'Hapus pencarian'**
  String get quranClearSearch;

  /// No description provided for @quranSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nomor atau nama surah...'**
  String get quranSearchHint;

  /// No description provided for @quranSearchJuzHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nomor juz...'**
  String get quranSearchJuzHint;

  /// No description provided for @quranSurahTab.
  ///
  /// In id, this message translates to:
  /// **'Surah'**
  String get quranSurahTab;

  /// No description provided for @quranJuzTab.
  ///
  /// In id, this message translates to:
  /// **'Juz'**
  String get quranJuzTab;

  /// No description provided for @quranSearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada surah yang cocok.'**
  String get quranSearchEmpty;

  /// No description provided for @quranJuzEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada juz yang cocok.'**
  String get quranJuzEmpty;

  /// No description provided for @quranJuzUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Halaman awal juz tidak tersedia.'**
  String get quranJuzUnavailable;

  /// No description provided for @quranMushafChoice.
  ///
  /// In id, this message translates to:
  /// **'Baca Mushaf'**
  String get quranMushafChoice;

  /// No description provided for @quranTranslationChoice.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get quranTranslationChoice;

  /// No description provided for @quranTranslationReader.
  ///
  /// In id, this message translates to:
  /// **'Surah & Terjemahan'**
  String get quranTranslationReader;

  /// No description provided for @quranMurattal.
  ///
  /// In id, this message translates to:
  /// **'Murattal'**
  String get quranMurattal;

  /// No description provided for @comingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera hadir'**
  String get comingSoon;

  /// No description provided for @comingSoonHint.
  ///
  /// In id, this message translates to:
  /// **'Layar ini masih placeholder untuk kerangka aplikasi.'**
  String get comingSoonHint;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang & Atribusi'**
  String get aboutTitle;

  /// No description provided for @aboutSources.
  ///
  /// In id, this message translates to:
  /// **'Sumber data dan font'**
  String get aboutSources;

  /// No description provided for @aboutOpenSource.
  ///
  /// In id, this message translates to:
  /// **'Buka sumber'**
  String get aboutOpenSource;

  /// No description provided for @aboutLicenses.
  ///
  /// In id, this message translates to:
  /// **'Lisensi perangkat lunak dan font'**
  String get aboutLicenses;

  /// No description provided for @themeSection.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get themeSection;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @themeSepia.
  ///
  /// In id, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @languageSection.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageSection;

  /// No description provided for @languageId.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageId;

  /// No description provided for @languageEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @voiceTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari Ayat Suara'**
  String get voiceTitle;

  /// No description provided for @voiceResultTitle.
  ///
  /// In id, this message translates to:
  /// **'Hasil pencarian'**
  String get voiceResultTitle;

  /// No description provided for @voiceConnecting.
  ///
  /// In id, this message translates to:
  /// **'Menghubungkan pencarian suara…'**
  String get voiceConnecting;

  /// No description provided for @voiceListening.
  ///
  /// In id, this message translates to:
  /// **'Mendengarkan bacaan dan mengikuti ayat…'**
  String get voiceListening;

  /// No description provided for @voiceFinding.
  ///
  /// In id, this message translates to:
  /// **'Mencari ayat yang dibaca…'**
  String get voiceFinding;

  /// No description provided for @voiceFollowPaused.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti ayat dijeda; mikrofon masih aktif.'**
  String get voiceFollowPaused;

  /// No description provided for @voicePauseFollow.
  ///
  /// In id, this message translates to:
  /// **'Jeda ikuti'**
  String get voicePauseFollow;

  /// No description provided for @voiceResumeFollow.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ikuti'**
  String get voiceResumeFollow;

  /// No description provided for @voiceStop.
  ///
  /// In id, this message translates to:
  /// **'Hentikan'**
  String get voiceStop;

  /// No description provided for @voiceConnectFailed.
  ///
  /// In id, this message translates to:
  /// **'Pencarian suara belum dapat terhubung. Periksa backend dan izin mikrofon.'**
  String get voiceConnectFailed;

  /// No description provided for @voicePermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izinkan akses mikrofon di Pengaturan untuk menggunakan pencarian suara.'**
  String get voicePermissionDenied;

  /// No description provided for @voiceStreamBusy.
  ///
  /// In id, this message translates to:
  /// **'Koneksi tidak dapat mengikuti bacaan Anda. Coba lagi.'**
  String get voiceStreamBusy;

  /// No description provided for @voiceRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get voiceRetry;

  /// No description provided for @quranTitle.
  ///
  /// In id, this message translates to:
  /// **'Al-Qur\'an'**
  String get quranTitle;

  /// No description provided for @quranLoadError.
  ///
  /// In id, this message translates to:
  /// **'Al-Qur\'an tidak dapat dimuat.'**
  String get quranLoadError;

  /// No description provided for @quranNotFound.
  ///
  /// In id, this message translates to:
  /// **'Surah tidak ditemukan.'**
  String get quranNotFound;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @revelationMakkah.
  ///
  /// In id, this message translates to:
  /// **'Makkiyah'**
  String get revelationMakkah;

  /// No description provided for @revelationMadinah.
  ///
  /// In id, this message translates to:
  /// **'Madaniyah'**
  String get revelationMadinah;

  /// No description provided for @quranAyahCount.
  ///
  /// In id, this message translates to:
  /// **'{count} ayat'**
  String quranAyahCount(int count);

  /// No description provided for @quranAyahNumber.
  ///
  /// In id, this message translates to:
  /// **'Ayat {number}'**
  String quranAyahNumber(int number);

  /// No description provided for @quranShowLatin.
  ///
  /// In id, this message translates to:
  /// **'Latin'**
  String get quranShowLatin;

  /// No description provided for @quranShowTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get quranShowTranslation;

  /// No description provided for @quranMarkerUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Penanda nomor ayat tidak tersedia. Teks ayat tetap dapat dibaca.'**
  String get quranMarkerUnavailable;

  /// No description provided for @quranPlayAyah.
  ///
  /// In id, this message translates to:
  /// **'Putar ayat'**
  String get quranPlayAyah;

  /// No description provided for @quranAudioUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Pemutar murottal akan tersedia pada tahap berikutnya.'**
  String get quranAudioUnavailable;

  /// No description provided for @quranBookmark.
  ///
  /// In id, this message translates to:
  /// **'Tandai ayat'**
  String get quranBookmark;

  /// No description provided for @quranRemoveBookmark.
  ///
  /// In id, this message translates to:
  /// **'Hapus penanda'**
  String get quranRemoveBookmark;

  /// No description provided for @quranBookmarkSaved.
  ///
  /// In id, this message translates to:
  /// **'Ayat ditandai.'**
  String get quranBookmarkSaved;

  /// No description provided for @quranBookmarkRemoved.
  ///
  /// In id, this message translates to:
  /// **'Penanda dihapus.'**
  String get quranBookmarkRemoved;

  /// No description provided for @quranShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ayat'**
  String get quranShare;

  /// No description provided for @quranCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin ayat'**
  String get quranCopy;

  /// No description provided for @quranCopied.
  ///
  /// In id, this message translates to:
  /// **'Ayat disalin.'**
  String get quranCopied;

  /// No description provided for @quranTafsir.
  ///
  /// In id, this message translates to:
  /// **'Tafsir Kemenag'**
  String get quranTafsir;

  /// No description provided for @quranTafsirUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Tafsir belum tersedia untuk ayat ini.'**
  String get quranTafsirUnavailable;

  /// No description provided for @quranShareReference.
  ///
  /// In id, this message translates to:
  /// **'QS {name} {surah}:{ayah}'**
  String quranShareReference(String name, int surah, int ayah);

  /// No description provided for @quranSurahTitle.
  ///
  /// In id, this message translates to:
  /// **'Surah {number}'**
  String quranSurahTitle(int number);

  /// No description provided for @quranPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Halaman {page}'**
  String quranPageTitle(int page);

  /// No description provided for @quranPageNotFound.
  ///
  /// In id, this message translates to:
  /// **'Halaman mushaf tidak ditemukan.'**
  String get quranPageNotFound;

  /// No description provided for @quranPrintPackUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Paket mushaf QUL lokal belum tersedia. Siapkan sumbernya, lalu coba lagi.'**
  String get quranPrintPackUnavailable;

  /// No description provided for @quranAyahNotFound.
  ///
  /// In id, this message translates to:
  /// **'Ayat tidak ditemukan.'**
  String get quranAyahNotFound;

  /// No description provided for @quranMushafMode.
  ///
  /// In id, this message translates to:
  /// **'Buka mushaf'**
  String get quranMushafMode;

  /// No description provided for @quranJump.
  ///
  /// In id, this message translates to:
  /// **'Lompat ke'**
  String get quranJump;

  /// No description provided for @quranJumpPage.
  ///
  /// In id, this message translates to:
  /// **'Halaman'**
  String get quranJumpPage;

  /// No description provided for @quranJumpJuz.
  ///
  /// In id, this message translates to:
  /// **'Juz'**
  String get quranJumpJuz;

  /// No description provided for @quranJumpSurah.
  ///
  /// In id, this message translates to:
  /// **'Surah'**
  String get quranJumpSurah;

  /// No description provided for @quranJumpAyah.
  ///
  /// In id, this message translates to:
  /// **'Ayat'**
  String get quranJumpAyah;

  /// No description provided for @quranAyahReference.
  ///
  /// In id, this message translates to:
  /// **'Nomor surah:ayat'**
  String get quranAyahReference;

  /// No description provided for @quranJuzNumber.
  ///
  /// In id, this message translates to:
  /// **'Juz {number}'**
  String quranJuzNumber(int number);

  /// No description provided for @quranInvalidJump.
  ///
  /// In id, this message translates to:
  /// **'Masukkan tujuan yang valid.'**
  String get quranInvalidJump;

  /// No description provided for @quranJumpGo.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get quranJumpGo;

  /// No description provided for @quranAyahTitle.
  ///
  /// In id, this message translates to:
  /// **'Ayat {key}'**
  String quranAyahTitle(String key);

  /// No description provided for @prayerTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Sholat'**
  String get prayerTitle;

  /// No description provided for @prayerMonthTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal bulanan'**
  String get prayerMonthTitle;

  /// No description provided for @prayerSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan adzan'**
  String get prayerSettingsTitle;

  /// No description provided for @prayerLocationTitle.
  ///
  /// In id, this message translates to:
  /// **'Lokasi sholat'**
  String get prayerLocationTitle;

  /// No description provided for @qiblaTitle.
  ///
  /// In id, this message translates to:
  /// **'Kiblat'**
  String get qiblaTitle;

  /// No description provided for @moreTitle.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get moreTitle;

  /// No description provided for @doaTitle.
  ///
  /// In id, this message translates to:
  /// **'Doa harian'**
  String get doaTitle;

  /// No description provided for @doaDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Doa {id}'**
  String doaDetailTitle(String id);

  /// No description provided for @hadithTitle.
  ///
  /// In id, this message translates to:
  /// **'Hadis'**
  String get hadithTitle;

  /// No description provided for @hadithBookTitle.
  ///
  /// In id, this message translates to:
  /// **'{book}'**
  String hadithBookTitle(String book);

  /// No description provided for @hadithNumberTitle.
  ///
  /// In id, this message translates to:
  /// **'{book} #{number}'**
  String hadithNumberTitle(String book, String number);

  /// No description provided for @asmaulHusnaTitle.
  ///
  /// In id, this message translates to:
  /// **'Asmaul Husna'**
  String get asmaulHusnaTitle;

  /// No description provided for @tasbihTitle.
  ///
  /// In id, this message translates to:
  /// **'Tasbih'**
  String get tasbihTitle;

  /// No description provided for @hijriTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender Hijriah'**
  String get hijriTitle;

  /// No description provided for @homeVoiceCta.
  ///
  /// In id, this message translates to:
  /// **'Cari ayat dengan suara'**
  String get homeVoiceCta;

  /// No description provided for @moreDoa.
  ///
  /// In id, this message translates to:
  /// **'Doa'**
  String get moreDoa;

  /// No description provided for @moreHadith.
  ///
  /// In id, this message translates to:
  /// **'Hadis'**
  String get moreHadith;

  /// No description provided for @moreAsmaulHusna.
  ///
  /// In id, this message translates to:
  /// **'Asmaul Husna'**
  String get moreAsmaulHusna;

  /// No description provided for @moreTasbih.
  ///
  /// In id, this message translates to:
  /// **'Tasbih'**
  String get moreTasbih;

  /// No description provided for @moreHijri.
  ///
  /// In id, this message translates to:
  /// **'Kalender Hijriah'**
  String get moreHijri;

  /// No description provided for @moreSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get moreSettings;

  /// No description provided for @moreAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang & Atribusi'**
  String get moreAbout;

  /// No description provided for @errorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In id, this message translates to:
  /// **'Permintaan kehabisan waktu.'**
  String get errorTimeout;

  /// No description provided for @errorCancelled.
  ///
  /// In id, this message translates to:
  /// **'Permintaan dibatalkan.'**
  String get errorCancelled;

  /// No description provided for @errorUnknown.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get errorUnknown;

  /// No description provided for @errorRateLimited.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak permintaan. Coba lagi nanti.'**
  String get errorRateLimited;

  /// No description provided for @errorNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get errorNotFound;

  /// No description provided for @errorUpstream.
  ///
  /// In id, this message translates to:
  /// **'Layanan sementara tidak tersedia.'**
  String get errorUpstream;

  /// No description provided for @quranGlyphUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Huruf ayat QPC tidak tersedia. Menampilkan teks Arab QUL yang dapat dibaca.'**
  String get quranGlyphUnavailable;

  /// No description provided for @voiceRecognitionPreview.
  ///
  /// In id, this message translates to:
  /// **'Bacaan yang dikenali · dapat berubah'**
  String get voiceRecognitionPreview;

  /// No description provided for @voiceSessionExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi mendengarkan berakhir. Ketuk Coba lagi untuk melanjutkan.'**
  String get voiceSessionExpired;

  /// No description provided for @voiceInferenceFailed.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan suara gagal. Silakan coba lagi.'**
  String get voiceInferenceFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

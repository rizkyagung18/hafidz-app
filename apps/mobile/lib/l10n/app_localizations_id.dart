// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Hafidz App';

  @override
  String get tabHome => 'Beranda';

  @override
  String get tabQuran => 'Al-Qur\'an';

  @override
  String get tabPrayer => 'Sholat';

  @override
  String get tabQibla => 'Kiblat';

  @override
  String get tabMore => 'Lainnya';

  @override
  String get tabLearning => 'Belajar';

  @override
  String get learningTitle => 'Belajar Hafalan';

  @override
  String get learningPreview =>
      'Rencanakan hafalan dan latihan bersama murottal dan pencarian ayat suara. Segera hadir.';

  @override
  String get quranChooseReader => 'Buka surah';

  @override
  String get quranTranslationReader => 'Surah & Terjemahan';

  @override
  String get quranMurattal => 'Murattal';

  @override
  String get comingSoon => 'Segera hadir';

  @override
  String get comingSoonHint =>
      'Layar ini masih placeholder untuk kerangka aplikasi.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get aboutTitle => 'Tentang & Atribusi';

  @override
  String get aboutSources => 'Sumber data dan font';

  @override
  String get aboutOpenSource => 'Buka sumber';

  @override
  String get aboutLicenses => 'Lisensi perangkat lunak dan font';

  @override
  String get themeSection => 'Tema';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get languageSection => 'Bahasa';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageEn => 'English';

  @override
  String get voiceTitle => 'Cari Ayat Suara';

  @override
  String get voiceResultTitle => 'Hasil pencarian';

  @override
  String get voiceConnecting => 'Menghubungkan pencarian suara…';

  @override
  String get voiceListening => 'Mendengarkan bacaan dan mengikuti ayat…';

  @override
  String get voiceFinding => 'Mencari ayat yang dibaca…';

  @override
  String get voiceFollowPaused =>
      'Mengikuti ayat dijeda; mikrofon masih aktif.';

  @override
  String get voicePauseFollow => 'Jeda ikuti';

  @override
  String get voiceResumeFollow => 'Lanjut ikuti';

  @override
  String get voiceStop => 'Hentikan';

  @override
  String get voiceConnectFailed =>
      'Pencarian suara belum dapat terhubung. Periksa backend dan izin mikrofon.';

  @override
  String get voicePermissionDenied =>
      'Izinkan akses mikrofon di Pengaturan untuk menggunakan pencarian suara.';

  @override
  String get voiceStreamBusy =>
      'Koneksi tidak dapat mengikuti bacaan Anda. Coba lagi.';

  @override
  String get voiceRetry => 'Coba lagi';

  @override
  String get quranTitle => 'Al-Qur\'an';

  @override
  String get quranLoadError => 'Al-Qur\'an tidak dapat dimuat.';

  @override
  String get quranNotFound => 'Surah tidak ditemukan.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get revelationMakkah => 'Makkiyah';

  @override
  String get revelationMadinah => 'Madaniyah';

  @override
  String quranAyahCount(int count) {
    return '$count ayat';
  }

  @override
  String quranAyahNumber(int number) {
    return 'Ayat $number';
  }

  @override
  String get quranShowLatin => 'Latin';

  @override
  String get quranShowTranslation => 'Terjemahan';

  @override
  String get quranPlayAyah => 'Putar ayat';

  @override
  String get quranAudioUnavailable =>
      'Pemutar murottal akan tersedia pada tahap berikutnya.';

  @override
  String get quranBookmark => 'Tandai ayat';

  @override
  String get quranRemoveBookmark => 'Hapus penanda';

  @override
  String get quranBookmarkSaved => 'Ayat ditandai.';

  @override
  String get quranBookmarkRemoved => 'Penanda dihapus.';

  @override
  String get quranShare => 'Bagikan ayat';

  @override
  String get quranCopy => 'Salin ayat';

  @override
  String get quranCopied => 'Ayat disalin.';

  @override
  String get quranTafsir => 'Tafsir Kemenag';

  @override
  String get quranTafsirUnavailable => 'Tafsir belum tersedia untuk ayat ini.';

  @override
  String quranShareReference(String name, int surah, int ayah) {
    return 'QS $name $surah:$ayah';
  }

  @override
  String quranSurahTitle(int number) {
    return 'Surah $number';
  }

  @override
  String quranPageTitle(int page) {
    return 'Halaman $page';
  }

  @override
  String get quranPageNotFound => 'Halaman mushaf tidak ditemukan.';

  @override
  String get quranPrintPackUnavailable =>
      'Paket mushaf QUL lokal belum tersedia. Siapkan sumbernya, lalu coba lagi.';

  @override
  String get quranAyahNotFound => 'Ayat tidak ditemukan.';

  @override
  String get quranMushafMode => 'Buka mushaf';

  @override
  String get quranJump => 'Lompat ke';

  @override
  String get quranJumpPage => 'Halaman';

  @override
  String get quranJumpJuz => 'Juz';

  @override
  String get quranJumpSurah => 'Surah';

  @override
  String get quranJumpAyah => 'Ayat';

  @override
  String get quranAyahReference => 'Nomor surah:ayat';

  @override
  String quranJuzNumber(int number) {
    return 'Juz $number';
  }

  @override
  String get quranInvalidJump => 'Masukkan tujuan yang valid.';

  @override
  String get quranJumpGo => 'Buka';

  @override
  String quranAyahTitle(String key) {
    return 'Ayat $key';
  }

  @override
  String get prayerTitle => 'Jadwal Sholat';

  @override
  String get prayerMonthTitle => 'Jadwal bulanan';

  @override
  String get prayerSettingsTitle => 'Pengaturan adzan';

  @override
  String get prayerLocationTitle => 'Lokasi sholat';

  @override
  String get qiblaTitle => 'Kiblat';

  @override
  String get moreTitle => 'Lainnya';

  @override
  String get doaTitle => 'Doa harian';

  @override
  String doaDetailTitle(String id) {
    return 'Doa $id';
  }

  @override
  String get hadithTitle => 'Hadis';

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
  String get hijriTitle => 'Kalender Hijriah';

  @override
  String get homeVoiceCta => 'Cari ayat dengan suara';

  @override
  String get moreDoa => 'Doa';

  @override
  String get moreHadith => 'Hadis';

  @override
  String get moreAsmaulHusna => 'Asmaul Husna';

  @override
  String get moreTasbih => 'Tasbih';

  @override
  String get moreHijri => 'Kalender Hijriah';

  @override
  String get moreSettings => 'Pengaturan';

  @override
  String get moreAbout => 'Tentang & Atribusi';

  @override
  String get errorNetwork => 'Tidak dapat terhubung ke server.';

  @override
  String get errorTimeout => 'Permintaan kehabisan waktu.';

  @override
  String get errorCancelled => 'Permintaan dibatalkan.';

  @override
  String get errorUnknown => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get errorRateLimited => 'Terlalu banyak permintaan. Coba lagi nanti.';

  @override
  String get errorNotFound => 'Data tidak ditemukan.';

  @override
  String get errorUpstream => 'Layanan sementara tidak tersedia.';
}

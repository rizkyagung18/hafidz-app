import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/device/device_id_provider.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_range.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/features/quran/presentation/print_mushaf_page.dart';
import 'package:hafidz_app/features/quran/presentation/reader_controller.dart';
import 'package:hafidz_app/features/voice/data/live_voice_session.dart';
import 'package:hafidz_app/features/voice/domain/live_voice_message.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

const mushafPageCount = 604;

typedef LiveVoiceSessionFactory =
    LiveVoiceSession Function(
      String deviceId,
      void Function(Map<String, dynamic>) onEvent,
      void Function(Object) onError,
    );

final liveVoiceSessionFactoryProvider = Provider<LiveVoiceSessionFactory>(
  (ref) =>
      (deviceId, onEvent, onError) => LiveVoiceSession(
        deviceId: deviceId,
        onEvent: onEvent,
        onError: onError,
      ),
);

typedef MushafPageContent = ({
  List<AyahData> ayahs,
  Map<int, SurahData> surahs,
});

final FutureProviderFamily<MushafPageContent, int> mushafPageProvider =
    FutureProvider.family<MushafPageContent, int>((
      ref,
      page,
    ) async {
      final repository = ref.read(quranRepositoryProvider);
      final ayahs = await repository.page(page);
      final starts = ayahs.where((ayah) => ayah.ayah == 1).map((a) => a.surah);
      final surahs = <int, SurahData>{};
      for (final number in starts) {
        final surah = await repository.surahByNumber(number);
        if (surah != null) surahs[number] = surah;
      }
      return (ayahs: ayahs, surahs: surahs);
    });

typedef MushafPageHeader = ({int surah, int juz, int hizb, String name});

final FutureProviderFamily<MushafPageHeader, int> mushafPageHeaderProvider =
    FutureProvider.family<MushafPageHeader, int>((ref, page) async {
      final print = await ref.watch(printPageProvider(page).future);
      final first = print.lines.expand((line) => line.words).firstOrNull;
      if (first == null) {
        throw FormatException('No ayah on QUL print page $page');
      }
      final repository = ref.read(quranRepositoryProvider);
      final ayah = await repository.ayahByKey(first.ref);
      final surah = await repository.surahByNumber(first.ref.surah);
      if (ayah == null || surah == null) {
        throw FormatException(
          'Missing header metadata on QUL print page $page',
        );
      }
      return (
        surah: ayah.surah,
        juz: ayah.juz,
        hizb: ayah.hizb,
        name: surah.nameLatin,
      );
    });

class QuranPageScreen extends ConsumerStatefulWidget {
  const QuranPageScreen({
    required this.page,
    this.ayah,
    this.highlight = false,
    super.key,
  });

  final int page;
  final String? ayah;
  final bool highlight;

  @override
  ConsumerState<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends ConsumerState<QuranPageScreen> {
  late final PageController _pages;
  Timer? _saveTimer;
  late int _currentPage;
  LiveVoiceSession? _live;
  bool _connecting = false;
  bool _listening = false;
  bool _followPaused = false;
  int _lastVoiceSequence = -1;
  int _lastStableRevision = 0;
  int _latestAyahSequence = 0;
  int _sessionEpoch = 0;
  LiveVoiceMessage? _latestStableAyah;
  String? _voiceMessage;
  String? _voiceFailureCode;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.page;
    _pages = PageController(
      initialPage: widget.page.clamp(1, mushafPageCount) - 1,
    );
    if (_validPage(widget.page)) {
      _scheduleSave(widget.page);
      _positionRouteAyah();
    }
  }

  @override
  void didUpdateWidget(covariant QuranPageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page != oldWidget.page) {
      _currentPage = widget.page;
      if (_validPage(widget.page) && _pages.hasClients) {
        _pages.jumpToPage(widget.page - 1);
      }
      if (_validPage(widget.page)) _scheduleSave(widget.page);
    }
    if (widget.page != oldWidget.page ||
        widget.ayah != oldWidget.ayah ||
        widget.highlight != oldWidget.highlight) {
      _positionRouteAyah();
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _sessionEpoch++;
    if (_live != null) unawaited(_live!.stop());
    _pages.dispose();
    super.dispose();
  }

  bool _validPage(int page) => page >= 1 && page <= mushafPageCount;

  Future<void> _startListening() async {
    if (_connecting || _listening) return;
    final epoch = ++_sessionEpoch;
    setState(() {
      _connecting = true;
      _lastVoiceSequence = -1;
      _lastStableRevision = 0;
      _latestAyahSequence = 0;
      _latestStableAyah = null;
      _followPaused = false;
      _voiceMessage = null;
      _voiceFailureCode = null;
    });
    late final LiveVoiceSession session;
    session = ref.read(liveVoiceSessionFactoryProvider)(
      ref.read(deviceIdProvider),
      (event) {
        if (identical(_live, session)) _onVoiceEvent(event, epoch);
      },
      (error) {
        if (mounted && identical(_live, session)) {
          unawaited(_stopListening(failureCode: _failureCode(error)));
        }
      },
    );
    _live = session;
    try {
      final header = await ref.read(
        mushafPageHeaderProvider(_currentPage).future,
      );
      await session.start(hintSurah: header.surah);
      if (!mounted || !identical(_live, session)) {
        await session.stop();
        return;
      }
      setState(() {
        _connecting = false;
        _listening = true;
      });
    } on Object catch (error) {
      await session.stop();
      if (!mounted || !identical(_live, session)) return;
      setState(() {
        _connecting = false;
        _listening = false;
        _live = null;
        _voiceFailureCode = _failureCode(error);
      });
    }
  }

  String _failureCode(Object error) =>
      error is LiveVoiceFailure ? error.code : 'VOICE_DISCONNECTED';

  Future<void> _stopListening({String? failureCode}) async {
    final session = _live;
    _live = null;
    _sessionEpoch++;
    if (mounted) {
      setState(() {
        _connecting = false;
        _listening = false;
        _voiceMessage = null;
        _voiceFailureCode = failureCode;
      });
    }
    await session?.stop();
  }

  void _onVoiceEvent(Map<String, dynamic> event, int epoch) {
    if (!mounted) return;
    final message = LiveVoiceMessage.parse(event);
    if (message == null || message.sequence <= _lastVoiceSequence) return;
    _lastVoiceSequence = message.sequence;
    if (message.type == 'error') {
      unawaited(_stopListening(failureCode: message.code));
    } else if (message.type == 'candidate' || message.type == 'ambiguous') {
      if (_latestStableAyah == null) {
        setState(
          () => _voiceMessage = AppLocalizations.of(context).voiceFinding,
        );
      }
    } else if (message.type == 'ayah' &&
        message.revision! > _lastStableRevision) {
      _lastStableRevision = message.revision!;
      _latestAyahSequence = message.sequence;
      _latestStableAyah = message;
      setState(() => _voiceMessage = null);
      if (!_followPaused) unawaited(_followAyah(message, epoch));
    }
  }

  Future<void> _followAyah(LiveVoiceMessage message, int epoch) async {
    final range = message.range;
    if (range == null) return;
    final repository = ref.read(quranRepositoryProvider);
    final start = await repository.ayahByKey(range.start);
    final page = await repository.pageOf(range.end);
    if (!mounted ||
        !_listening ||
        _followPaused ||
        epoch != _sessionEpoch ||
        message.sequence != _latestAyahSequence ||
        start == null ||
        page == null ||
        !_validPage(page)) {
      return;
    }
    if (page != _currentPage && _pages.hasClients) {
      await _pages.animateToPage(
        page - 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
    if (mounted &&
        _listening &&
        !_followPaused &&
        epoch == _sessionEpoch &&
        message.sequence == _latestAyahSequence) {
      ref.read(readerControllerProvider.notifier).highlight(range);
    }
  }

  void _toggleFollow() {
    final resume = _followPaused;
    setState(() => _followPaused = !resume);
    if (resume && _latestStableAyah != null) {
      unawaited(_followAyah(_latestStableAyah!, _sessionEpoch));
    }
  }

  void _positionRouteAyah() {
    if (widget.ayah == null || !_validPage(widget.page)) return;
    final routePage = widget.page;
    final routeAyah = widget.ayah;
    Future<void>(() async {
      AyahRange range;
      try {
        range = AyahRange.parse(routeAyah!);
      } on FormatException {
        return;
      }
      final content = await ref.read(mushafPageProvider(routePage).future);
      if (!mounted || widget.page != routePage || widget.ayah != routeAyah) {
        return;
      }
      if (content.ayahs.any(
        (ayah) =>
            ayah.surah == range.start.surah && ayah.ayah == range.start.ayah,
      )) {
        if (widget.highlight) {
          ref.read(readerControllerProvider.notifier).highlight(range);
        }
      }
    });
  }

  void _scheduleSave(int page) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () async {
      if (!mounted) return;
      try {
        final content = await ref.read(mushafPageProvider(page).future);
        if (!mounted || content.ayahs.isEmpty || _currentPage != page) return;
        final first = content.ayahs.first;
        final target = widget.ayah;
        final selected = target == null
            ? first
            : content.ayahs.firstWhere(
                (ayah) => '${ayah.surah}:${ayah.ayah}' == target,
                orElse: () => first,
              );
        await ref
            .read(readingRepositoryProvider)
            .save(
              AyahRef(surah: selected.surah, ayah: selected.ayah),
              mode: ReadingMode.mushaf,
            );
      } on Exception catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).errorUnknown)),
          );
        }
      }
    });
  }

  Future<void> _showJump() async {
    final surahs = await ref.read(quranRepositoryProvider).surahs();
    if (!mounted) return;
    final target = await showModalBottomSheet<_MushafTarget>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MushafJumpSheet(
        currentPage: _currentPage,
        surahs: surahs,
      ),
    );
    if (!mounted || target == null) return;
    _goToTarget(target);
  }

  Future<void> _showQuickJump(_JumpKind kind, int selected) async {
    final repository = ref.read(quranRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    final List<({int number, int page, String title, String? subtitle})> items;
    if (kind == _JumpKind.surah) {
      final surahs = await repository.surahs();
      items = [
        for (final surah in surahs)
          (
            number: surah.number,
            page: surah.firstPage,
            title: '${surah.number}. ${surah.nameLatin}',
            subtitle: surah.nameArabic,
          ),
      ];
    } else {
      final pages = await Future.wait([
        for (var number = 1; number <= 30; number++)
          repository.firstPageOfJuz(number),
      ]);
      items = [
        for (var index = 0; index < pages.length; index++)
          if (pages[index] case final page?)
            (
              number: index + 1,
              page: page,
              title: l10n.quranJuzNumber(index + 1),
              subtitle: l10n.quranPageTitle(page),
            ),
      ];
    }
    if (!mounted) return;
    final listController = ScrollController(
      initialScrollOffset: (selected - 1) * 72.0,
    );
    final target = await showModalBottomSheet<_MushafTarget>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.78,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                kind == _JumpKind.surah
                    ? l10n.quranJumpSurah
                    : l10n.quranJumpJuz,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  key: Key('mushaf-${kind.name}-list'),
                  controller: listController,
                  itemExtent: 72,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      key: Key('mushaf-${kind.name}-${item.number}'),
                      selected: item.number == selected,
                      title: Text(item.title),
                      subtitle: item.subtitle == null
                          ? null
                          : Text(item.subtitle!),
                      trailing: item.number == selected
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => Navigator.of(context).pop((
                        page: item.page,
                        ayah: null,
                      )),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    listController.dispose();
    if (!mounted || target == null) return;
    _goToTarget(target);
  }

  void _goToTarget(_MushafTarget target) {
    final uri = Uri(
      path: '/quran/page/${target.page}',
      queryParameters: target.ayah == null
          ? null
          : {'ayah': target.ayah, 'hl': '1'},
    );
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_validPage(widget.page)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quranTitle)),
        body: Center(child: Text(l10n.quranPageNotFound)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3E8),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 62,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: ref
            .watch(mushafPageHeaderProvider(_currentPage))
            .when(
              data: (header) => Row(
                children: [
                  Expanded(
                    child: _ReaderPill(
                      label: 'Surah ${header.surah}: ${header.name}',
                      onTap: () => unawaited(
                        _showQuickJump(_JumpKind.surah, header.surah),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${header.surah}',
                            style: const TextStyle(
                              color: Color(0xFF174C3F),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'surah${header.surah.toString().padLeft(3, '0')}',
                                style: const TextStyle(
                                  fontFamily: 'QULSurahNameV2',
                                  fontSize: 27,
                                  color: Color(0xFF174C3F),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ReaderPill(
                      label: 'Juz ${header.juz}, Hizb ${header.hizb}',
                      onTap: () => unawaited(
                        _showQuickJump(_JumpKind.juz, header.juz),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'juz${header.juz.toString().padLeft(3, '0')}',
                                style: const TextStyle(
                                  fontFamily: 'QPCCommon',
                                  fontSize: 22,
                                  color: Color(0xFF174C3F),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Hizb ${header.hizb}',
                            style: const TextStyle(
                              color: Color(0xFF174C3F),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              error: (_, _) => Text(l10n.quranPrintPackUnavailable),
              loading: () =>
                  const SizedBox(height: 20, child: LinearProgressIndicator()),
            ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ColoredBox(
          color: const Color(0xFFF7F3E8),
          child: SizedBox(
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TextButton.icon(
                  key: const Key('mushaf-page-jump'),
                  onPressed: _showJump,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(
                    '${l10n.quranPageTitle(_currentPage)} / $mushafPageCount',
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 8,
                  child: FloatingActionButton(
                    tooltip: l10n.voiceTitle,
                    shape: const CircleBorder(),
                    backgroundColor: const Color(0xFF58D99A),
                    foregroundColor: Colors.white,
                    onPressed: _connecting
                        ? null
                        : _listening
                        ? () => unawaited(_stopListening())
                        : () => unawaited(_startListening()),
                    child: Icon(_listening ? Icons.stop : Icons.mic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomSheet: _connecting || _listening || _voiceFailureCode != null
      //     ? SafeArea(
      //         child: Padding(
      //           padding: const EdgeInsets.fromLTRB(16, 8, 96, 8),
      //           child: Row(
      //             children: [
      //               Icon(
      //                 _listening ? Icons.graphic_eq : Icons.connecting_airports,
      //               ),
      //               const SizedBox(width: 12),
      //               Expanded(
      //                 child: Text(
      //                   _connecting
      //                       ? l10n.voiceConnecting
      //                       : _voiceFailureCode == 'MIC_PERMISSION_DENIED'
      //                       ? l10n.voicePermissionDenied
      //                       : _voiceFailureCode == 'BACKPRESSURE'
      //                       ? l10n.voiceStreamBusy
      //                       : _voiceFailureCode != null
      //                       ? l10n.voiceConnectFailed
      //                       : _followPaused
      //                       ? l10n.voiceFollowPaused
      //                       : _voiceMessage ?? l10n.voiceListening,
      //                 ),
      //               ),
      //               if (_listening)
      //                 TextButton(
      //                   key: const Key('voice-pause-follow'),
      //                   onPressed: _toggleFollow,
      //                   child: Text(
      //                     _followPaused
      //                         ? l10n.voiceResumeFollow
      //                         : l10n.voicePauseFollow,
      //                   ),
      //                 ),
      //               if (_voiceFailureCode != null)
      //                 TextButton(
      //                   key: const Key('voice-retry'),
      //                   onPressed: () => unawaited(_startListening()),
      //                   child: Text(l10n.voiceRetry),
      //                 ),
      //             ],
      //           ),
      //         ),
      //       )
      //     : null,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: PageView.builder(
          key: const Key('mushaf-pages'),
          controller: _pages,
          reverse: true,
          itemCount: mushafPageCount,
          onPageChanged: (index) {
            setState(() => _currentPage = index + 1);
            _scheduleSave(index + 1);
          },
          itemBuilder: (context, index) => PrintMushafPage(page: index + 1),
        ),
      ),
    );
  }
}

class _ReaderPill extends StatelessWidget {
  const _ReaderPill({
    required this.label,
    required this.child,
    required this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDCC58F)),
        ),
        child: Row(
          children: [
            Expanded(child: child),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    ),
  );
}

typedef _MushafTarget = ({int page, String? ayah});

enum _JumpKind { page, juz, surah, ayah }

class _MushafJumpSheet extends ConsumerStatefulWidget {
  const _MushafJumpSheet({required this.currentPage, required this.surahs});

  final int currentPage;
  final List<SurahData> surahs;

  @override
  ConsumerState<_MushafJumpSheet> createState() => _MushafJumpSheetState();
}

class _MushafJumpSheetState extends ConsumerState<_MushafJumpSheet> {
  late final TextEditingController _input = TextEditingController(
    text: '${widget.currentPage}',
  );
  _JumpKind _kind = _JumpKind.page;
  int _juz = 1;
  int _surah = 1;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repository = ref.read(quranRepositoryProvider);
    _MushafTarget? target;
    try {
      switch (_kind) {
        case _JumpKind.page:
          final page = int.parse(_input.text.trim());
          if (page >= 1 && page <= mushafPageCount) {
            target = (page: page, ayah: null);
          }
        case _JumpKind.juz:
          final page = await repository.firstPageOfJuz(_juz);
          if (page != null) target = (page: page, ayah: null);
        case _JumpKind.surah:
          final surah = widget.surahs.firstWhere(
            (item) => item.number == _surah,
          );
          target = (page: surah.firstPage, ayah: null);
        case _JumpKind.ayah:
          final range = AyahRange.parse(_input.text.trim());
          final end = await repository.ayahByKey(range.end);
          if (end != null) {
            final page = await repository.pageOf(range.start);
            if (page != null) target = (page: page, ayah: range.key);
          }
      }
    } on FormatException catch (_) {
      // The localized validation message is shown below.
    }
    if (!mounted) return;
    if (target == null) {
      setState(() => _error = AppLocalizations.of(context).quranInvalidJump);
    } else {
      Navigator.of(context).pop(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.quranJump,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final kind in _JumpKind.values)
                    ChoiceChip(
                      label: Text(switch (kind) {
                        _JumpKind.page => l10n.quranJumpPage,
                        _JumpKind.juz => l10n.quranJumpJuz,
                        _JumpKind.surah => l10n.quranJumpSurah,
                        _JumpKind.ayah => l10n.quranJumpAyah,
                      }),
                      selected: _kind == kind,
                      onSelected: (_) => setState(() {
                        _kind = kind;
                        _error = null;
                        _input.text = kind == _JumpKind.page
                            ? '${widget.currentPage}'
                            : '';
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_kind == _JumpKind.page || _kind == _JumpKind.ayah)
                TextField(
                  key: const Key('mushaf-jump-input'),
                  controller: _input,
                  autofocus: true,
                  keyboardType: _kind == _JumpKind.page
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: _kind == _JumpKind.page
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  decoration: InputDecoration(
                    labelText: _kind == _JumpKind.page
                        ? l10n.quranJumpPage
                        : l10n.quranAyahReference,
                    hintText: _kind == _JumpKind.ayah ? '2:255' : null,
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                )
              else if (_kind == _JumpKind.juz)
                DropdownButtonFormField<int>(
                  initialValue: _juz,
                  decoration: InputDecoration(labelText: l10n.quranJumpJuz),
                  items: [
                    for (var number = 1; number <= 30; number++)
                      DropdownMenuItem(
                        value: number,
                        child: Text(l10n.quranJuzNumber(number)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _juz = value ?? 1),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _surah,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.quranJumpSurah),
                  items: [
                    for (final surah in widget.surahs)
                      DropdownMenuItem(
                        value: surah.number,
                        child: Text('${surah.number}. ${surah.nameLatin}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _surah = value ?? 1),
                ),
              if (_error != null &&
                  _kind != _JumpKind.page &&
                  _kind != _JumpKind.ayah)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _submit, child: Text(l10n.quranJumpGo)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_sharif/quran_sharif.dart';

import '../../../../core/widgets/tamanina_ui.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../statistics/data/worship_activity.dart';
import '../../data/services/mushaf_library.dart';
import '../../data/services/mushaf_settings.dart';
import '../../data/services/reading_position_manager.dart';
import '../../data/services/recitation_playback.dart';
import '../../data/services/recitation_store.dart';
import '../widgets/mushaf_page_typography.dart';
import '../widgets/printed_mushaf_page.dart';
import 'mushaf_settings_screen.dart';

class SimpleMushafPageScreen extends StatefulWidget {
  const SimpleMushafPageScreen({
    super.key,
    this.initialPage,
    this.initialSurah,
    this.initialVerse,
  });

  final int? initialPage;
  final int? initialSurah;
  final int? initialVerse;

  @override
  State<SimpleMushafPageScreen> createState() => _SimpleMushafPageScreenState();
}

class _SimpleMushafPageScreenState extends State<SimpleMushafPageScreen> {
  final _verseKey = GlobalKey();
  late Future<void> _initialization;
  Future<void> _readingWrites = Future.value();
  PageController? _pages;
  late MushafSettingsData _settings;
  RecitationPlayback? _recitation;
  StreamSubscription<PlaybackState>? _recitationState;
  HttpClient? _downloadClient;
  int _playback = 0;
  int _page = 1;
  int? _anchorSurah;
  int? _anchorVerse;
  double _initialScroll = 0;
  int _pageCount = 604;
  bool _playing = false;
  bool _showBars = true;

  void _toggleReadingBars() => setState(() => _showBars = !_showBars);

  @override
  void initState() {
    super.initState();
    _initialization = _load();
  }

  Future<void> _load() async {
    _settings = await MushafSettings.getAllSettings();
    _pageCount = MushafLibrary.pages.length;
    final surah = widget.initialSurah;
    _page =
        (surah == null
                ? widget.initialPage ??
                      await ReadingPositionManager.getCurrentPage()
                : MushafLibrary.surah(surah).ayahs.first.page)
            .clamp(1, _pageCount);
    _anchorSurah = surah;
    _anchorVerse = widget.initialVerse;
    if (surah == null && widget.initialPage == null) {
      _initialScroll = await ReadingPositionManager.getScrollPosition(_page);
    }
    if (!mounted) return;
    _pages = PageController(initialPage: _page - 1);
    _remember(_page);
    if (surah != null || widget.initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSurah());
    }
  }

  void _scrollToSurah() {
    final anchor = _verseKey.currentContext;
    if (anchor != null && mounted) Scrollable.ensureVisible(anchor);
  }

  void _remember(int page) {
    _readingWrites = _readingWrites.then((_) async {
      await ReadingPositionManager.saveCurrentPage(page);
      await WorshipLog.openQuranPage(page);
    });
  }

  Future<void> _jump(int page) async {
    if (_pages?.hasClients != true) return;
    _pages!.jumpToPage(page.clamp(1, _pageCount) - 1);
  }

  Future<void> _openSaved(
    BuildContext context, {
    required bool bookmarks,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        final future = bookmarks
            ? ReadingPositionManager.getBookmarks()
            : ReadingPositionManager.getReadingHistory();
        return FractionallySizedBox(
          heightFactor: .72,
          child: FutureBuilder<List<Object>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const ListSkeleton(rows: 4);
              final entries = snapshot.data!;
              return ContentFrame(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ListTile(
                      title: Text(
                        bookmarks
                            ? appText(context, 'العلامات المرجعية', 'Bookmarks')
                            : appText(
                                context,
                                'سجل القراءة',
                                'Reading history',
                              ),
                      ),
                    ),
                    if (entries.isEmpty)
                      ListTile(
                        title: Text(
                          appText(
                            context,
                            'لا توجد صفحات محفوظة بعد.',
                            'No pages saved yet.',
                          ),
                        ),
                      ),
                    for (final entry in entries)
                      ListTile(
                        title: Text(switch (entry) {
                          BookmarkModel bookmark => bookmark.title,
                          ReadingHistoryModel history => appText(
                            context,
                            'صفحة ${history.page}',
                            'Page ${history.page}',
                          ),
                          _ => '',
                        }),
                        trailing: entry is BookmarkModel
                            ? IconButton(
                                tooltip: appText(
                                  context,
                                  'حذف العلامة',
                                  'Remove bookmark',
                                ),
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await ReadingPositionManager.removeBookmark(
                                    entry.page,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                },
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _jump(
                            entry is BookmarkModel
                                ? entry.page
                                : (entry as ReadingHistoryModel).page,
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _choosePage(BuildContext context) async {
    var target = _page;
    final number = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appText(context, 'انتقل إلى صفحة', 'Go to page')),
        content: TextFormField(
          initialValue: '$_page',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(helperText: '1–$_pageCount'),
          onChanged: (value) => target = int.tryParse(value) ?? _page,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, target),
            child: Text(appText(context, 'انتقل', 'Go')),
          ),
        ],
      ),
    );
    if (number != null && mounted) _jump(number);
  }

  Future<void> _downloadAudio() async {
    if (_downloadClient != null) return;
    final page = _page;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    setState(() => _downloadClient = client);
    try {
      final store = await RecitationStore.open();
      await store.downloadPage(
        MushafLibrary.pages[page]!.map((entry) => entry.verse),
        client,
      );
      if (mounted) {
        _audioStatus(
          'تم حفظ تلاوة الصفحة على الجهاز.',
          'Page recitation saved on this device.',
        );
      }
    } catch (_) {
      if (mounted) {
        _audioStatus(
          'تعذّر التحميل. جرّب عند توفر الإنترنت.',
          'Download unavailable. Try again when connected.',
        );
      }
    } finally {
      client.close(force: true);
      if (mounted) setState(() => _downloadClient = null);
    }
  }

  void _audioStatus(String arabic, String english) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(appText(context, arabic, english))));

  Future<void> _listen() async {
    final token = ++_playback;
    if (_playing) {
      setState(() => _playing = false);
      await _recitation?.stop();
      return;
    }
    final page = _page;
    final title = appText(
      context,
      'تلاوة المصحف • صفحة $page',
      'Quran recitation • Page $page',
    );
    final entries = MushafLibrary.pages[page]!;
    setState(() => _playing = true);
    try {
      final store = await RecitationStore.open();
      final sources = <AudioSource>[];
      for (final entry in entries) {
        final file = await store.savedFileFor(entry.verse);
        if (file != null) {
          sources.add(AudioSource.file(file.path));
        } else if (entry.verse.audio.startsWith('https://')) {
          sources.add(AudioSource.uri(Uri.parse(entry.verse.audio)));
        }
      }
      if (sources.isEmpty || !mounted || token != _playback) return;
      final player = await RecitationPlayback.instance;
      if (!mounted || token != _playback) return;
      _recitation = player;
      await player.preparePage(page: page, title: title, sources: sources);
      if (!mounted || token != _playback) return;
      await _recitationState?.cancel();
      if (!mounted || token != _playback) return;
      _recitationState = player.playbackState.listen((state) {
        if (mounted &&
            token == _playback &&
            _playing &&
            state.processingState == AudioProcessingState.idle &&
            !player.hasPage) {
          setState(() => _playing = false);
        }
      });
      await player.play();
    } catch (_) {
      if (mounted && token == _playback) {
        await _recitation?.stop();
        if (mounted && token == _playback) {
          _audioStatus(
            'تعذّر تشغيل التلاوة. حمّل الصوت عند توفر الإنترنت.',
            'Recitation unavailable. Download the audio when connected.',
          );
        }
      }
    } finally {
      if (mounted && token == _playback && _recitation?.hasPage != true) {
        setState(() => _playing = false);
      }
    }
  }

  @override
  void dispose() {
    _pages?.dispose();
    _downloadClient?.close(force: true);
    unawaited(_recitationState?.cancel());
    if (_playing) unawaited(_recitation?.stop());
    super.dispose();
  }

  Future<void> _cycleTheme() async {
    final next = switch (_settings.readingTheme) {
      'light' => 'cream',
      'cream' => 'dark',
      _ => 'light',
    };
    await MushafSettings.setReadingTheme(next);
    if (mounted) {
      setState(() {
        _settings = _settings.copyWith(
          readingTheme: next,
          darkMode: next == 'dark',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      final ready = _pages != null;
      final appTheme = Theme.of(context);
      final readerTheme = ready
          ? AppTheme.readingTheme(appTheme, _settings.readingTheme)
          : appTheme;
      final screen = Builder(
        builder: (context) => _readerScaffold(
          context,
          ready: ready,
          hasError: snapshot.hasError,
          appIsDark: appTheme.brightness == Brightness.dark,
        ),
      );
      return Theme(data: readerTheme, child: screen);
    },
  );

  Widget _readerScaffold(
    BuildContext context, {
    required bool ready,
    required bool hasError,
    required bool appIsDark,
  }) {
    return Scaffold(
      appBar: _showBars
          ? AppBar(
              leadingWidth: 48,
              titleSpacing: 4,
              title: FittedBox(
                alignment: AlignmentDirectional.centerStart,
                fit: BoxFit.scaleDown,
                child: Text(appText(context, 'المصحف', 'Mushaf')),
              ),
              actions: [
                if (ready) ...[
                  // زر ملء الشاشة للقراءة الممتعة والمستمرة
                  IconButton(
                    tooltip: appText(
                      context,
                      'ملء الشاشة للقراءة',
                      'Full screen reading',
                    ),
                    icon: const Icon(Icons.fullscreen_rounded),
                    onPressed: _toggleReadingBars,
                  ),
                  // زر ضبط مظهر القراءة وحجم الخط المباشر
                  IconButton(
                    tooltip: appText(
                      context,
                      'خيارات الخط والمظهر',
                      'Appearance & font',
                    ),
                    icon: const Icon(Icons.format_size_rounded),
                    onPressed: () =>
                        _openQuickAppearance(context, appIsDark: appIsDark),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'theme') {
                        await _cycleTheme();
                      } else if (action == 'bookmarks') {
                        await _openSaved(context, bookmarks: true);
                      } else if (action == 'history') {
                        await _openSaved(context, bookmarks: false);
                      } else if (action == 'download') {
                        await _downloadAudio();
                      } else if (action == 'audio') {
                        await _listen();
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const MushafSettingsScreen(),
                          ),
                        );
                        if (!mounted) return;
                        final updated = await MushafSettings.getAllSettings();
                        if (mounted) setState(() => _settings = updated);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'bookmarks',
                        child: Text(
                          appText(context, 'العلامات المرجعية', 'Bookmarks'),
                        ),
                      ),
                      if (!appIsDark)
                        PopupMenuItem(
                          value: 'theme',
                          child: Text(switch (_settings.readingTheme) {
                            'dark' => appText(
                              context,
                              'الوضع النهاري',
                              'Light theme',
                            ),
                            'cream' => appText(
                              context,
                              'الوضع الليلي',
                              'Dark theme',
                            ),
                            _ => appText(
                              context,
                              'الوضع الورقي الدافئ',
                              'Warm paper theme',
                            ),
                          }),
                        ),
                      PopupMenuItem(
                        value: 'history',
                        child: Text(
                          appText(context, 'سجل القراءة', 'Reading history'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        child: Text(
                          appText(context, 'ضبط القراءة', 'Reading settings'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'audio',
                        child: Text(
                          _playing
                              ? appText(
                                  context,
                                  'إيقاف التلاوة',
                                  'Stop recitation',
                                )
                              : appText(
                                  context,
                                  'استمع للتلاوة',
                                  'Play recitation',
                                ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'download',
                        enabled: _downloadClient == null,
                        child: Text(
                          _downloadClient == null
                              ? appText(
                                  context,
                                  'حمّل صوت الصفحة',
                                  'Download page audio',
                                )
                              : appText(context, 'جارٍ التحميل', 'Downloading'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          : null,
      body: SafeArea(
        top: !_showBars,
        bottom: !ready || !_showBars,
        child: hasError
            ? Center(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _initialization = _load();
                  }),
                  child: Text(
                    appText(context, 'إعادة تحميل المصحف', 'Reload Quran'),
                  ),
                ),
              )
            : !ready
            ? const ListSkeleton(rows: 7)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_showBars)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextButton.icon(
                          onPressed: _toggleReadingBars,
                          icon: const Icon(Icons.fullscreen_exit_rounded),
                          label: Text(
                            appText(context, 'إظهار الأشرطة', 'Show bars'),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SelectionArea(
                      child: ContentFrame(
                        maxWidth: 780,
                        child: PageView.builder(
                          controller: _pages,
                          itemCount: _pageCount,
                          onPageChanged: (index) {
                            if (_page == index + 1) return;
                            setState(() {
                              _page = index + 1;
                              _anchorSurah = null;
                              _anchorVerse = null;
                              _initialScroll = 0;
                              _playing = false;
                            });
                            _playback++;
                            unawaited(_recitation?.stop());
                            _remember(_page);
                          },
                          itemBuilder: (context, index) =>
                              _buildPage(context, index + 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: ready && _showBars ? _readerControls(context) : null,
    );
  }

  Widget _readerControls(BuildContext context) => SafeArea(
    top: false,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: appText(context, 'الصفحة السابقة', 'Previous page'),
          onPressed: _page > 1 ? () => _jump(_page - 1) : null,
          icon: Icon(
            appChevron(context, backwards: true),
          ),
        ),
        Flexible(
          child: TextButton(
            onPressed: () => _choosePage(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: Text(
              appText(
                context,
                'صفحة $_page من $_pageCount',
                'Page $_page of $_pageCount',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          tooltip: appText(context, 'الصفحة التالية', 'Next page'),
          onPressed: _page < _pageCount ? () => _jump(_page + 1) : null,
          icon: Icon(appChevron(context)),
        ),
        IconButton(
          tooltip: appText(context, 'احفظ الصفحة', 'Bookmark page'),
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () async {
            final page = _page;
            await ReadingPositionManager.addBookmark(
              page,
              appText(context, 'صفحة $page', 'Page $page'),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appText(context, 'تم حفظ العلامة', 'Bookmark saved'),
                  ),
                ),
              );
            }
          },
        ),
      ],
    ),
  );

  static const _surahBannerHeight = 44.0;

  static EdgeInsets _surahBannerMargin(bool firstOnPage) =>
      EdgeInsets.only(top: firstOnPage ? 0 : 10, bottom: 8);

  Widget _buildSurahBanner({
    required BuildContext context,
    required Surahs surah,
    required Color gold,
    required bool isFirstOnPage,
    required Key? key,
  }) => Padding(
    key: key,
    padding: _surahBannerMargin(isFirstOnPage),
    child: Container(
      height: _surahBannerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: gold.withValues(alpha: .45)),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            Text(
              surah.name,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: gold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              appText(
                context,
                'آيَاتُهَا ${_arabicDigits(surah.ayahs.length)}',
                '${surah.ayahs.length} verses',
              ),
              style: TextStyle(fontSize: 12, color: gold),
            ),
          ],
        ),
      ),
    ),
  );

  /// شريط رأس الصفحة القرآني الأنيق - مستوحى من مصحف المدينة النبوية
  Widget _pageHeader(
    BuildContext context,
    int page,
    List<({Surahs surah, Ayahs verse})> entries,
    ColorScheme scheme,
  ) {
    // في المصحف الحقيقي: الصفحتان الافتتاحيتان (الفاتحة وبداية البقرة)
    // لا تحتويان على شريط رأس في الأعلى؛ الترويسة الزخرفية للسورة هي العنوان الأوحد.
    if (page <= 2) {
      return const SizedBox.shrink();
    }

    final first = entries.first;
    // إذا كانت الصفحة تبدأ بسورة جديدة (الآية 1)، لا نكرر اسم السورة في الشريط العلوي
    // منعاً للتكرار المزدوج الذي نهى عنه المستخدم، وتماشياً مع مصحف المدينة
    final startsWithNewSurah = first.verse.numberInSurah == 1;
    final juz = first.verse.juz;
    final isDark = scheme.brightness == Brightness.dark;
    final gold = isDark ? AppTheme.gold : const Color(0xFF8C642B);
    final border = scheme.outlineVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        border: Border(bottom: BorderSide(color: border, width: 0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // يمين: اسم السورة بالخط العثماني (إذا لم تكن السورة تبدأ في رأس الصفحة)
          Flexible(
            child: startsWithNewSurah
                ? Text(
                    '— ❖ —',
                    style: TextStyle(
                      fontSize: 11,
                      color: gold.withValues(alpha: 0.5),
                    ),
                  )
                : Text(
                    first.surah.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
          ),
          // حلية إسلامية في المنتصف
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '— ❖ —',
              style: TextStyle(
                fontSize: 10,
                color: gold.withValues(alpha: 0.55),
              ),
            ),
          ),
          // يسار: رقم الجزء
          Flexible(
            child: Text(
              appText(context, 'الجزء $juz', 'Juz $juz'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, int page) {
    if (_settings.printLayout && (_anchorVerse == null || page != _page)) {
      return PrintedMushafPage(
        key: ValueKey(page),
        page: page,
        warmPaper: _settings.readingTheme == 'cream',
        onTap: _toggleReadingBars,
      );
    }

    final entries = MushafLibrary.pages[page]!;
    final font = switch (_settings.fontFamily) {
      'Scheherazade' => 'Scheherazade New',
      'NotoNaskhArabic' => 'Noto Naskh Arabic',
      final family => family,
    };
    final scheme = Theme.of(context).colorScheme;
    final gold = scheme.brightness == Brightness.dark
        ? AppTheme.gold
        : const Color(0xFF8C642B);
    final opening = page == 1;
    final alignment = page <= 2 ? TextAlign.center : TextAlign.justify;
    final baseStyle = TextStyle(
      fontFamily: font,
      fontFamilyFallback: const ['Amiri'],
      fontSize: _settings.fontSize,
      height: _settings.lineHeight,
      color: scheme.onSurface,
    );

    final groups = <List<({Surahs surah, Ayahs verse})>>[];
    for (final entry in entries) {
      if (groups.isEmpty || entry.verse.numberInSurah == 1) groups.add([]);
      groups.last.add(entry);
    }
    final sections = [
      for (final group in groups)
        (
          surah: group.first.surah,
          startsSurah: group.first.verse.numberInSurah == 1,
          hasBasmala:
              group.first.verse.numberInSurah == 1 &&
              group.first.surah.number != 1 &&
              group.first.surah.number != 9 &&
              _settings.showBasmala,
          hasAnchor:
              page == _page &&
              _anchorSurah == null &&
              group.any((entry) => entry.verse.number == _anchorVerse),
          verses: TextSpan(
            children: [
              for (final (index, entry) in group.indexed) ...[
                TextSpan(
                  text: _verseText(
                    entry.verse.text,
                    entry.surah.number,
                    entry.verse.numberInSurah,
                  ),
                  style: entry.verse.number == _anchorVerse
                      ? TextStyle(backgroundColor: scheme.secondaryContainer)
                      : null,
                ),
                TextSpan(
                  text: '\u00A0﴿${_arabicDigits(entry.verse.numberInSurah)}﴾',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (index < group.length - 1)
                  TextSpan(text: opening ? '\n' : ' '),
              ],
            ],
          ),
        ),
    ];

    const basmalaPadding = 6.0;
    final basmala = TextSpan(text: MushafLibrary.basmala);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _pageHeader(context, page, entries, scheme),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleReadingBars,
            child: _MushafScroll(
              key: ValueKey(page),
              page: page,
              initialOffset: page == _page ? _initialScroll : 0,
              builder: (context, space) {
                var style = baseStyle;
                if (_settings.autoFit) {
                  var textHeight = space.height;
                  for (final (index, section) in sections.indexed) {
                    if (section.startsSurah) {
                      textHeight -=
                          _surahBannerHeight +
                          _surahBannerMargin(index == 0).vertical;
                    }
                    if (section.hasBasmala) textHeight -= basmalaPadding;
                  }
                  final defaults = DefaultTextStyle.of(context);
                  final fitted = fitMushafText(
                    style: defaults.style.merge(baseStyle),
                    textScaler: MediaQuery.textScalerOf(context),
                    textHeightBehavior: defaults.textHeightBehavior,
                    textAlign: alignment,
                    paragraphs: [
                      for (final section in sections) ...[
                        if (section.hasBasmala) basmala,
                        section.verses,
                      ],
                    ],
                    space: Size(space.width, textHeight),
                    opening: opening,
                  );
                  style = baseStyle.copyWith(
                    fontSize: fitted.fontSize! * _settings.fontScale,
                    height: fitted.height,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, section) in sections.indexed) ...[
                      if (section.startsSurah)
                        _buildSurahBanner(
                          context: context,
                          surah: section.surah,
                          gold: gold,
                          isFirstOnPage: index == 0,
                          key:
                              section.surah.number == _anchorSurah &&
                                  page == _page
                              ? _verseKey
                              : null,
                        ),
                      if (section.hasBasmala)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: basmalaPadding,
                          ),
                          child: Text.rich(
                            basmala,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: style.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      Text.rich(
                        section.verses,
                        key: section.hasAnchor ? _verseKey : null,
                        textAlign: alignment,
                        textDirection: TextDirection.rtl,
                        style: style,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// نافذة تخصيص القراءة السريعة والمباشرة
  Future<void> _openQuickAppearance(
    BuildContext context, {
    required bool appIsDark,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gold = isDark ? AppTheme.gold : const Color(0xFF8C642B);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final currentTheme = _settings.readingTheme;

          void updateFontSize(double size) {
            final value = size.clamp(
              MushafSettings.minFontSize,
              MushafSettings.maxFontSize,
            );
            setState(() => _settings = _settings.copyWith(fontSize: value));
            setSheetState(() {});
          }

          void stepFontSize(double step) {
            updateFontSize(_settings.fontSize + step);
            unawaited(MushafSettings.setFontSize(_settings.fontSize));
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شريط السحب والعنوان
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.tune_rounded, color: gold, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appText(
                              context,
                              'تخصيص القراءة',
                              'Reading appearance',
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    if (!appIsDark) ...[
                      // 1. سمة القراءة (نهاري - ورقي دافئ - ليلي)
                      Text(
                        appText(context, 'نمط العرض والسمة', 'Reading theme'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _themeCard(
                            context: context,
                            id: 'light',
                            title: appText(context, 'نهاري', 'Light'),
                            bg: const Color(0xFFFFFFFF),
                            border: const Color(0xFFD4AF37),
                            text: const Color(0xFF1E242B),
                            icon: Icons.light_mode_rounded,
                            selected: currentTheme == 'light',
                            onTap: () async {
                              await MushafSettings.setReadingTheme('light');
                              setState(() {
                                _settings = _settings.copyWith(
                                  readingTheme: 'light',
                                  darkMode: false,
                                );
                              });
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          _themeCard(
                            context: context,
                            id: 'cream',
                            title: appText(context, 'ورقي دافئ', 'Warm paper'),
                            bg: const Color(0xFFFAF6ED),
                            border: const Color(0xFFC79848),
                            text: const Color(0xFF22262E),
                            icon: Icons.auto_stories_rounded,
                            selected: currentTheme == 'cream',
                            onTap: () async {
                              await MushafSettings.setReadingTheme('cream');
                              setState(() {
                                _settings = _settings.copyWith(
                                  readingTheme: 'cream',
                                  darkMode: false,
                                );
                              });
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          _themeCard(
                            context: context,
                            id: 'dark',
                            title: appText(context, 'ليلي فاخر', 'Dark night'),
                            bg: AppTheme.night,
                            border: AppTheme.gold,
                            text: AppColors.textOnSurfaceDark,
                            icon: Icons.dark_mode_rounded,
                            selected: currentTheme == 'dark',
                            onTap: () async {
                              await MushafSettings.setReadingTheme('dark');
                              setState(() {
                                _settings = _settings.copyWith(
                                  readingTheme: 'dark',
                                  darkMode: true,
                                );
                              });
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                    ],

                    MushafLayoutSwitch(
                      printLayout: _settings.printLayout,
                      onChanged: (enabled) {
                        setState(() {
                          _settings = _settings.copyWith(printLayout: enabled);
                          if (enabled) _anchorVerse = null;
                        });
                        setSheetState(() {});
                        unawaited(MushafSettings.setPrintLayout(enabled));
                      },
                    ),

                    if (!_settings.printLayout) ...[
                      // 2. حجم الخط مع ملاءمة الصفحة للشاشة
                      Row(
                        children: [
                          Text(
                            appText(context, 'حجم الخط', 'Font size'),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: gold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _settings.fontSizeLabel,
                              style: TextStyle(
                                color: gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Text(
                              'A-',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed:
                                _settings.fontSize > MushafSettings.minFontSize
                                ? () => stepFontSize(-1)
                                : null,
                          ),
                          Expanded(
                            child: Slider(
                              value: _settings.fontSize.clamp(
                                MushafSettings.minFontSize,
                                MushafSettings.maxFontSize,
                              ),
                              min: MushafSettings.minFontSize,
                              max: MushafSettings.maxFontSize,
                              divisions:
                                  (MushafSettings.maxFontSize -
                                          MushafSettings.minFontSize)
                                      .toInt(),
                              activeColor: gold,
                              onChanged: updateFontSize,
                              onChangeEnd: MushafSettings.setFontSize,
                            ),
                          ),
                          IconButton.filledTonal(
                            icon: const Text(
                              'A+',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed:
                                _settings.fontSize < MushafSettings.maxFontSize
                                ? () => stepFontSize(1)
                                : null,
                          ),
                        ],
                      ),

                      // 3. خيار ملاءمة الصفحة للشاشة تلقائياً
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _settings.autoFit,
                        activeThumbColor: gold,
                        title: Text(
                          appText(
                            context,
                            'ملاءمة أسطر الصفحة للشاشة',
                            'Fit page lines to screen',
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          appText(
                            context,
                            'يكبّر الآيات حسب مساحة الشاشة. يمكنك التمرير بعد زيادة حجم الخط.',
                            'Fills the reading area. Scroll when you increase text size.',
                          ),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onChanged: (val) async {
                          await MushafSettings.setAutoFit(val);
                          setState(
                            () => _settings = _settings.copyWith(autoFit: val),
                          );
                          setSheetState(() {});
                        },
                      ),

                      const SizedBox(height: 8),

                      // 4. نوع الخط القرآني
                      Text(
                        appText(context, 'نوع الخط القرآني', 'Arabic font'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final font in MushafSettings.supportedFonts)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    MushafSettings.fontDisplayNames[font] ??
                                        font,
                                    style: TextStyle(
                                      fontFamily: font == 'Scheherazade'
                                          ? 'Scheherazade New'
                                          : font,
                                      fontSize: 14,
                                    ),
                                  ),
                                  selected: _settings.fontFamily == font,
                                  selectedColor: gold.withValues(alpha: 0.22),
                                  side: BorderSide(
                                    color: _settings.fontFamily == font
                                        ? gold
                                        : theme.colorScheme.outlineVariant,
                                  ),
                                  onSelected: (_) async {
                                    await MushafSettings.setFontFamily(font);
                                    setState(
                                      () => _settings = _settings.copyWith(
                                        fontFamily: font,
                                      ),
                                    );
                                    setSheetState(() {});
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _themeCard({
    required BuildContext context,
    required String id,
    required String title,
    required Color bg,
    required Color border,
    required Color text,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? border : Colors.grey.withValues(alpha: 0.3),
              width: selected ? 2.0 : 0.8,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: border.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? border : text.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 4),
                Icon(Icons.check_circle_rounded, size: 14, color: border),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _arabicDigits(int number) => number
      .toString()
      .split('')
      .map((digit) => '٠١٢٣٤٥٦٧٨٩'[int.parse(digit)])
      .join();

  String _verseText(String text, int surah, int verse) {
    final clean = text.replaceFirst('\uFEFF', '').trim();
    final basmala = MushafLibrary.basmala;
    if (surah != 1 && surah != 9 && verse == 1 && clean.startsWith(basmala)) {
      return clean.substring(basmala.length).trimLeft();
    }
    return clean;
  }
}

class _MushafScroll extends StatefulWidget {
  const _MushafScroll({
    super.key,
    required this.page,
    required this.initialOffset,
    required this.builder,
  });

  final int page;
  final double initialOffset;
  final Widget Function(BuildContext, Size) builder;

  @override
  State<_MushafScroll> createState() => _MushafScrollState();
}

class _MushafScrollState extends State<_MushafScroll> {
  late final _scroll = ScrollController(
    initialScrollOffset: widget.initialOffset,
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollEndNotification>(
        onNotification: (event) {
          if (event.depth == 0 && event.metrics.axis == Axis.vertical) {
            unawaited(
              ReadingPositionManager.saveScrollPosition(
                widget.page,
                event.metrics.pixels,
              ),
            );
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final gold = isDark ? AppTheme.gold : const Color(0xFF8C642B);

            const margin = EdgeInsets.fromLTRB(6, 4, 6, 4);
            const inset = EdgeInsets.fromLTRB(10, 8, 10, 8);
            final space = Size(
              (constraints.maxWidth - margin.horizontal - inset.horizontal)
                  .clamp(0.0, double.infinity),
              (constraints.maxHeight - margin.vertical - inset.vertical).clamp(
                0.0,
                double.infinity,
              ),
            );
            return SingleChildScrollView(
              controller: _scroll,
              physics: const ClampingScrollPhysics(),
              padding: margin,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: gold.withValues(alpha: isDark ? 0.22 : 0.16),
                    width: 0.8,
                  ),
                ),
                child: Padding(
                  padding: inset,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: space.height),
                    child: widget.builder(context, space),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/widgets/tamanina_ui.dart';

/// Arguments for navigating to [AdhanScreen].
class AdhanScreenArgs {
  const AdhanScreenArgs({
    this.prayerNameArabic = 'الصلاة',
    this.prayerName = 'Prayer',
    this.isFajr = false,
  });

  final String prayerNameArabic;
  final String prayerName;
  final bool isFajr;
}

// ─────────────────────────── Adhan Phrase Data ───────────────────────────────

class _AdhanPhrase {
  const _AdhanPhrase({
    required this.arabic,
    required this.transliteration,
    required this.startSec,
    required this.endSec,
  });

  final String arabic;
  final String transliteration;
  final double startSec;
  final double endSec;

  List<String> get words =>
      arabic.split(' ').where((w) => w.trim().isNotEmpty).toList();

  double get duration => (endSec - startSec).clamp(0.1, 999.0);
}

// Timestamps synchronized with assets/audio/adhan/adhan_local.mp3 (154.02 seconds)
const _standardAdhanPhrases = [
  _AdhanPhrase(
    arabic: 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar, Allahu Akbar',
    startSec: 0.0,
    endSec: 16.5,
  ),
  _AdhanPhrase(
    arabic: 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar, Allahu Akbar',
    startSec: 17.5,
    endSec: 30.8,
  ),
  _AdhanPhrase(
    arabic: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ',
    transliteration: 'Ashhadu an la ilaha illa Allah',
    startSec: 31.5,
    endSec: 43.0,
  ),
  _AdhanPhrase(
    arabic: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ',
    transliteration: 'Ashhadu an la ilaha illa Allah',
    startSec: 43.7,
    endSec: 57.5,
  ),
  _AdhanPhrase(
    arabic: 'أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
    transliteration: 'Ashhadu anna Muhammadan rasulullah',
    startSec: 58.5,
    endSec: 69.0,
  ),
  _AdhanPhrase(
    arabic: 'أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
    transliteration: 'Ashhadu anna Muhammadan rasulullah',
    startSec: 69.8,
    endSec: 81.5,
  ),
  _AdhanPhrase(
    arabic: 'حَيَّ عَلَى الصَّلَاةِ',
    transliteration: 'Hayya alas-salah',
    startSec: 82.5,
    endSec: 91.0,
  ),
  _AdhanPhrase(
    arabic: 'حَيَّ عَلَى الصَّلَاةِ',
    transliteration: 'Hayya alas-salah',
    startSec: 91.8,
    endSec: 101.5,
  ),
  _AdhanPhrase(
    arabic: 'حَيَّ عَلَى الْفَلَاحِ',
    transliteration: 'Hayya alal-falah',
    startSec: 102.2,
    endSec: 111.8,
  ),
  _AdhanPhrase(
    arabic: 'حَيَّ عَلَى الْفَلَاحِ',
    transliteration: 'Hayya alal-falah',
    startSec: 112.5,
    endSec: 122.5,
  ),
  _AdhanPhrase(
    arabic: 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar, Allahu Akbar',
    startSec: 123.2,
    endSec: 137.8,
  ),
  _AdhanPhrase(
    arabic: 'لَا إِلَهَ إِلَّا اللَّهُ',
    transliteration: 'La ilaha illa Allah',
    startSec: 138.2,
    endSec: 153.5,
  ),
];

// Fajr additions
const _fajrExtraPhrases = [
  _AdhanPhrase(
    arabic: 'الصَّلَاةُ خَيْرٌ مِنَ النَّوْمِ',
    transliteration: 'As-salatu khayrun min an-nawm',
    startSec: 122.8,
    endSec: 130.0,
  ),
  _AdhanPhrase(
    arabic: 'الصَّلَاةُ خَيْرٌ مِنَ النَّوْمِ',
    transliteration: 'As-salatu khayrun min an-nawm',
    startSec: 130.2,
    endSec: 138.0,
  ),
];

// ─────────────────────────── Star Field ──────────────────────────────────────

class _StarParticle {
  _StarParticle(math.Random rng)
    : x = rng.nextDouble(),
      y = rng.nextDouble(),
      r = rng.nextDouble() * 1.5 + 0.6,
      blink = rng.nextDouble() * math.pi * 2;

  final double x, y, r, blink;
}

class _StarField extends StatefulWidget {
  const _StarField({this.count = 70});
  final int count;

  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_StarParticle> _stars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(19);
    _stars = List.generate(widget.count, (_) => _StarParticle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        painter: _StarPainter(_stars, _ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.t);
  final List<_StarParticle> stars;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in stars) {
      final alpha = (0.25 + 0.75 * math.sin(s.blink + t * math.pi * 2)).clamp(
        0.0,
        1.0,
      );
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}

// ─────────────────────────── Full Screen Adhan ───────────────────────────────

class AdhanScreen extends StatefulWidget {
  const AdhanScreen({super.key, this.args = const AdhanScreenArgs()});

  final AdhanScreenArgs args;

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen>
    with TickerProviderStateMixin {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _duskDeep = AppColors.backgroundDark;
  static const _lanternAmber = AppColors.darkAccent;
  static const _goldLight = Color(0xFFFEDC8A);
  static const _ivory = AppColors.textOnSurfaceDark;

  // ── Audio ──────────────────────────────────────────────────────────────────
  final _player = AudioPlayer();
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;
  Duration _currentPos = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 154);
  bool _isPlaying = false;
  bool _audioLoaded = false;
  bool _loadingAudio = false;
  bool _audioError = false;
  bool _completed = false;

  // ── Phrases ────────────────────────────────────────────────────────────────
  late final List<_AdhanPhrase> _phrases;
  int _activePhraseIndex = 0;
  int _activeWordIndex = 0;
  final _scrollController = ScrollController();

  // ── Animation Controllers ──────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final AnimationController _crescentCtrl;

  @override
  void initState() {
    super.initState();

    // Prepare phrase list
    if (widget.args.isFajr) {
      final list = List<_AdhanPhrase>.from(_standardAdhanPhrases);
      list.insertAll(list.length - 2, _fajrExtraPhrases);
      _phrases = list;
    } else {
      _phrases = _standardAdhanPhrases;
    }

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _crescentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initAudio();
  }

  Future<void> _initAudio() async {
    if (_loadingAudio) return;
    _loadingAudio = true;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      final duration = await _player.setAsset(AdhanSound.local.assetPath);
      if (sl.isRegistered<SettingsRepository>()) {
        await _player.setVolume(
          sl<SettingsRepository>().currentSettings.adhanVolume,
        );
      }
      if (!mounted) return;
      if (duration != null) {
        _totalDuration = duration;
      }
      setState(() {
        _audioLoaded = true;
        _audioError = false;
      });

      _posSub ??= _player.positionStream.listen(_onPositionUpdated);
      _stateSub ??= _player.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _completed = true;
          }
        });
      });

      await _player.play();
    } catch (_) {
      if (mounted) {
        setState(() {
          _audioLoaded = false;
          _audioError = true;
        });
      }
    } finally {
      _loadingAudio = false;
    }
  }

  void _onPositionUpdated(Duration pos) {
    if (!mounted) return;
    final sec = pos.inMilliseconds / 1000.0;
    _currentPos = pos;

    // Find active phrase
    int phraseIdx = 0;
    for (int i = 0; i < _phrases.length; i++) {
      if (sec >= _phrases[i].startSec) {
        phraseIdx = i;
      }
    }

    // Find active word inside active phrase
    final curPhrase = _phrases[phraseIdx];
    final words = curPhrase.words;
    int wordIdx = 0;
    if (words.isNotEmpty) {
      final elapsed = (sec - curPhrase.startSec).clamp(0.0, curPhrase.duration);
      final ratio = elapsed / curPhrase.duration;
      wordIdx = (ratio * words.length).floor().clamp(0, words.length - 1);
    }

    final phraseChanged = phraseIdx != _activePhraseIndex;
    final wordChanged = wordIdx != _activeWordIndex;

    if (phraseChanged || wordChanged) {
      setState(() {
        _activePhraseIndex = phraseIdx;
        _activeWordIndex = wordIdx;
      });

      if (phraseChanged) {
        _pulseCtrl.forward(from: 0.0);
        _autoScroll(phraseIdx);
        HapticFeedback.lightImpact();
      }
    }
  }

  void _autoScroll(int index) {
    if (!_scrollController.hasClients) return;
    const itemHeight = 72.0;
    final target = (index * itemHeight) - 80.0;
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _togglePlayPause() async {
    if (!_audioLoaded) {
      await _initAudio();
    } else if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _dismiss() async {
    try {
      await _player.stop();
    } catch (_) {}
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    _scrollController.dispose();
    _pulseCtrl.dispose();
    _crescentCtrl.dispose();
    super.dispose();
  }

  // ── Formatters ─────────────────────────────────────────────────────────────

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── UI Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _dismiss();
        },
        child: Scaffold(
          backgroundColor: _duskDeep,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Atmospheric night sky gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundDark,
                      AppColors.surfaceDark,
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
              ),

              // Twinkling stars
              const _StarField(count: 85),

              // Ambient golden dome glow at the bottom
              Positioned(
                bottom: -100,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _crescentCtrl,
                  builder: (_, _) {
                    final opacity = 0.12 + 0.08 * _crescentCtrl.value;
                    return Container(
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _lanternAmber.withValues(alpha: opacity),
                            blurRadius: 160,
                            spreadRadius: 40,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 12),
                    _buildPrayerBanner(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _completed
                          ? _buildDuaAfterAdhan()
                          : _buildRecitationSection(),
                    ),
                    const SizedBox(height: 12),
                    _buildAudioControls(),
                    const SizedBox(height: 16),
                    _buildBottomDismissButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header & Banner ────────────────────────────────────────────────────────

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _lanternAmber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '✦',
                    style: TextStyle(color: _lanternAmber, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                appText(
                  context,
                  'طَمَأْنِينَة • الأذان المبارك',
                  'Tamanina • Blessed Adhan',
                ),
                style: const TextStyle(
                  color: _goldLight,
                  fontSize: 15,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Dismiss (✕) icon button
          GestureDetector(
            onTap: _dismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.close, color: _ivory, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerBanner() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _crescentCtrl,
          builder: (_, _) {
            final scale = 1.0 + 0.05 * _crescentCtrl.value;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _lanternAmber.withValues(
                        alpha: 0.25 + 0.15 * _crescentCtrl.value,
                      ),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '☽',
                    style: TextStyle(
                      fontSize: 54,
                      color: _lanternAmber,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          appText(
            context,
            'أَذَان ${widget.args.prayerNameArabic}',
            'Adhan ${widget.args.prayerName}',
          ),
          style: const TextStyle(
            color: _lanternAmber,
            fontSize: 26,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          appText(
            context,
            'حَانَ الْآن وَقْتُ الصَّلَاة',
            'It is now prayer time',
          ),
          style: TextStyle(
            color: _ivory.withValues(alpha: 0.65),
            fontSize: 13,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  // ── Recitation with Word-by-Word Highlight ─────────────────────────────────

  Widget _buildRecitationSection() {
    final curPhrase = _phrases[_activePhraseIndex];
    final words = curPhrase.words;

    return Column(
      children: [
        // Live Word-by-Word Focus Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.surfaceDarkRaised.withValues(alpha: 0.85),
            border: Border.all(
              color: _lanternAmber.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _lanternAmber.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Ornament badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 1,
                    color: _lanternAmber.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '✦',
                    style: TextStyle(color: _lanternAmber, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_activePhraseIndex + 1} / ${_phrases.length}',
                    style: const TextStyle(
                      color: _lanternAmber,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '✦',
                    style: TextStyle(color: _lanternAmber, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 1,
                    color: _lanternAmber.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // The animated words (karaoke style)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 10,
                children: List.generate(words.length, (wIdx) {
                  final isRecited = wIdx < _activeWordIndex;
                  final isCurrent = wIdx == _activeWordIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCurrent ? 10 : 4,
                      vertical: isCurrent ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isCurrent
                          ? _lanternAmber.withValues(alpha: 0.22)
                          : Colors.transparent,
                      border: isCurrent
                          ? Border.all(
                              color: _lanternAmber.withValues(alpha: 0.6),
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Text(
                      words[wIdx],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: isCurrent ? 26 : 22,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isCurrent
                            ? _goldLight
                            : isRecited
                            ? _ivory
                            : _ivory.withValues(alpha: 0.4),
                        shadows: isCurrent
                            ? [
                                Shadow(
                                  color: _lanternAmber.withValues(alpha: 0.8),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              // Transliteration
              Text(
                curPhrase.transliteration,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ivory.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Auto-scrolling full playlist of Adhan phrases
        Expanded(
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.1, 0.9, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _phrases.length,
              itemBuilder: (context, index) {
                final p = _phrases[index];
                final isActive = index == _activePhraseIndex;
                final isDone = index < _activePhraseIndex;

                return GestureDetector(
                  onTap: () {
                    if (_audioLoaded) {
                      _player.seek(
                        Duration(milliseconds: (p.startSec * 1000).toInt()),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isActive
                          ? _lanternAmber.withValues(alpha: 0.15)
                          : isDone
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.transparent,
                      border: Border.all(
                        color: isActive
                            ? _lanternAmber.withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Indicator dot or checkmark
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? _lanternAmber
                                : isDone
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                          child: Center(
                            child: isActive
                                ? const Icon(
                                    Icons.volume_up,
                                    size: 13,
                                    color: _duskDeep,
                                  )
                                : isDone
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: _ivory,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _ivory.withValues(alpha: 0.4),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Phrase text
                        Expanded(
                          child: Text(
                            p.arabic,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: isActive ? 18 : 15,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isActive
                                  ? _goldLight
                                  : isDone
                                  ? _ivory.withValues(alpha: 0.75)
                                  : _ivory.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Dua After Adhan (Displayed when completed) ────────────────────────────

  Widget _buildDuaAfterAdhan() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppColors.surfaceDarkRaised.withValues(alpha: 0.9),
            border: Border.all(
              color: _lanternAmber.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _lanternAmber.withValues(alpha: 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _lanternAmber.withValues(alpha: 0.15),
                ),
                child: Text(
                  appText(
                    context,
                    'دُعَاءُ مَا بَعْدَ الأَذَان',
                    'Supplication After Adhan',
                  ),
                  style: const TextStyle(
                    color: _lanternAmber,
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ»',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ivory,
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appText(
                  context,
                  'حَلَّتْ لَهُ شَفَاعَتِي يَوْمَ الْقِيَامَةِ (صحيح البخاري)',
                  'Whoever says this, my intercession becomes guaranteed for him (Sahih Bukhari)',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ivory.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 20),
              // Repeat button
              GestureDetector(
                onTap: () {
                  setState(() => _completed = false);
                  _player.seek(Duration.zero);
                  _player.play();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _lanternAmber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.replay, size: 16, color: _lanternAmber),
                      const SizedBox(width: 8),
                      Text(
                        appText(
                          context,
                          'إعادة الاستماع للأذان',
                          'Replay Adhan',
                        ),
                        style: const TextStyle(
                          color: _lanternAmber,
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Audio Controls & Progress ──────────────────────────────────────────────

  Widget _buildAudioControls() {
    final progress = _totalDuration.inMilliseconds > 0
        ? (_currentPos.inMilliseconds / _totalDuration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          if (_audioError)
            Text(
              appText(
                context,
                'تعذّر تشغيل الأذان. اضغط تشغيل للمحاولة تاني.',
                'Adhan could not play. Tap play to retry.',
              ),
            ),
          // Slider and time
          Row(
            children: [
              Text(
                _formatDuration(_currentPos),
                style: TextStyle(
                  color: _ivory.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: _lanternAmber,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                    thumbColor: _lanternAmber,
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: (val) {
                      final targetMs = (val * _totalDuration.inMilliseconds)
                          .toInt();
                      _player.seek(Duration(milliseconds: targetMs));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  color: _ivory.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),

          // Control buttons: Mute / Play-Pause / Forward 10s
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 10s
              IconButton(
                icon: const Icon(Icons.replay_10, color: _ivory, size: 22),
                onPressed: () {
                  final target = _currentPos - const Duration(seconds: 10);
                  _player.seek(target < Duration.zero ? Duration.zero : target);
                },
              ),
              const SizedBox(width: 16),
              // Play/Pause
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lanternAmber,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _duskDeep,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Forward 10s
              IconButton(
                icon: const Icon(Icons.forward_10, color: _ivory, size: 22),
                onPressed: () {
                  final target = _currentPos + const Duration(seconds: 10);
                  _player.seek(
                    target > _totalDuration ? _totalDuration : target,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dismiss Button ─────────────────────────────────────────────────────────

  Widget _buildBottomDismissButton() {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close, color: _ivory, size: 18),
              const SizedBox(width: 8),
              Text(
                appText(context, 'إغلاق الأذان', 'Dismiss Adhan'),
                style: const TextStyle(
                  color: _ivory,
                  fontSize: 16,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

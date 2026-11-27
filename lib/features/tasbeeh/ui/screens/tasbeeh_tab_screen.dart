import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/home_widgets_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../statistics/data/worship_activity.dart';

class TasbeehTabScreen extends StatefulWidget {
  const TasbeehTabScreen({super.key});

  @override
  State<TasbeehTabScreen> createState() => _TasbeehTabScreenState();
}

class _TasbeehTabScreenState extends State<TasbeehTabScreen> {
  static const _phrases = [
    ('سُبْحَانَ اللَّهِ', 'Glory be to Allah', 33),
    ('الْحَمْدُ لِلَّهِ', 'Praise be to Allah', 33),
    ('اللَّهُ أَكْبَرُ', 'Allah is the Greatest', 34),
  ];
  // Single-phrase counters: Arabic, English, target (0 = no target).
  static const _presets = [
    ('لَا إِلَٰهَ إِلَّا اللَّهُ', 'There is no god but Allah', 100),
    ('أَسْتَغْفِرُ اللَّهَ', 'I seek Allah’s forgiveness', 100),
    (
      'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      'Send blessings on the Prophet ﷺ',
      100,
    ),
    ('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'Glory and praise be to Allah', 100),
    (
      'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'There is no power but with Allah',
      100,
    ),
    ('عَدّاد حُرّ', 'Free counter', 0),
  ];
  static const _modeKey = 'tasbeeh_mode';
  late final SharedPreferences _prefs;
  // -1 is the three-stage tasbeeh; 0.. are the single-phrase counters above.
  int _mode = -1;
  int _presetCount = 0;
  int _presetRounds = 0;
  int _today = 0;
  int _lifetime = 0;
  int _count = 0;
  int _phrase = 0;
  int _cycles = 0;
  bool? _vibration;
  Offset? _buttonAnchor;

  @override
  void initState() {
    super.initState();
    _prefs = sl<SharedPreferences>();
    final saved = _prefs.getStringList(AppConstants.prefKeyTasbeehProgress);
    if (saved != null && saved.length == 3) {
      _phrase = (int.tryParse(saved[0]) ?? 0).clamp(0, _phrases.length - 1);
      _count = (int.tryParse(saved[1]) ?? 0).clamp(0, _phrases[_phrase].$3 - 1);
      _cycles = (int.tryParse(saved[2]) ?? 0).clamp(0, 1 << 30);
    }
    _mode = (_prefs.getInt(_modeKey) ?? -1).clamp(-1, _presets.length - 1);
    _loadPreset();
    _lifetime = _prefs.getInt('tasbeeh_lifetime') ?? 0;
    _today = _prefs.getString('tasbeeh_day') == _dayKey()
        ? (_prefs.getInt('tasbeeh_today') ?? 0)
        : 0;
    _vibration = _prefs.getBool('tasbeeh_vibration');
    final x = _prefs.getDouble('tasbeeh_button_x');
    final y = _prefs.getDouble('tasbeeh_button_y');
    if (x != null && y != null) _buttonAnchor = Offset(x, y);
  }

  static String _dayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  bool get _sequence => _mode < 0;

  void _loadPreset() {
    if (_sequence) return;
    final saved = _prefs.getStringList('tasbeeh_preset_$_mode');
    _presetCount = int.tryParse(saved?.elementAtOrNull(0) ?? '') ?? 0;
    _presetRounds = int.tryParse(saved?.elementAtOrNull(1) ?? '') ?? 0;
  }

  void _tally(int delta) {
    _today = (_today + delta).clamp(0, 1 << 30);
    _lifetime = (_lifetime + delta).clamp(0, 1 << 30);
    unawaited(_prefs.setString('tasbeeh_day', _dayKey()));
    unawaited(_prefs.setInt('tasbeeh_today', _today));
    unawaited(_prefs.setInt('tasbeeh_lifetime', _lifetime));
  }

  void _selectMode(int mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _loadPreset();
    });
    unawaited(_prefs.setInt(_modeKey, mode));
  }

  /// Takes back the last count.
  void _undo() {
    if (_sequence) {
      if (_count > 0) {
        setState(() => _count--);
        _tally(-1);
        _save();
      }
    } else if (_presetCount > 0) {
      setState(() => _presetCount--);
      _tally(-1);
      _savePreset();
    }
  }

  void _savePreset() => unawaited(
    _prefs.setStringList('tasbeeh_preset_$_mode', [
      '$_presetCount',
      '$_presetRounds',
    ]),
  );

  void _incrementPreset(bool vibration) {
    final target = _presets[_mode].$3;
    final reached = target > 0 && _presetCount + 1 == target;
    setState(() {
      if (reached) {
        _presetCount = 0;
        _presetRounds++;
      } else {
        _presetCount++;
      }
    });
    _tally(1);
    _savePreset();
    unawaited(WorshipLog.record(WorshipActivity.tasbeeh));
    if (vibration) {
      if (reached) {
        HapticFeedback.heavyImpact();
        Future<void>.delayed(
          const Duration(milliseconds: 140),
          HapticFeedback.heavyImpact,
        );
      } else if (target > 0 && (_presetCount + 1) % 10 == 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    if (reached) unawaited(_showRoundComplete(rounds: _presetRounds));
  }

  void _save() {
    unawaited(
      _prefs.setStringList(AppConstants.prefKeyTasbeehProgress, [
        '$_phrase',
        '$_count',
        '$_cycles',
      ]),
    );
    if (sl.isRegistered<HomeWidgetsService>()) {
      sl<HomeWidgetsService>().publishTasbeeh(_count);
    }
  }

  void _increment(bool vibration) {
    if (!_sequence) return _incrementPreset(vibration);
    final targetReached = _count + 1 == _phrases[_phrase].$3;
    setState(() {
      if (targetReached) {
        _count = 0;
        _phrase = (_phrase + 1) % _phrases.length;
        if (_phrase == 0) _cycles++;
      } else {
        _count++;
      }
    });
    _tally(1);
    _save();
    unawaited(WorshipLog.record(WorshipActivity.tasbeeh));
    if (vibration) {
      if (targetReached) {
        HapticFeedback.heavyImpact();
        Future<void>.delayed(
          const Duration(milliseconds: 140),
          HapticFeedback.heavyImpact,
        );
      } else {
        HapticFeedback.lightImpact();
      }
    }
    if (!targetReached) return;
    if (_phrase == 0) {
      unawaited(_showRoundComplete());
    } else {
      final next = _phrases[_phrase].$1;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              appText(context, 'الذِّكر التالي: $next', 'Next: $next'),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  Future<void> _showRoundComplete({int? rounds}) async {
    final done = rounds ?? _cycles;
    await showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(appText(context, 'أكملت دورة تسبيح', 'Round completed')),
        content: Text(
          appText(
            context,
            'الدورات المكتملة: $done',
            'Completed rounds: $done',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              appText(context, 'متابعة التسبيح', 'Continue counting'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(appText(context, 'تصفير السبحة؟', 'Reset counter?')),
        content: Text(
          appText(
            context,
            'سيبدأ العد من أول دورة.',
            'The counter will return to the first round.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(appText(context, 'إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(appText(context, 'تصفير', 'Reset')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      if (_sequence) {
        _count = 0;
        _phrase = 0;
        _cycles = 0;
      } else {
        _presetCount = 0;
        _presetRounds = 0;
      }
    });
    _sequence ? _save() : _savePreset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (arabic, english, rawTarget) = _sequence
        ? _phrases[_phrase]
        : _presets[_mode];
    final target = rawTarget;
    final shown = _sequence ? _count : _presetCount;
    final rounds = _sequence ? _cycles : _presetRounds;
    final global = context
        .watch<SettingsCubit>()
        .currentSettings
        .vibrationEnabled;
    final vibration = global && (_vibration ?? true);
    final countLabel = target == 0
        ? appText(context, 'بدون هدف', 'No target')
        : appText(context, '$shown من $target', '$shown of $target');

    final scheme = theme.colorScheme;
    return ContentFrame(
      maxWidth: 600,
      child: LayoutBuilder(
        builder: (context, bounds) {
          const margin = 10.0;
          const buttonSize = 76.0;
          final travel = Offset(
            math.max(0, bounds.maxWidth - 2 * margin - buttonSize),
            math.max(0, bounds.maxHeight - 2 * margin - buttonSize),
          );
          final anchor =
              _buttonAnchor ??
              Offset(
                Directionality.of(context) == TextDirection.rtl ? 0 : 1,
                .96,
              );
          final point = Offset(
            margin + travel.dx * anchor.dx,
            margin + travel.dy * anchor.dy,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 108),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appText(
                            context,
                            'الدورة ${rounds + 1}',
                            'Round ${rounds + 1}',
                          ),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: appText(
                          context,
                          'تراجع عن آخر عدّة',
                          'Undo last count',
                        ),
                        icon: const Icon(Icons.undo),
                        onPressed: shown == 0 ? null : _undo,
                      ),
                      IconButton(
                        tooltip: appText(
                          context,
                          'تصفير السبحة',
                          'Reset counter',
                        ),
                        icon: Icon(
                          platformIcon(
                            context,
                            Icons.restart_alt,
                            CupertinoIcons.arrow_counterclockwise,
                          ),
                        ),
                        onPressed:
                            shown + (_sequence ? _phrase : 0) + rounds == 0
                            ? null
                            : _reset,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 310),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: _BeadsPainter(
                            total: target == 0 ? 33 : target,
                            count: target == 0 ? shown % 33 : shown,
                            active: scheme.secondary,
                            inactive: scheme.outlineVariant,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(38),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.surface,
                                border: Border.all(
                                  color: scheme.outlineVariant,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        arabic,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 27,
                                          height: 1.3,
                                        ),
                                      ),
                                      Text(
                                        '$shown',
                                        style: theme.textTheme.displaySmall,
                                      ),
                                      Text(
                                        countLabel,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (Localizations.localeOf(context).languageCode != 'ar')
                    Text(
                      english,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  if (_sequence)
                    Text(
                      appText(
                        context,
                        'المرحلة ${_phrase + 1} من 3',
                        'Stage ${_phrase + 1} of 3',
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 10),
                  if (_sequence)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final (index, phrase) in _phrases.indexed)
                          Semantics(
                            selected: index == _phrase,
                            child: Chip(
                              avatar: index < _phrase
                                  ? const Icon(Icons.check, size: 16)
                                  : null,
                              side: BorderSide(
                                color: index == _phrase
                                    ? scheme.secondary
                                    : scheme.outlineVariant,
                              ),
                              label: Text(
                                phrase.$1,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 19,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Text(
                    appText(context, 'اختر الذكر', 'Choose a dhikr'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ChoiceChip(
                        label: Text(
                          appText(
                            context,
                            'السبحة (٣٣ ٣٣ ٣٤)',
                            'Tasbeeh (33 33 34)',
                          ),
                        ),
                        selected: _sequence,
                        onSelected: (_) => _selectMode(-1),
                      ),
                      for (final (index, preset) in _presets.indexed)
                        ChoiceChip(
                          label: Text(
                            appText(
                              context,
                              preset.$3 == 0
                                  ? preset.$1
                                  : preset.$1.split(' ').take(3).join(' '),
                              preset.$2,
                            ),
                          ),
                          selected: _mode == index,
                          onSelected: (_) => _selectMode(index),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appText(
                      context,
                      'اليوم: $_today   •   الإجمالي: $_lifetime',
                      'Today: $_today   •   All time: $_lifetime',
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (target > 0)
                    LinearProgressIndicator(
                      value: shown / target,
                      semanticsLabel: countLabel,
                    ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      appText(context, 'اهتزاز مع التسبيح', 'Haptic feedback'),
                    ),
                    value: vibration,
                    onChanged: global
                        ? (value) {
                            setState(() => _vibration = value);
                            unawaited(
                              _prefs.setBool('tasbeeh_vibration', value),
                            );
                          }
                        : null,
                  ),
                  Text(
                    appText(
                      context,
                      'اضغط للعد، واسحب الزر للمكان المريح لك.',
                      'Tap to count. Drag the button to a comfortable spot.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: point.dx,
                top: point.dy,
                child: GestureDetector(
                  onPanUpdate: (event) {
                    double move(double current, double delta, double room) =>
                        room == 0
                        ? current
                        : (current + delta / room).clamp(0.0, 1.0);
                    final current = _buttonAnchor ?? anchor;
                    setState(() {
                      _buttonAnchor = Offset(
                        move(current.dx, event.delta.dx, travel.dx),
                        move(current.dy, event.delta.dy, travel.dy),
                      );
                    });
                  },
                  onPanEnd: (_) {
                    final position = _buttonAnchor;
                    if (position == null) return;
                    unawaited(
                      _prefs.setDouble('tasbeeh_button_x', position.dx),
                    );
                    unawaited(
                      _prefs.setDouble('tasbeeh_button_y', position.dy),
                    );
                  },
                  child: SizedBox.square(
                    dimension: buttonSize,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        elevation: 4,
                      ),
                      onPressed: () => _increment(vibration),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                platformIcon(
                                  context,
                                  Icons.touch_app_outlined,
                                  CupertinoIcons.hand_draw,
                                ),
                                size: 23,
                              ),
                              Text(appText(context, 'سبّح', 'Count')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BeadsPainter extends CustomPainter {
  const _BeadsPainter({
    required this.total,
    required this.count,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int count;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 11;
    final stroke = Paint()
      ..color = inactive
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, stroke);
    final bead = Paint();
    for (var i = 0; i < total; i++) {
      final angle = 2 * math.pi * i / total - math.pi / 2;
      bead.color = i < count ? active : inactive;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        i < count ? 4.8 : 3.6,
        bead,
      );
    }
  }

  @override
  bool shouldRepaint(_BeadsPainter oldDelegate) =>
      oldDelegate.total != total ||
      oldDelegate.count != count ||
      oldDelegate.active != active ||
      oldDelegate.inactive != inactive;
}

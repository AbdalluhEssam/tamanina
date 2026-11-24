import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tamanina_ui.dart';

abstract final class JourneyColors {
  static const background = AppColors.backgroundDark;
  static const gold = AppColors.darkAccent;
  static const bronze = Color(0xFFA9843E);
  static const ivory = AppColors.textOnSurfaceDark;
  static const muted = Color(0xFFA4B2AA);
  static const dot = Color(0xFF465B50);
  static const brandSurface = Color(0xFF322D1C);
  static const surface = Color(0xE610271E);
  static const border = Color(0x515E583C);
  static const highlightSurface = Color(0xFF4A361C);
  static const buttonInk = AppColors.onDarkAccent;
  static const light = Color(0xFFFFEBB1);
  static const glow = Color(0xFFF4A43E);
}

class OnboardingJourneyArt extends StatelessWidget {
  const OnboardingJourneyArt({
    super.key,
    required this.index,
    required this.asset,
    required this.controller,
  });

  final int index;
  final String asset;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          final height = box.maxHeight;
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final artSide = math.min(
            width * (index == 3 ? .90 : 1),
            height * (index == 3 ? .88 : .91),
          );
          final prayerDial = math.min(width * .39, height * .37);
          final beadsTop = height * .055;
          final beadsCenter = beadsTop + artSide * .34;
          final art = RepaintBoundary(child: _Artwork(asset: asset));

          return Stack(
            alignment: Alignment.topCenter,
            fit: StackFit.expand,
            children: [
              if (index < 2)
                Positioned.fill(
                  bottom: index == 1 ? height * .13 : 0,
                  child: art,
                )
              else
                Positioned(
                  top: index == 2 ? beadsTop : height - 40 - artSide,
                  width: artSide,
                  height: artSide,
                  child: art,
                ),
              RepaintBoundary(
                child: CustomPaint(
                  painter: _WavePainter(
                    index: index,
                    rtl: rtl,
                    scroll: controller,
                  ),
                ),
              ),
              if (index == 3) CustomPaint(painter: _CrescentPainter(rtl: rtl)),
              switch (index) {
                0 => Positioned(
                  bottom: height * .055,
                  child: _ScenePill(
                    icon: Icons.wb_twilight_rounded,
                    label: appText(context, 'الفجر', 'Fajr'),
                    value: '05:08',
                  ),
                ),
                1 => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: height * .21,
                      width: prayerDial,
                      height: prayerDial,
                      child: const _PrayerDial(),
                    ),
                    Positioned(
                      left: width < 350 ? 12 : 21,
                      right: width < 350 ? 12 : 21,
                      bottom: 35,
                      child: const _PrayerStrip(),
                    ),
                    Positioned(
                      bottom: -1,
                      child: _ScenePill(
                        icon: Icons.check_circle_outline_rounded,
                        label: appText(
                          context,
                          'يعمل بدون إنترنت',
                          'Works offline',
                        ),
                      ),
                    ),
                  ],
                ),
                2 => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: beadsCenter - artSide * .15,
                      width: artSide * .36,
                      height: artSide * .30,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('33', style: _number(artSide * .123)),
                          Text(
                            appText(context, 'تسبيحة', 'tasbeeh'),
                            style: const TextStyle(
                              color: JourneyColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Row(
                        children: [
                          _ScenePill(
                            icon: Icons.wb_sunny_outlined,
                            label: appText(
                              context,
                              'أذكار الصباح',
                              'Morning adhkar',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ScenePill(
                            icon: Icons.wb_twilight_rounded,
                            label: appText(
                              context,
                              'أذكار المساء',
                              'Evening adhkar',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _ => Positioned(
                  bottom: 0,
                  child: Row(
                    children: [
                      _SceneTile(
                        icon: Icons.auto_stories_outlined,
                        label: appText(context, 'القرآن', 'Quran'),
                      ),
                      const SizedBox(width: 8),
                      _SceneTile(
                        icon: Icons.layers_outlined,
                        label: appText(context, 'الأذكار', 'Adhkar'),
                      ),
                      const SizedBox(width: 8),
                      _SceneTile(
                        icon: Icons.spa_outlined,
                        label: appText(context, 'السكينة', 'Stillness'),
                      ),
                    ],
                  ),
                ),
              },
            ],
          );
        },
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (bounds) => const RadialGradient(
      radius: .72,
      center: Alignment(0, .05),
      colors: [Colors.white, Colors.white, Colors.transparent],
      stops: [0, .49, 1],
    ).createShader(bounds),
    child: ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0, .12, .77, 1],
      ).createShader(bounds),
      child: Image.asset(asset, fit: BoxFit.cover),
    ),
  );
}

TextStyle _number(double size) => TextStyle(
  fontFamily: 'Poppins',
  color: JourneyColors.gold,
  fontSize: size,
  fontWeight: FontWeight.w600,
  fontFeatures: const [FontFeature.tabularFigures()],
  height: 1.16,
);

class _PrayerDial extends StatelessWidget {
  const _PrayerDial();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.maxWidth;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: JourneyColors.background.withValues(alpha: .89),
            border: Border.all(color: JourneyColors.bronze),
            boxShadow: [
              BoxShadow(
                color: JourneyColors.gold.withValues(alpha: .13),
                blurRadius: 30,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: size * .18,
                  color: JourneyColors.gold,
                ),
                const SizedBox(height: 3),
                Text(
                  appText(context, 'المغرب', 'Maghrib'),
                  style: TextStyle(
                    color: JourneyColors.ivory,
                    fontSize: size * .126,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                Text(
                  appText(context, 'بعد 01:45', 'In 01:45'),
                  style: TextStyle(
                    color: JourneyColors.gold,
                    fontSize: size * .095,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip();

  static const _prayers = [
    ('الفجر', 'Fajr', '05:08'),
    ('الظهر', 'Dhuhr', '11:54'),
    ('العصر', 'Asr', '14:51'),
    ('المغرب', 'Maghrib', '18:36'),
    ('العشاء', 'Isha', '19:54'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: JourneyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JourneyColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            for (final (index, (arabic, english, time)) in _prayers.indexed)
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: index == 3 ? JourneyColors.highlightSurface : null,
                    borderRadius: BorderRadius.circular(12),
                    border: index == 3
                        ? Border.all(color: JourneyColors.bronze)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 2,
                    ),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            appText(context, arabic, english),
                            style: TextStyle(
                              color: index == 3
                                  ? JourneyColors.gold
                                  : JourneyColors.ivory,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          textDirection: TextDirection.ltr,
                          style: _number(11).copyWith(
                            color: index == 3
                                ? JourneyColors.gold
                                : JourneyColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScenePill extends StatelessWidget {
  const _ScenePill({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: JourneyColors.surface,
        shape: const StadiumBorder(
          side: BorderSide(color: JourneyColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: JourneyColors.gold, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: JourneyColors.ivory,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            if (value case final value?) ...[
              const SizedBox(width: 7),
              Text(value, textDirection: TextDirection.ltr, style: _number(11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SceneTile extends StatelessWidget {
  const _SceneTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: 67,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: JourneyColors.surface,
      border: Border.all(color: JourneyColors.border),
      borderRadius: BorderRadius.circular(19),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: JourneyColors.gold, size: 21),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: JourneyColors.ivory,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.index, required this.rtl, required this.scroll})
    : super(repaint: scroll);

  final int index;
  final bool rtl;
  final PageController scroll;

  // Each segment meets the next at the same height and tangent.
  static const _segments = [
    (.83, [(.23, .94, .76, .49, 1.0, .41)]),
    (.41, [(.24, .33, .38, .64, .65, .72), (.80, .76, .90, .74, 1.0, .68)]),
    (.68, [(.10, .62, .31, .14, .57, .13), (.72, .12, .84, .43, 1.0, .50)]),
    (.50, [(.16, .57, .29, .63, .50, .51), (.70, .40, .83, .20, 1.0, .21)]),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final (start, curves) = _segments[index];
    final path = Path()..moveTo(0, start * size.height);
    for (final (x1, y1, x2, y2, x, y) in curves) {
      path.cubicTo(
        x1 * size.width,
        y1 * size.height,
        x2 * size.width,
        y2 * size.height,
        x * size.width,
        y * size.height,
      );
    }
    if (rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final bounds = Offset.zero & size;
    final gradient = LinearGradient(
      colors: [
        index == 0
            ? JourneyColors.gold.withValues(alpha: .25)
            : JourneyColors.light,
        JourneyColors.light,
        index == 3
            ? JourneyColors.gold.withValues(alpha: .3)
            : JourneyColors.light,
      ],
      stops: const [0, .38, 1],
    ).createShader(bounds);
    canvas.drawPath(
      path,
      Paint()
        ..color = JourneyColors.glow.withValues(alpha: .64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.75,
    );

    final page = scroll.hasClients && scroll.position.hasContentDimensions
        ? (scroll.page ?? index.toDouble())
        : index.toDouble();
    final approach = ((page - 2.55) / .45).clamp(0.0, 1.0);
    final fraction = page - index + .5 + .43 * approach;
    if (fraction < 0 || fraction > 1) return;
    final metric = path.computeMetrics().single;
    final point = metric
        .getTangentForOffset(metric.length * fraction)
        ?.position;
    if (point == null) return;
    canvas.drawCircle(
      point,
      9,
      Paint()
        ..color = JourneyColors.glow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawCircle(point, 4.3, Paint()..color = JourneyColors.light);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.index != index ||
      oldDelegate.rtl != rtl ||
      oldDelegate.scroll != scroll;
}

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter({required this.rtl});

  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width * .132, size.height * .15);
    final center = Offset(size.width * .5, size.height * .51 - radius);
    final outline = Rect.fromCircle(center: center, radius: radius);
    final phase = Path.combine(
      PathOperation.difference,
      Path()..addOval(outline),
      Path()..addOval(
        Rect.fromCircle(
          center: center.translate(radius * (rtl ? -.46 : .46), -radius * .34),
          radius: radius * .92,
        ),
      ),
    );
    canvas.drawPath(
      phase,
      Paint()
        ..color = JourneyColors.glow.withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    canvas.drawPath(
      phase,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JourneyColors.light,
            JourneyColors.gold,
            JourneyColors.bronze,
          ],
        ).createShader(outline),
    );
    canvas.drawPath(
      phase,
      Paint()
        ..color = JourneyColors.light.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );
  }

  @override
  bool shouldRepaint(_CrescentPainter oldDelegate) => oldDelegate.rtl != rtl;
}

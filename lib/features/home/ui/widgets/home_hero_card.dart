import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/services/location_service.dart';
import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../prayer_times/ui/widgets/next_prayer_panel.dart';
import 'home_visuals.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    this.loading = false,
    this.onChangeCity,
    this.onOpenPrayerTimes,
    this.onPrayerReached,
  });

  final DailyPrayerTimes? prayerTimes;
  final PrayerTimeData? nextPrayer;
  final bool loading;
  final VoidCallback? onChangeCity;
  final VoidCallback? onOpenPrayerTimes;
  final VoidCallback? onPrayerReached;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final schedule = prayerTimes;
    final next = nextPrayer;
    final locale = Localizations.localeOf(context).languageCode;
    final date = schedule?.date ?? DateTime.now();
    final day = DateFormat.MMMMEEEEd(locale).format(date);
    final city = schedule?.cityName ?? '';
    final hasCity = city.isNotEmpty;
    final hijri = schedule?.hijriDate;

    final dateAndCity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: HomePalette.gold,
              size: 16,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hijri != null && hijri.isNotEmpty)
                    Text(
                      hijri,
                      style: theme.bodyMedium?.copyWith(
                        color: HomePalette.ivory,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  Text(
                    day,
                    style: theme.bodySmall?.copyWith(
                      color: HomePalette.mist,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        const Divider(height: 1, color: Color(0x4DAEC7B4)),
        TextButton.icon(
          onPressed: onChangeCity,
          style: TextButton.styleFrom(
            alignment: AlignmentDirectional.centerStart,
            foregroundColor: HomePalette.ivory,
            minimumSize: const Size(44, 44),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(
            Icons.place_outlined,
            size: 18,
            color: HomePalette.gold,
          ),
          label: Text(
            hasCity
                ? localizedCityName(city, arabic: locale == 'ar')
                : appText(context, 'اختر مدينتك', 'Choose your city'),
            style: theme.bodySmall?.copyWith(
              color: HomePalette.ivory,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
    final prayer = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              prayerIcon(next?.name ?? ''),
              size: 18,
              color: HomePalette.gold,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                appText(context, 'الصلاة القادمة', 'Next prayer'),
                style: theme.bodySmall?.copyWith(color: HomePalette.mist),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        if (next == null)
          Text(
            loading
                ? appText(
                    context,
                    'جارٍ حساب المواقيت',
                    'Calculating prayer times',
                  )
                : appText(
                    context,
                    'المواقيت حسب موقعك',
                    'Prayer times for your location',
                  ),
            style: theme.titleMedium?.copyWith(
              color: HomePalette.ivory,
              fontWeight: FontWeight.w700,
            ),
          )
        else ...[
          Text(
            appText(context, next.nameArabic, next.name),
            style: theme.titleLarge?.copyWith(
              color: HomePalette.ivory,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            alignment: AlignmentDirectional.centerStart,
            fit: BoxFit.scaleDown,
            child: Text(
              prayerClock(context, next.time),
              style: theme.headlineLarge?.copyWith(
                fontSize: 31,
                height: 1.22,
                color: HomePalette.gold,
                fontFamily: 'Poppins',
                fontFamilyFallback: const ['Cairo'],
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _HomeCountdown(time: next.time, onReached: onPrayerReached),
        ],
      ],
    );

    return HomePanel(
      background: HomePalette.deepGreen,
      border: const Color(0xFF345347),
      artwork: const HomeArt(
        'assets/images/home_prayer_dome.webp',
        mirrorInEnglish: true,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
            final useColumns = constraints.maxWidth >= 250 * scale;
            final nextPrayerAction = onOpenPrayerTimes == null
                ? prayer
                : InkWell(
                    onTap: onOpenPrayerTimes,
                    borderRadius: BorderRadius.circular(10),
                    child: prayer,
                  );
            if (!useColumns) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  nextPrayerAction,
                  const SizedBox(height: 12),
                  dateAndCity,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: nextPrayerAction),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(start: 12),
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: Color(0x558E9C70)),
                      ),
                    ),
                    child: dateAndCity,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeCountdown extends StatefulWidget {
  const _HomeCountdown({required this.time, this.onReached});

  final DateTime time;
  final VoidCallback? onReached;

  @override
  State<_HomeCountdown> createState() => _HomeCountdownState();
}

class _HomeCountdownState extends State<_HomeCountdown> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  @override
  void didUpdateWidget(_HomeCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time) _startClock();
  }

  void _startClock() {
    _ticker?.cancel();
    if (!widget.time.isAfter(DateTime.now())) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (!widget.time.isAfter(DateTime.now())) {
        timer.cancel();
        widget.onReached?.call();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.time.difference(DateTime.now());
    final seconds = remaining.isNegative ? 0 : remaining.inSeconds;
    String two(int number) => number.toString().padLeft(2, '0');
    final clock =
        '${two(seconds ~/ 3600)}:${two((seconds ~/ 60) % 60)}:${two(seconds % 60)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: HomePalette.gold.withValues(alpha: .8)),
        color: HomePalette.night.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.schedule_rounded, size: 14, color: HomePalette.gold),
          Text(
            appText(context, 'بعد', 'In'),
            style: const TextStyle(color: HomePalette.mist, fontSize: 11),
          ),
          Text(
            clock,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: HomePalette.ivory,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

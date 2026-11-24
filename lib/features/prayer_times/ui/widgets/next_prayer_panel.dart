import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/theme/worship_palette.dart';
import '../../../../core/widgets/tamanina_ui.dart';

String prayerClock(BuildContext context, DateTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

IconData prayerIcon(String name) => switch (name) {
  'Fajr' => Icons.nights_stay_outlined,
  'Sunrise' => Icons.wb_twilight_rounded,
  'Dhuhr' => Icons.light_mode_outlined,
  'Asr' => Icons.wb_sunny_outlined,
  'Maghrib' => Icons.wb_twilight_rounded,
  'Isha' => Icons.dark_mode_outlined,
  _ => Icons.schedule,
};

class NextPrayerPanel extends StatelessWidget {
  const NextPrayerPanel({
    super.key,
    this.prayer,
    this.onTap,
    this.illustrated = false,
    this.unavailable = false,
  });

  final PrayerTimeData? prayer;
  final VoidCallback? onTap;
  final bool illustrated;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final next = prayer;
    final typography = Theme.of(context).textTheme;
    final title = next == null
        ? appText(context, 'مواقيت الصلاة', 'Prayer times')
        : appText(context, next.nameArabic, next.name);
    final radius = BorderRadius.circular(illustrated ? 28 : 22);

    return Material(
      color: WorshipPalette.pine,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          image: illustrated
              ? DecorationImage(
                  image: const AssetImage('assets/images/prayer_dawn.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    WorshipPalette.deepPine.withValues(alpha: .47),
                    BlendMode.srcOver,
                  ),
                )
              : null,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(illustrated ? 20 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      prayerIcon(next?.name ?? ''),
                      color: WorshipPalette.warmGold,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appText(context, 'الصلاة القادمة', 'Next prayer'),
                        style: typography.labelLarge?.copyWith(
                          color: WorshipPalette.warmGold,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        appChevron(context),
                        color: WorshipPalette.ivory,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: typography.titleLarge?.copyWith(
                    color: WorshipPalette.ivory,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (next != null) ...[
                  Text(
                    prayerClock(context, next.time),
                    style:
                        (illustrated
                                ? typography.displaySmall
                                : typography.headlineMedium)
                            ?.copyWith(
                              color: WorshipPalette.ivory,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                  ),
                  const SizedBox(height: 4),
                  _PrayerCountdown(time: next.time),
                ] else
                  Text(
                    unavailable
                        ? appText(
                            context,
                            'تعذّر حساب المواقيت',
                            'Prayer times are unavailable',
                          )
                        : appText(
                            context,
                            'اختر موقعك لعرض المواقيت',
                            'Set your location to see prayer times',
                          ),
                    style: typography.bodyMedium?.copyWith(
                      color: WorshipPalette.paleSky,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerCountdown extends StatefulWidget {
  const _PrayerCountdown({required this.time});

  final DateTime time;

  @override
  State<_PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<_PrayerCountdown> {
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      const Duration(seconds: 15),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.time.difference(DateTime.now());
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    );
    final hour = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final label = remaining.inMinutes < 1
        ? appText(context, 'أقل من دقيقة', 'Less than a minute')
        : hour == 0
        ? appText(
            context,
            'متبقي ${number.format(minutes)} د',
            'In ${number.format(minutes)} min',
          )
        : appText(
            context,
            'متبقي ${number.format(hour)} س و${number.format(minutes)} د',
            'In ${number.format(hour)}h ${number.format(minutes)}m',
          );
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: WorshipPalette.paleSky),
    );
  }
}

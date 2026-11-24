import 'package:flutter/material.dart';

import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../prayer_times/ui/widgets/next_prayer_panel.dart';
import '../../../statistics/data/worship_activity.dart';
import 'home_visuals.dart';

class HomePrayerTimeline extends StatelessWidget {
  const HomePrayerTimeline({
    super.key,
    required this.today,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.onOpenAllPrayers,
    required this.onChooseCity,
    this.loading = false,
  });

  final DateTime today;
  final DailyPrayerTimes? prayerTimes;
  final PrayerTimeData? nextPrayer;
  final VoidCallback onOpenAllPrayers;
  final VoidCallback onChooseCity;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final schedule = prayerTimes;
    final next = nextPrayer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.schedule_rounded, color: colors.accent, size: 20),
            const SizedBox(width: 7),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  appText(context, 'مواقيت الصلاة', 'Prayer times'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: onOpenAllPrayers,
                style: TextButton.styleFrom(
                  foregroundColor: colors.muted,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        appText(context, 'الجدول الكامل', 'Full schedule'),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      appChevron(context),
                      size: 14,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (schedule == null)
          HomePanel(
            onTap: loading ? null : onChooseCity,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, color: colors.accent, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loading
                          ? appText(
                              context,
                              'جارٍ حساب المواقيت',
                              'Calculating prayer times',
                            )
                          : appText(
                              context,
                              'اختر مدينتك لعرض المواقيت',
                              'Choose your city to see prayer times',
                            ),
                      style: TextStyle(color: colors.ink),
                    ),
                  ),
                  if (!loading)
                    Icon(
                      appChevron(context),
                      color: colors.accent,
                      size: 16,
                      textDirection: TextDirection.ltr,
                    ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 6.0;
              final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
              final columns = constraints.maxWidth >= 264 * scale ? 5 : 3;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: schedule.obligatoryPrayers.map((prayer) {
                  // The next occurrence can belong to tomorrow's schedule.
                  final upcoming =
                      next != null &&
                          next.name == prayer.name &&
                          next.time.isAfter(today)
                      ? next
                      : null;
                  final status = upcoming == null
                      ? null
                      : DateUtils.isSameDay(upcoming.time, schedule.date)
                      ? appText(context, 'القادمة', 'Next')
                      : appText(context, 'غدًا', 'Tomorrow');
                  return SizedBox(
                    width: width,
                    child: _PrayerTile(
                      prayer: upcoming ?? prayer,
                      status: status,
                      today: today,
                      date: schedule.date,
                      onOpenAllPrayers: onOpenAllPrayers,
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.prayer,
    required this.status,
    required this.today,
    required this.date,
    required this.onOpenAllPrayers,
  });

  final PrayerTimeData prayer;
  final String? status;
  final DateTime today;
  final DateTime date;
  final VoidCallback onOpenAllPrayers;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final highlighted = status != null;
    final past = !prayer.time.isAfter(today);
    final completed = past && WorshipLog.prayerCompleted(prayer.name, date);
    final label = appText(context, prayer.nameArabic, prayer.name);
    final time = prayerClock(context, prayer.time);
    final state = completed
        ? appText(context, 'تم التسجيل', 'Logged')
        : past
        ? appText(context, 'تسجيل الصلاة', 'Log prayer')
        : appText(context, 'عرض الجدول', 'Open schedule');

    return Stack(
      alignment: Alignment.topCenter,
      fit: StackFit.passthrough,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Semantics(
            button: true,
            toggled: past ? completed : null,
            label: [label, time, ?status, state].join(', '),
            child: HomePanel(
              radius: 15,
              background: colors.surface,
              border: highlighted ? colors.accent : null,
              artwork: highlighted
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: dark
                              ? const [Color(0xFF6B502D), Color(0xFF283222)]
                              : const [Color(0xFFF0DEB5), Color(0xFFFFF4DB)],
                        ),
                      ),
                    )
                  : null,
              onTap: () async {
                if (!past) {
                  onOpenAllPrayers();
                  return;
                }
                await WorshipLog.setPrayerCompleted(
                  prayer.name,
                  date,
                  !completed,
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 78),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 12, 2, 7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle_outline
                            : prayerIcon(prayer.name),
                        size: 18,
                        color: highlighted || completed
                            ? colors.accent
                            : colors.ink,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.ink,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        time,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.muted,
                          fontSize: 10.5,
                          height: 1.35,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (status case final status?)
          Positioned(
            top: 0,
            left: 2,
            right: 2,
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: HomePalette.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: HomePalette.onGold,
                      fontSize: 9,
                      height: 1.26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

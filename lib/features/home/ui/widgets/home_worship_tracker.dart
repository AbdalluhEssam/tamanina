import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../statistics/data/worship_activity.dart';
import 'home_visuals.dart';

class HomeWorshipTracker extends StatelessWidget {
  const HomeWorshipTracker({
    super.key,
    required this.today,
    required this.onOpenPrayerTimes,
    required this.onOpenQuran,
    required this.onOpenTasbeeh,
    required this.onOpenStatistics,
  });

  final DateTime today;
  final VoidCallback onOpenPrayerTimes;
  final VoidCallback onOpenQuran;
  final VoidCallback onOpenTasbeeh;
  final VoidCallback onOpenStatistics;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = Theme.of(context).textTheme;
    final prayerCount = WorshipLog.count(WorshipActivity.prayer, today);
    final adhkarCount = WorshipLog.count(WorshipActivity.adhkar, today);
    final quranCount = WorshipLog.count(WorshipActivity.quran, today);
    final tasbeehCount = WorshipLog.count(WorshipActivity.tasbeeh, today);
    void openAdhkar() => Navigator.pushNamed(context, AppRoutes.azkar);

    final targets = [
      (
        label: appText(context, 'الصلوات', 'Prayers'),
        goal: appText(context, 'تسجيل الصلوات', 'Log your prayers'),
        icon: Icons.schedule_outlined,
        count: prayerCount,
        target: 5,
        onTap: onOpenPrayerTimes,
      ),
      (
        label: appText(context, 'الأذكار', 'Adhkar'),
        goal: appText(context, 'المواظبة على الأذكار', 'Keep up with adhkar'),
        icon: Icons.wb_twilight_rounded,
        count: adhkarCount,
        target: 2,
        onTap: openAdhkar,
      ),
      (
        label: appText(context, 'الورد', 'Portion'),
        goal: appText(context, 'قراءة الورد', 'Read your portion'),
        icon: Icons.menu_book_outlined,
        count: quranCount,
        target: 1,
        onTap: onOpenQuran,
      ),
      (
        label: appText(context, 'التسبيح', 'Tasbeeh'),
        goal: appText(context, 'إكمال التسبيح', 'Complete your tasbeeh'),
        icon: Icons.fingerprint_rounded,
        count: tasbeehCount,
        target: 33,
        onTap: onOpenTasbeeh,
      ),
    ];
    final focus = [
      targets[1],
      targets[0],
      targets[2],
      targets[3],
    ].where((target) => target.count < target.target).firstOrNull;

    return HomePanel(
      background: colors.surface,
      artwork: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topEnd,
            end: AlignmentDirectional.bottomStart,
            colors: [colors.raised, colors.surface],
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 10, 11, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                header: true,
                child: Text(
                  appText(
                    context,
                    'تركيز اليوم والعبادات',
                    "Today's worship focus",
                  ),
                  style: text.titleSmall?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _SummaryAction(
                    icon: Icons.star_rounded,
                    label: appText(context, 'نقاط اليوم', 'Daily score'),
                    value: WorshipLog.dailyScore(today).toString(),
                    onTap: onOpenStatistics,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: colors.border),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: _SummaryAction(
                        icon: focus?.icon ?? Icons.check_circle_outline_rounded,
                        label: appText(context, 'هدف اليوم', "Today's goal"),
                        value:
                            focus?.goal ??
                            appText(
                              context,
                              'أكملت أهداف اليوم',
                              'Daily goals complete',
                            ),
                        onTap: focus?.onTap ?? onOpenStatistics,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 3),
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
                final columns = constraints.maxWidth < 195 * scale ? 2 : 4;
                return Wrap(
                  children: [
                    for (final target in targets)
                      SizedBox(
                        width: constraints.maxWidth / columns,
                        child: _WorshipProgress(
                          label: target.label,
                          count: target.count,
                          target: target.target,
                          onTap: target.onTap,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryAction extends StatelessWidget {
  const _SummaryAction({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colors.raised,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.accent, size: 20),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: text.bodySmall?.copyWith(
                        color: colors.muted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      value,
                      style: text.bodyMedium?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w700,
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorshipProgress extends StatelessWidget {
  const _WorshipProgress({
    required this.label,
    required this.count,
    required this.target,
    required this.onTap,
  });

  final String label;
  final int count;
  final int target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final complete = count >= target;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count/$target',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: complete ? colors.accent : colors.ink,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 12,
                  height: 1.18,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.muted,
                  fontSize: 11,
                  height: 1.22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

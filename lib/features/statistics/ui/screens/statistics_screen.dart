import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/tamanina_ui.dart';
import '../../data/worship_activity.dart';

enum _Period { today, week, all }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  _Period _period = _Period.today;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(appText(context, 'نشاطك', 'Your activity'))),
    body: SafeArea(
      top: false,
      child: ContentFrame(
        child: ValueListenableBuilder(
          valueListenable: WorshipLog.box.listenable(),
          builder: (context, _, _) => _content(context),
        ),
      ),
    ),
  );

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final today = WorshipLog.day(DateTime.now());
    final locale = Localizations.localeOf(context).languageCode;
    final days = [
      for (var offset = 0; offset < 7; offset++)
        DateTime(today.year, today.month, today.day - offset),
    ];
    final metrics = [
      (
        WorshipActivity.tasbeeh,
        Icons.fingerprint,
        appText(context, 'تسبيحات', 'Tasbeeh counts'),
      ),
      (
        WorshipActivity.adhkar,
        Icons.wb_twilight,
        appText(context, 'أذكار مكتملة', 'Adhkar completed'),
      ),
      (
        WorshipActivity.quran,
        Icons.menu_book_outlined,
        appText(context, 'صفحات فُتحت', 'Quran pages opened'),
      ),
      (
        WorshipActivity.prayer,
        Icons.check_circle_outline,
        appText(context, 'صلوات سجّلتها', 'Prayers marked complete'),
      ),
    ];
    final counts = [
      for (final (activity, _, _) in metrics)
        switch (_period) {
          _Period.today => WorshipLog.count(activity, today),
          _Period.week => days.fold<int>(
            0,
            (sum, day) => sum + WorshipLog.count(activity, day),
          ),
          _Period.all => WorshipLog.total(activity),
        },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (period, title) in [
              (_Period.today, appText(context, 'اليوم', 'Today')),
              (_Period.week, appText(context, 'آخر ٧ أيام', 'Last 7 days')),
              (_Period.all, appText(context, 'الإجمالي', 'All time')),
            ])
              ChoiceChip(
                label: Text(title),
                selected: period == _period,
                onSelected: (_) => setState(() => _period = period),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              for (final (index, (_, icon, title)) in metrics.indexed) ...[
                if (index != 0) const Divider(height: 1),
                ListTile(
                  leading: Icon(icon, color: theme.colorScheme.secondary),
                  title: Text(title),
                  trailing: Text(
                    NumberFormat.decimalPattern(locale).format(counts[index]),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (counts.every((count) => count == 0))
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              appText(
                context,
                'سيظهر نشاطك هنا بعد استخدام المصحف أو السبحة أو الأذكار.',
                'Your activity appears here after using Quran, Tasbeeh, or Adhkar.',
              ),
            ),
          ),
        if (_period == _Period.week) ...[
          const SizedBox(height: 22),
          Text(
            appText(context, 'النشاط حسب اليوم', 'Activity by day'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final day in days)
            ListTile(
              title: Text(DateFormat.MMMEd(locale).format(day)),
              subtitle: Text(
                metrics
                    .map(
                      (metric) =>
                          '${metric.$3} ${NumberFormat.decimalPattern(locale).format(WorshipLog.count(metric.$1, day))}',
                    )
                    .join('، '),
              ),
            ),
        ],
      ],
    );
  }
}

// Retain the previously persisted daily statistics shape for existing callers.
class DailyStats {
  const DailyStats({
    required this.date,
    required this.tasbeehCount,
    required this.azkarCount,
    required this.quranPages,
    required this.prayersCompleted,
  });

  final DateTime date;
  final int tasbeehCount;
  final int azkarCount;
  final int quranPages;
  final int prayersCompleted;

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'tasbeehCount': tasbeehCount,
    'azkarCount': azkarCount,
    'quranPages': quranPages,
    'prayersCompleted': prayersCompleted,
  };

  factory DailyStats.fromMap(Map map) => DailyStats(
    date: DateTime.parse(map['date'] as String),
    tasbeehCount: (map['tasbeehCount'] as int?) ?? 0,
    azkarCount: (map['azkarCount'] as int?) ?? 0,
    quranPages: (map['quranPages'] as int?) ?? 0,
    prayersCompleted: (map['prayersCompleted'] as int?) ?? 0,
  );
}

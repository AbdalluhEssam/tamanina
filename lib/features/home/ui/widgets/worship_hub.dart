import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/reminder_schedule.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import 'home_visuals.dart';

class WorshipHub extends StatefulWidget {
  const WorshipHub({
    super.key,
    required this.prayerCard,
    required this.onOpenNotifications,
  });

  final Widget prayerCard;
  final VoidCallback onOpenNotifications;

  @override
  State<WorshipHub> createState() => _WorshipHubState();
}

class _WorshipHubState extends State<WorshipHub> {
  int _index = 0;
  int _dhikrOffset = 0;

  void _select(int index) {
    if (_index != index) setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final index =
        (now.day * 24 + now.hour + _dhikrOffset) % dhikrMessages.length;
    final message = dhikrMessages[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeMasthead(
          selection: _index,
          onSelected: _select,
          onOpenNotifications: widget.onOpenNotifications,
        ),
        const SizedBox(height: 7),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 180) return;
            final forward = Directionality.of(context) == TextDirection.rtl
                ? velocity > 0
                : velocity < 0;
            _select(forward ? 1 : 0);
          },
          child: _index == 0
              ? widget.prayerCard
              : _DhikrCard(
                  arabic: message.ar,
                  english: message.en,
                  onNext: () => setState(() => _dhikrOffset++),
                ),
        ),
      ],
    );
  }
}

class _HomeMasthead extends StatelessWidget {
  const _HomeMasthead({
    required this.selection,
    required this.onSelected,
    required this.onOpenNotifications,
  });

  final int selection;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 0, 3, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HomePalette.deepGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HomePalette.gold.withValues(alpha: .7),
                  ),
                ),
                alignment: Alignment.center,
                child: const BrandMark(size: 31),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  appText(context, 'طمأنينة', 'Tamanina'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: arabic ? 'Reem Kufi' : 'Poppins',
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpenNotifications,
                tooltip: appText(
                  context,
                  'إعدادات التنبيهات',
                  'Notification settings',
                ),
                icon: Icon(Icons.notifications_none_rounded, color: colors.ink),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            children: [
              for (final (index, label) in [
                (0, appText(context, 'الصلاة', 'Prayer')),
                (1, appText(context, 'الذكر', 'Dhikr')),
              ])
                ChoiceChip(
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 49),
                    child: Text(label, textAlign: TextAlign.center),
                  ),
                  selected: selection == index,
                  onSelected: (_) => onSelected(index),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  side: BorderSide(
                    color: selection == index
                        ? HomePalette.gold
                        : colors.border,
                  ),
                  selectedColor: HomePalette.gold,
                  backgroundColor: colors.surface,
                  labelStyle: TextStyle(
                    color: selection == index ? HomePalette.onGold : colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.arabic,
    required this.english,
    required this.onNext,
  });

  final String arabic;
  final String english;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final quote = isArabic ? arabic : english;
    final type = Theme.of(context).textTheme;
    return HomePanel(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 18,
                  color: colors.accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appText(context, 'لحظة للذكر', 'A moment for dhikr'),
                    style: type.titleSmall?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: appText(context, 'مشاركة الذكر', 'Share dhikr'),
                  onPressed: () => Share.share(quote),
                  color: colors.accent,
                  icon: const Icon(Icons.share_outlined, size: 18),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: type.titleMedium?.copyWith(
                  fontFamily: isArabic ? 'Amiri' : null,
                  height: 1.6,
                  color: colors.ink,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onNext,
                  style: TextButton.styleFrom(foregroundColor: colors.accent),
                  child: Text(appText(context, 'ذكر آخر', 'Next dhikr')),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.azkar),
                  style: TextButton.styleFrom(foregroundColor: colors.accent),
                  child: Text(appText(context, 'كل الأذكار', 'All adhkar')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

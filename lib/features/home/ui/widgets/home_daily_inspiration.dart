import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'home_visuals.dart';
import '../../../../core/widgets/tamanina_ui.dart';

class HomeDailyInspiration extends StatelessWidget {
  const HomeDailyInspiration({super.key});

  static const _inspirations = [
    (
      'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'سورة الرعد · الآية ٢٨',
      'Those who believe and whose hearts find rest in the remembrance of Allah. Verily in the remembrance of Allah do hearts find rest.',
      'Surah Ar-Ra’d · Ayah 28',
    ),
    (
      'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      'سورة البقرة · الآية ١٥٢',
      'So remember Me; I will remember you. And be grateful to Me and do not deny Me.',
      'Surah Al-Baqarah · Ayah 152',
    ),
    (
      'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
      'سورة البقرة · الآية ١٨٦',
      'And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.',
      'Surah Al-Baqarah · Ayah 186',
    ),
    (
      'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ',
      'سورة الطلاق · الآيات ٢-٣',
      'And whoever fears Allah - He will make for him a way out and will provide for him from where he does not expect.',
      'Surah At-Talaq · Ayat 2-3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = HomePalette.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final today = DateTime.now();
    final item = _inspirations[today.day % _inspirations.length];
    final verse = isArabic ? item.$1 : item.$3;
    final source = isArabic ? item.$2 : item.$4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appText(
                    context,
                    'نفحة طمأنينة اليوم',
                    'Daily verse of serenity',
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.accent,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy_rounded, size: 17),
                tooltip: appText(context, 'نسخ الآية', 'Copy verse'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$verse ($source)'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appText(
                          context,
                          'تم نسخ الآية الكريمة',
                          'Verse copied',
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.share_outlined, size: 17),
                tooltip: appText(context, 'مشاركة', 'Share'),
                onPressed: () {
                  Share.share('$verse\n\n$source\n- طمأنينة');
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            verse,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.65,
              fontSize: 15.5,
              color: colors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            source,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.muted,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

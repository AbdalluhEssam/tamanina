import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/tamanina_ui.dart';
import '../cubit/adhkar_cubit.dart';
import 'adhkar_detail_screen.dart';

String adhkarCategoryName(
  BuildContext context,
  AdhkarCategory category,
) => switch (category) {
  AdhkarCategory.morning => appText(context, 'أذكار الصباح', 'Morning adhkar'),
  AdhkarCategory.evening => appText(context, 'أذكار المساء', 'Evening adhkar'),
  AdhkarCategory.sleep => appText(context, 'أذكار النوم', 'Bedtime adhkar'),
  AdhkarCategory.postPrayer => appText(
    context,
    'أذكار بعد الصلاة',
    'After prayer',
  ),
  AdhkarCategory.misc => appText(context, 'أذكار متنوعة', 'Other adhkar'),
};

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [
      platformIcon(context, Icons.wb_sunny_outlined, CupertinoIcons.sunrise),
      platformIcon(context, Icons.wb_twilight, CupertinoIcons.sunset),
      platformIcon(context, Icons.nightlight_outlined, CupertinoIcons.moon),
      platformIcon(context, Icons.schedule_outlined, CupertinoIcons.clock),
      platformIcon(context, Icons.auto_stories_outlined, CupertinoIcons.book),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(appText(context, 'الأذكار', 'Adhkar'))),
      body: SafeArea(
        top: false,
        child: ContentFrame(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                appText(context, 'اختر مجموعة أذكار', 'Choose a collection'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              for (final (index, category) in AdhkarCategory.values.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Icon(
                        icons[index],
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(adhkarCategoryName(context, category)),
                      trailing: Icon(appChevron(context)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AdhkarDetailScreen(category: category),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

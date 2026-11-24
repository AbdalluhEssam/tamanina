import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran_sharif/quran_sharif.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../data/services/mushaf_library.dart';
import 'simple_mushaf_page_screen.dart';

enum _QuranIndex { surahs, juz, verses }

class QuranTabScreen extends StatefulWidget {
  const QuranTabScreen({super.key});

  @override
  State<QuranTabScreen> createState() => _QuranTabScreenState();
}

class _QuranTabScreenState extends State<QuranTabScreen> {
  late Future<List<Surahs>> _library;
  final _search = TextEditingController();
  _QuranIndex _index = _QuranIndex.surahs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _library = Future(() => MushafLibrary.surahs);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ContentFrame(
    child: FutureBuilder<List<Surahs>>(
      future: _library,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ListSkeleton();
        }
        if (!snapshot.hasData) {
          return Center(
            child: OutlinedButton(
              onPressed: () => setState(_load),
              child: Text(
                appText(context, 'إعادة تحميل المصحف', 'Reload Quran'),
              ),
            ),
          );
        }
        final query = MushafLibrary.normalize(_search.text.trim());
        final theme = Theme.of(context);
        final rows = switch (_index) {
          _QuranIndex.surahs => _surahs(context, snapshot.data!, query),
          _QuranIndex.juz => _juz(context),
          _QuranIndex.verses => _verses(context, query),
        };
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList.list(
                children: [
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: ListTile(
                      leading: Icon(
                        platformIcon(
                          context,
                          Icons.bookmark_outline,
                          CupertinoIcons.bookmark,
                        ),
                      ),
                      title: Text(
                        appText(context, 'تابع القراءة', 'Continue reading'),
                      ),
                      subtitle: Text(
                        appText(
                          context,
                          'ارجع إلى آخر موضع حفظته',
                          'Return to your last position',
                        ),
                      ),
                      trailing: Icon(appChevron(context)),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.mushafReader),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (index, label) in [
                        (
                          _QuranIndex.surahs,
                          appText(context, 'السور', 'Surahs'),
                        ),
                        (_QuranIndex.juz, appText(context, 'الأجزاء', 'Juz')),
                        (
                          _QuranIndex.verses,
                          appText(context, 'بحث الآيات', 'Find verses'),
                        ),
                      ])
                        ChoiceChip(
                          label: Text(label),
                          selected: _index == index,
                          onSelected: (_) => setState(() {
                            if (_index != index) _search.clear();
                            _index = index;
                          }),
                        ),
                    ],
                  ),
                  if (_index != _QuranIndex.juz) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          platformIcon(
                            context,
                            Icons.search,
                            CupertinoIcons.search,
                          ),
                        ),
                        labelText: _index == _QuranIndex.surahs
                            ? appText(context, 'ابحث عن سورة', 'Search surahs')
                            : appText(
                                context,
                                'اكتب كلمات من الآية بالعربية',
                                'Enter part of a verse in Arabic',
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) => rows[index],
              ),
            ),
          ],
        );
      },
    ),
  );

  List<Widget> _surahs(
    BuildContext context,
    List<Surahs> surahs,
    String query,
  ) {
    final results = surahs.where(
      (surah) =>
          MushafLibrary.normalize(surah.name).contains(query) ||
          MushafLibrary.normalize(surah.englishName).contains(query) ||
          surah.number.toString() == query,
    );
    if (results.isEmpty) {
      return [
        ListTile(
          title: Text(
            appText(
              context,
              'لم نجد سورة بهذا الاسم.',
              'No surahs match your search.',
            ),
          ),
        ),
      ];
    }
    return [
      for (final surah in results)
        ListTile(
          leading: _number(context, surah.number),
          title: Text(
            surah.name,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 22),
          ),
          subtitle: Text(
            appText(
              context,
              '${surah.ayahs.length} آية',
              '${surah.englishName}, ${surah.ayahs.length} verses',
            ),
          ),
          trailing: Icon(appChevron(context)),
          onTap: () => _open(
            context,
            SimpleMushafPageScreen(initialSurah: surah.number),
          ),
        ),
    ];
  }

  List<Widget> _juz(BuildContext context) => [
    for (var juz = 1; juz <= 30; juz++)
      if (MushafLibrary.juzStarts[juz] case final entry?)
        ListTile(
          leading: _number(context, juz),
          title: Text(appText(context, 'الجزء $juz', 'Juz $juz')),
          subtitle: Text(
            appText(
              context,
              'صفحة ${entry.verse.page}',
              'Page ${entry.verse.page}',
            ),
          ),
          trailing: Icon(appChevron(context)),
          onTap: () => _open(
            context,
            SimpleMushafPageScreen(initialPage: entry.verse.page),
          ),
        ),
  ];

  List<Widget> _verses(BuildContext context, String query) {
    if (query.length < 3) {
      return [
        ListTile(
          title: Text(
            appText(
              context,
              'اكتب ثلاثة أحرف على الأقل.',
              'Enter at least three letters.',
            ),
          ),
        ),
      ];
    }
    final matches = MushafLibrary.searchVerses(query).take(50).toList();
    if (matches.isEmpty) {
      return [
        ListTile(
          title: Text(
            appText(
              context,
              'لم نجد آيات مطابقة.',
              'No verses match your search.',
            ),
          ),
        ),
      ];
    }
    return [
      for (final entry in matches)
        ListTile(
          title: Text(
            entry.verse.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
          ),
          subtitle: Text('${entry.surah.name}، ${entry.verse.numberInSurah}'),
          trailing: Icon(appChevron(context)),
          onTap: () => _open(
            context,
            SimpleMushafPageScreen(
              initialPage: entry.verse.page,
              initialVerse: entry.verse.number,
            ),
          ),
        ),
    ];
  }

  Widget _number(BuildContext context, int number) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: colors.secondaryContainer,
      foregroundColor: colors.onSecondaryContainer,
      child: Text('$number'),
    );
  }

  void _open(BuildContext context, SimpleMushafPageScreen reader) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => reader));
}

import 'package:quran_sharif/quran_sharif.dart';

class MushafLibrary {
  MushafLibrary._();

  static final List<Surahs> surahs = List.unmodifiable(Quran.getAllSurah());
  static final String basmala = surahs.first.ayahs.first.text
      .replaceFirst('\uFEFF', '')
      .trim();

  static final Map<int, List<({Surahs surah, Ayahs verse})>> pages =
      _indexPages();

  static Map<int, List<({Surahs surah, Ayahs verse})>> _indexPages() {
    final result = <int, List<({Surahs surah, Ayahs verse})>>{};
    for (final surah in surahs) {
      for (final verse in surah.ayahs) {
        (result[verse.page] ??= []).add((surah: surah, verse: verse));
      }
    }
    return result.map(
      (page, verses) => MapEntry(page, List.unmodifiable(verses)),
    );
  }

  static final Map<int, ({Surahs surah, Ayahs verse})> juzStarts = {
    for (final entry in pages.values.expand((page) => page).toList().reversed)
      entry.verse.juz: entry,
  };

  static final _searchableVerses = [
    for (final entry in pages.values.expand((page) => page))
      (entry: entry, text: normalize(entry.verse.text)),
  ];

  static Iterable<({Surahs surah, Ayahs verse})> searchVerses(String query) =>
      _searchableVerses
          .where((verse) => verse.text.contains(query))
          .map((verse) => verse.entry);

  static final List<int> _legacyPageStarts = [
    for (final surah in surahs)
      // Previous releases grouped each surah into blocks of 15 verses.
      for (var i = 0; i < surah.ayahs.length; i += 15) surah.ayahs[i].page,
  ];

  static int migratePage(int legacyPage) =>
      _legacyPageStarts[legacyPage.clamp(1, _legacyPageStarts.length) - 1];

  static Surahs surah(int number) => surahs[number.clamp(1, surahs.length) - 1];

  static String normalize(String text) => text
      .toLowerCase()
      .replaceAll(
        RegExp(r'[\u0610-\u061a\u064b-\u065f\u0670\u06d6-\u06edـ]'),
        '',
      )
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'[-\s]+'), '')
      .replaceAll('سورة', '');
}

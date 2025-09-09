import 'package:quran_sharif/quran_sharif.dart';

void main() async {
  // Test the quran_sharif API
  try {
    print('Testing quran_sharif package...');
    print('=========================================');

    // 1. Get all surahs
    final allSurahs = Quran.getAllSurah();
    print('Total surahs: ${allSurahs.length}');
    print('First surah: ${allSurahs.first.name}');
    print('First surah English: ${allSurahs.first.englishName}');
    print('First surah verses: ${allSurahs.first.ayahs.length}');
    print('');

    // 2. Get surah by ID
    final surah = Quran.getSurahById(id: 1);
    print('Surah 1: ${surah?.name}');
    print('Surah 1 English: ${surah?.englishName}');
    print('Surah 1 Total verses: ${surah?.ayahs.length}');
    print('Surah 1 Revelation type: ${surah?.revelationType}');
    if (surah != null && surah.ayahs.isNotEmpty) {
      print('First ayah: ${surah.ayahs.first.text}');
    }
    print('');

    // 3. Get all surah names
    final surahNames = Quran.getSurahName();
    print('All surah names count: ${surahNames.length}');
    print('First 5 surah names:');
    for (int i = 0; i < 5; i++) {
      print('  ${i + 1}. ${surahNames[i]}');
    }
    print('');

    // 4. Filter surahs by revelation type
    final makkiSurahs = Quran.getSurahByRevelationType(isMakki: true);
    print('Makki surahs: ${makkiSurahs.length}');

    final madaniSurahs = Quran.getSurahByRevelationType(isMakki: false);
    print('Madani surahs: ${madaniSurahs.length}');
    print('');

    // 5. Get ayahs by Juz
    final juzAyahs = Quran.getJuz(id: 1);
    print('Ayahs in Juz 1: ${juzAyahs.length}');
    if (juzAyahs.isNotEmpty) {
      print('First ayah: ${juzAyahs.first.text}');
      print('First ayah number: ${juzAyahs.first.numberInSurah}');
    }

    print('=========================================');
    print('API test complete!');
  } catch (e) {
    print('Error: $e');
  }
}

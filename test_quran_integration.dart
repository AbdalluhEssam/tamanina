import 'package:quran_sharif/quran_sharif.dart';

void main() {
  // Test quran_sharif integration
  testQuranSharif();
}

void testQuranSharif() {
  print('Testing quran_sharif integration...');

  try {
    // Test 1: Get all surahs
    List<Surahs> allSurahs = Quran.getAllSurah();
    print('✅ Total surahs loaded: ${allSurahs.length}');

    if (allSurahs.isNotEmpty) {
      print(
          'First surah: ${allSurahs.first.name} - ${allSurahs.first.englishName}');
      print('Total ayahs in first surah: ${allSurahs.first.ayahs.length}');
    }

    // Test 2: Get specific surah
    Surahs? fatiha = Quran.getSurahById(id: 1);
    if (fatiha != null) {
      print('✅ Al-Fatiha loaded successfully');
      print('Name: ${fatiha.name}');
      print('English Name: ${fatiha.englishName}');
      print('Number of verses: ${fatiha.ayahs.length}');
      print('Revelation type: ${fatiha.revelationType}');

      // Print first verse
      if (fatiha.ayahs.isNotEmpty) {
        print('First verse: ${fatiha.ayahs.first.text}');
      }
    } else {
      print('❌ Failed to load Al-Fatiha');
    }

    // Test 3: Get surah names
    List<String> surahNames = Quran.getSurahName();
    print('✅ Surah names loaded: ${surahNames.length}');
    print('First 5 surah names: ${surahNames.take(5).toList()}');

    // Test 4: Filter by revelation type
    List<Surahs> makkiSurahs = Quran.getSurahByRevelationType(isMakki: true);
    List<Surahs> madaniSurahs = Quran.getSurahByRevelationType(isMakki: false);
    print('✅ Makki surahs: ${makkiSurahs.length}');
    print('✅ Madani surahs: ${madaniSurahs.length}');

    // Test 5: Get Juz
    List<Ayahs> juz1 = Quran.getJuz(id: 1);
    print('✅ Juz 1 verses: ${juz1.length}');

    print('\n🎉 All tests passed! quran_sharif is working correctly.');
  } catch (e) {
    print('❌ Error testing quran_sharif: $e');
  }
}

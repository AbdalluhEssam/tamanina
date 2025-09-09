import 'package:flutter/material.dart';
import 'lib/features/quran/data/datasources/quran_local_datasource.dart';
import 'lib/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔍 Testing QuranRepository...');

  try {
    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Create data source
    final dataSource = QuranLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );

    // Create repository
    final repository = QuranRepositoryImpl(
      localDataSource: dataSource,
    );

    print('✅ Repository initialized successfully');

    // Test getting all surahs
    print('\n📚 Testing getAllSurahs...');
    final result = await repository.getAllSurahs();

    result.fold(
      (failure) => print('❌ Error getting surahs: ${failure.message}'),
      (surahs) {
        print('✅ Got ${surahs.length} surahs');

        if (surahs.isNotEmpty) {
          final firstSurah = surahs.first;
          print('First surah: ${firstSurah.surahNameArabic}');
          print('English name: ${firstSurah.surahNameEnglish}');
          print('Total verses: ${firstSurah.totalVerses}');
          print('Revelation type: ${firstSurah.revelationType}');
        }

        print('\nFirst 10 surahs:');
        for (int i = 0; i < 10 && i < surahs.length; i++) {
          final surah = surahs[i];
          print(
              '${surah.surahNumber}. ${surah.surahNameArabic} (${surah.totalVerses} آية)');
        }
      },
    );

    // Test getting specific surah with verses
    print('\n📖 Testing getSurah with verses...');
    final surahResult = await repository.getSurah(1); // Al-Fatiha

    surahResult.fold(
      (failure) => print('❌ Error getting surah: ${failure.message}'),
      (surah) {
        print('✅ Got surah: ${surah.surahNameArabic}');
        print('Number of verses: ${surah.verses.length}');

        if (surah.verses.isNotEmpty) {
          print('\nFirst 3 verses:');
          for (int i = 0; i < 3 && i < surah.verses.length; i++) {
            final verse = surah.verses[i];
            print('${verse.verseNumber}. ${verse.arabicText}');
          }
        }
      },
    );

    print('\n🎉 Repository test completed successfully!');
  } catch (e) {
    print('❌ Repository test failed: $e');
  }
}

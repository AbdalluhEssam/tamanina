import 'package:quran_sharif/quran_sharif.dart';

void main() {
  // Test to understand Ayahs properties
  try {
    Surahs? fatiha = Quran.getSurahById(id: 1);
    if (fatiha != null && fatiha.ayahs.isNotEmpty) {
      Ayahs firstAyah = fatiha.ayahs.first;

      print('Ayah properties:');
      print('Text: ${firstAyah.text}');
      print('Number in surah: ${firstAyah.numberInSurah}');

      // Try to access different potential properties
      try {
        print('Number: ${firstAyah.number}');
      } catch (e) {
        print('No number property');
      }

      // Check if we can get surah number from parent
      print('Parent surah number: ${fatiha.number}');
    }

    // Test with multiple surahs to understand structure
    List<Ayahs> juz1 = Quran.getJuz(id: 1);
    if (juz1.isNotEmpty) {
      print('\nJuz ayah example:');
      Ayahs juzAyah = juz1.first;
      print('Text: ${juzAyah.text}');
      print('Number in surah: ${juzAyah.numberInSurah}');
      try {
        print('Number: ${juzAyah.number}');
      } catch (e) {
        print('No number property in juz');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

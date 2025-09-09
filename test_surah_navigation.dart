import 'package:quran_sharif/quran_sharif.dart';

void main() {
  print('اختبار الانتقال للسور...');

  try {
    // تحميل جميع السور
    List<Surahs> allSurahs = Quran.getAllSurah();
    print('✅ تم تحميل ${allSurahs.length} سورة');

    // تجميع الآيات مع تتبع السور
    List<Ayahs> allAyahs = [];
    Map<int, int> ayahIndexToSurahNumber = {};

    for (final surah in allSurahs) {
      print(
          'السورة ${surah.number}: ${surah.name} - ${surah.ayahs.length} آية');
      for (final ayah in surah.ayahs) {
        ayahIndexToSurahNumber[allAyahs.length] = surah.number;
        allAyahs.add(ayah);
      }
    }

    print('✅ إجمالي الآيات: ${allAyahs.length}');

    // اختبار الصفحات
    const int ayahsPerPage = 15;
    List<Map<String, dynamic>> pages = [];

    for (int i = 0; i < allAyahs.length; i += ayahsPerPage) {
      int endIndex = i + ayahsPerPage;
      if (endIndex > allAyahs.length) endIndex = allAyahs.length;

      List<Ayahs> pageAyahs = allAyahs.sublist(i, endIndex);
      int mainSurahNumber = ayahIndexToSurahNumber[i] ?? 1;

      // جمع السور في الصفحة
      Set<int> surahs = {};
      for (int j = i; j < endIndex; j++) {
        if (ayahIndexToSurahNumber.containsKey(j)) {
          surahs.add(ayahIndexToSurahNumber[j]!);
        }
      }

      pages.add({
        'pageNumber': pages.length + 1,
        'mainSurah': mainSurahNumber,
        'allSurahs': surahs.toList(),
        'ayahsCount': pageAyahs.length,
        'firstAyahNumber': pageAyahs.first.numberInSurah,
      });
    }

    print('✅ إجمالي الصفحات: ${pages.length}');

    // اختبار العثور على سور محددة
    List<int> testSurahs = [
      1,
      2,
      18,
      36,
      67,
      114
    ]; // الفاتحة، البقرة، الكهف، يس، الملك، الناس

    for (int surahNumber in testSurahs) {
      bool found = false;
      for (int i = 0; i < pages.length; i++) {
        if (pages[i]['allSurahs'].contains(surahNumber)) {
          print(
              '✅ السورة $surahNumber موجودة في الصفحة ${pages[i]['pageNumber']}');
          found = true;
          break;
        }
      }
      if (!found) {
        print('❌ لم يتم العثور على السورة $surahNumber');
      }
    }
  } catch (e) {
    print('❌ خطأ: $e');
  }
}

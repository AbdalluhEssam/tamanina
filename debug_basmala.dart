import 'package:quran_sharif/quran_sharif.dart';

void main() {
  // فحص البسملة في السور المختلفة
  final surahs = Quran.getAllSurah();

  print('=== فحص البسملة في السور ===');

  // فحص أول 10 سور
  for (int i = 0; i < 10 && i < surahs.length; i++) {
    final surah = surahs[i];
    print('\n--- سورة ${surah.name} (رقم ${surah.number}) ---');

    if (surah.ayahs.isNotEmpty) {
      final firstAyah = surah.ayahs[0];
      print('الآية الأولى: "${firstAyah.text}"');
      print('رقم الآية في السورة: ${firstAyah.numberInSurah}');
      print('طول النص: ${firstAyah.text.length} حرف');

      // فحص إذا كانت تبدأ بالبسملة
      String text = firstAyah.text.trim();
      List<String> basmalaVariations = [
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'بسم الله الرحمن الرحيم',
        'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيمِ',
      ];

      bool foundBasmala = false;
      for (String basmala in basmalaVariations) {
        if (text.startsWith(basmala)) {
          print('✅ تحتوي على البسملة: $basmala');
          foundBasmala = true;
          break;
        }
      }

      if (!foundBasmala) {
        print('❌ لا تحتوي على البسملة المعروفة');
        // طباعة أول 100 حرف للفحص
        String preview =
            text.length > 100 ? text.substring(0, 100) + '...' : text;
        print('معاينة: $preview');
      }
    }
  }

  print('\n=== فحص انتهى ===');
}

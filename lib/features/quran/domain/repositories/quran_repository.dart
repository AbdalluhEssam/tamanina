import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quran_entity.dart';

abstract class QuranRepository {
  /// الحصول على جميع السور
  Future<Either<Failure, List<QuranEntity>>> getAllSurahs();

  /// الحصول على سورة معينة بالآيات
  Future<Either<Failure, QuranEntity>> getSurah(int surahNumber);

  /// الحصول على آية معينة
  Future<Either<Failure, VerseEntity>> getVerse(
      int surahNumber, int verseNumber);

  /// البحث في القرآن
  Future<Either<Failure, List<VerseEntity>>> searchQuran(String query);

  /// الحصول على السور المفضلة
  Future<Either<Failure, List<QuranEntity>>> getFavoriteSurahs();

  /// الحصول على الآيات المفضلة
  Future<Either<Failure, List<VerseEntity>>> getFavoriteVerses();

  /// الحصول على الآيات المحفوظة (العلامات المرجعية)
  Future<Either<Failure, List<VerseEntity>>> getBookmarkedVerses();

  /// تبديل حالة السورة المفضلة
  Future<Either<Failure, bool>> toggleSurahFavorite(int surahNumber);

  /// تبديل حالة الآية المفضلة
  Future<Either<Failure, bool>> toggleVerseFavorite(
      int surahNumber, int verseNumber);

  /// تبديل حالة الآية المحفوظة
  Future<Either<Failure, bool>> toggleVerseBookmark(
      int surahNumber, int verseNumber);

  /// تحديث آخر قراءة
  Future<Either<Failure, bool>> updateLastRead(
      int surahNumber, int verseNumber);

  /// الحصول على إحصائيات القراءة
  Future<Either<Failure, QuranStats>> getReadingStats();

  /// إضافة ملاحظة شخصية للآية
  Future<Either<Failure, bool>> addVerseNote(
      int surahNumber, int verseNumber, String note);

  /// إضافة علامة للآية
  Future<Either<Failure, bool>> addVerseTag(
      int surahNumber, int verseNumber, String tag);

  /// حذف علامة من الآية
  Future<Either<Failure, bool>> removeVerseTag(
      int surahNumber, int verseNumber, String tag);

  /// الحصول على السورة مع الترجمة المحددة
  Future<Either<Failure, QuranEntity>> getSurahWithTranslation(
      int surahNumber, String language);
}

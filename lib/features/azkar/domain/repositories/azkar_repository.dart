import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/azkar_entity.dart';

/// مستودع البيانات الخاص بالأذكار
/// Azkar Repository Interface
abstract class AzkarRepository {
  /// الحصول على جميع الأذكار
  Future<Either<Failure, List<AzkarEntity>>> getAllAzkar();

  /// الحصول على الأذكار حسب الفئة
  Future<Either<Failure, List<AzkarEntity>>> getAzkarByCategory(
      String category);

  /// الحصول على الأذكار المفضلة
  Future<Either<Failure, List<AzkarEntity>>> getFavoriteAzkar();

  /// الحصول على ذكر معين بالمعرف
  Future<Either<Failure, AzkarEntity>> getAzkarById(int id);

  /// تحديث ذكر
  Future<Either<Failure, AzkarEntity>> updateAzkar(AzkarEntity azkar);

  /// زيادة عداد الذكر
  Future<Either<Failure, AzkarEntity>> incrementAzkarCount(int id);

  /// إعادة تعيين عداد الذكر
  Future<Either<Failure, AzkarEntity>> resetAzkarCount(int id);

  /// تبديل حالة المفضلة
  Future<Either<Failure, AzkarEntity>> toggleAzkarFavorite(int id);

  /// إضافة ملاحظة شخصية
  Future<Either<Failure, AzkarEntity>> addNote(int id, String note);

  /// الحصول على إحصائيات الأذكار
  Future<Either<Failure, AzkarStats>> getAzkarStatistics();

  /// البحث في الأذكار
  Future<Either<Failure, List<AzkarEntity>>> searchAzkar(String query);

  /// تحميل الأذكار من الملفات المحلية
  Future<Either<Failure, void>> loadAzkarFromAssets();

  /// إعادة تعيين جميع الأذكار (البداية من جديد)
  Future<Either<Failure, void>> resetAllAzkar();

  /// الحصول على أذكار اليوم (حسب الوقت)
  Future<Either<Failure, List<AzkarEntity>>> getTodaysAzkar();
}

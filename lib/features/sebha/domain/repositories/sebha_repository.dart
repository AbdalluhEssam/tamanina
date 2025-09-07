import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sebha_entity.dart';

/// مستودع البيانات الخاص بالتسبيح
/// Sebha Repository Interface
abstract class SebhaRepository {
  /// الحصول على جميع التسابيح المحفوظة
  /// Get all saved sebha items
  Future<Either<Failure, List<SebhaEntity>>> getAllSebhaItems();

  /// الحصول على تسبيح معين بالمعرف
  /// Get specific sebha item by ID
  Future<Either<Failure, SebhaEntity>> getSebhaById(int id);

  /// حفظ أو تحديث تسبيح
  /// Save or update sebha item
  Future<Either<Failure, SebhaEntity>> saveSebhaItem(SebhaEntity sebhaItem);

  /// حذف تسبيح
  /// Delete sebha item
  Future<Either<Failure, void>> deleteSebhaItem(int id);

  /// زيادة عداد التسبيح
  /// Increment sebha counter
  Future<Either<Failure, SebhaEntity>> incrementSebhaCount(int id);

  /// إعادة تعيين عداد التسبيح
  /// Reset sebha counter
  Future<Either<Failure, SebhaEntity>> resetSebhaCount(int id);

  /// الحصول على إجمالي إحصائيات التسبيح
  /// Get total sebha statistics
  Future<Either<Failure, SebhaStats>> getSebhaStatistics();

  /// إنشاء تسبيح افتراضي (إذا لم يوجد)
  /// Create default sebha items (if none exist)
  Future<Either<Failure, List<SebhaEntity>>> createDefaultSebhaItems();
}

/// إحصائيات التسبيح
/// Sebha Statistics Model
class SebhaStats {
  final int totalItemsCount; // إجمالي عدد التسابيح
  final int totalLifetimeCount; // إجمالي العد عبر كل الأوقات
  final int todayCount; // عدد اليوم
  final int thisWeekCount; // عدد هذا الأسبوع
  final int thisMonthCount; // عدد هذا الشهر
  final SebhaEntity? mostUsedSebha; // التسبيح الأكثر استخداماً
  final DateTime? lastUsedAt; // آخر وقت استخدام

  const SebhaStats({
    required this.totalItemsCount,
    required this.totalLifetimeCount,
    required this.todayCount,
    required this.thisWeekCount,
    required this.thisMonthCount,
    this.mostUsedSebha,
    this.lastUsedAt,
  });

  /// إنشاء نسخة فارغة من الإحصائيات
  const SebhaStats.empty()
      : totalItemsCount = 0,
        totalLifetimeCount = 0,
        todayCount = 0,
        thisWeekCount = 0,
        thisMonthCount = 0,
        mostUsedSebha = null,
        lastUsedAt = null;
}

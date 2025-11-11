import 'package:equatable/equatable.dart';

/// نموذج البيانات الخاص بالأذكار
/// Azkar (Islamic Remembrance) Data Model
class AzkarEntity extends Equatable {
  final int id;
  final String category; // فئة الذكر (صباح، مساء، نوم، إلخ)
  final String title; // عنوان الذكر
  final String arabicText; // النص العربي
  final String transliteration; // النطق بالحروف الإنجليزية (اختياري)
  final String translation; // الترجمة
  final String reference; // المرجع (الكتاب والسنة)
  final int repeatCount; // عدد مرات التكرار المطلوبة
  final int currentCount; // العدد الحالي للتكرار
  final String audioUrl; // رابط الصوت (اختياري)
  final bool isFavorite; // هل هو مفضل
  final bool isCompleted; // هل تم الانتهاء من الذكر
  final int order; // ترتيب الذكر في الفئة
  final DateTime? lastReadAt; // آخر مرة تم قراءته
  final List<String> benefits; // فوائد الذكر
  final String? note; // ملاحظة شخصية

  const AzkarEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.arabicText,
    required this.translation,
    required this.reference,
    this.transliteration = '',
    this.repeatCount = 1,
    this.currentCount = 0,
    this.audioUrl = '',
    this.isFavorite = false,
    this.isCompleted = false,
    this.order = 0,
    this.lastReadAt,
    this.benefits = const [],
    this.note,
  });

  /// إنشاء نسخة جديدة مع تحديث بعض القيم
  AzkarEntity copyWith({
    int? id,
    String? category,
    String? title,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? reference,
    int? repeatCount,
    int? currentCount,
    String? audioUrl,
    bool? isFavorite,
    bool? isCompleted,
    int? order,
    DateTime? lastReadAt,
    List<String>? benefits,
    String? note,
  }) {
    return AzkarEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      repeatCount: repeatCount ?? this.repeatCount,
      currentCount: currentCount ?? this.currentCount,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      benefits: benefits ?? this.benefits,
      note: note ?? this.note,
    );
  }

  /// زيادة العد الحالي
  AzkarEntity incrementCount() {
    final newCount = currentCount + 1;
    final completed = newCount >= repeatCount;

    return copyWith(
      currentCount: newCount,
      isCompleted: completed,
      lastReadAt: DateTime.now(),
    );
  }

  /// إعادة تعيين العد
  AzkarEntity resetCount() {
    return copyWith(
      currentCount: 0,
      isCompleted: false,
    );
  }

  /// تبديل حالة المفضلة
  AzkarEntity toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  /// حساب النسبة المئوية للإنجاز
  double get completionPercentage {
    if (repeatCount == 0) return 1.0;
    return (currentCount / repeatCount).clamp(0.0, 1.0);
  }

  /// العدد المتبقي
  int get remainingCount {
    final remaining = repeatCount - currentCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// هل تم الانتهاء من الذكر
  bool get isFinished => currentCount >= repeatCount;

  /// هل يحتوي على ملف صوتي
  bool get hasAudio => audioUrl.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        arabicText,
        transliteration,
        translation,
        reference,
        repeatCount,
        currentCount,
        audioUrl,
        isFavorite,
        isCompleted,
        order,
        lastReadAt,
        benefits,
        note,
      ];
}

/// أنواع فئات الأذكار
enum AzkarCategory {
  morning('أذكار الصباح', 'Morning Azkar'),
  evening('أذكار المساء', 'Evening Azkar'),
  afterPrayer('أذكار ما بعد الصلاة', 'Post-Prayer Azkar'),
  beforeSleep('أذكار النوم', 'Sleeping Azkar'),
  wakeUp('أذكار الاستيقاظ', 'Wake Up Azkar'),
  travel('أذكار السفر', 'Travel Azkar'),
  food('أذكار الطعام', 'Food Azkar'),
  general('أذكار عامة', 'General Azkar'),
  protection('أذكار الحفظ والحماية', 'Protection Azkar'),
  repentance('أذكار التوبة', 'Repentance Azkar'),
  dua('الأدعية', 'Supplications');

  const AzkarCategory(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;

  /// الحصول على الاسم حسب اللغة
  String getLocalizedName(bool isArabic) {
    return isArabic ? arabicName : englishName;
  }
}

/// نموذج إحصائيات الأذكار
class AzkarStats {
  final int totalAzkarCount; // إجمالي عدد الأذكار
  final int completedTodayCount; // عدد الأذكار المكتملة اليوم
  final int favoriteCount; // عدد الأذكار المفضلة
  final Map<String, int> categoryStats; // إحصائيات حسب الفئة
  final AzkarEntity? mostReadAzkar; // الذكر الأكثر قراءة
  final double averageCompletionRate; // متوسط معدل الإنجاز

  const AzkarStats({
    required this.totalAzkarCount,
    required this.completedTodayCount,
    required this.favoriteCount,
    required this.categoryStats,
    this.mostReadAzkar,
    required this.averageCompletionRate,
  });

  const AzkarStats.empty()
      : totalAzkarCount = 0,
        completedTodayCount = 0,
        favoriteCount = 0,
        categoryStats = const {},
        mostReadAzkar = null,
        averageCompletionRate = 0.0;
}

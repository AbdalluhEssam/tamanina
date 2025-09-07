import 'package:equatable/equatable.dart';

/// نموذج البيانات الخاص بالتسبيح
/// Sebha (Tasbih) Data Model
class SebhaEntity extends Equatable {
  final int id;
  final String title; // اسم التسبيح (سبحان الله، الحمد لله، إلخ)
  final String arabicText; // النص العربي
  final String transliteration; // النطق بالحروف الإنجليزية
  final String meaning; // المعنى باللغة العربية/الإنجليزية
  final int currentCount; // العدد الحالي
  final int targetCount; // العدد المستهدف (33، 100، إلخ)
  final bool isCompleted; // هل تم الانتهاء من العدد المطلوب
  final DateTime? lastUsedAt; // آخر مرة تم استخدامه
  final int totalLifetimeCount; // إجمالي العدد عبر كل الأوقات

  const SebhaEntity({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.meaning,
    this.currentCount = 0,
    this.targetCount = 33,
    this.isCompleted = false,
    this.lastUsedAt,
    this.totalLifetimeCount = 0,
  });

  /// إنشاء نسخة جديدة مع تحديث بعض القيم
  SebhaEntity copyWith({
    int? id,
    String? title,
    String? arabicText,
    String? transliteration,
    String? meaning,
    int? currentCount,
    int? targetCount,
    bool? isCompleted,
    DateTime? lastUsedAt,
    int? totalLifetimeCount,
  }) {
    return SebhaEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      isCompleted: isCompleted ?? this.isCompleted,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      totalLifetimeCount: totalLifetimeCount ?? this.totalLifetimeCount,
    );
  }

  /// إعادة تعيين العد الحالي
  SebhaEntity resetCount() {
    return copyWith(
      currentCount: 0,
      isCompleted: false,
      lastUsedAt: DateTime.now(),
    );
  }

  /// زيادة العد بواحد
  SebhaEntity incrementCount() {
    final newCount = currentCount + 1;
    final newTotalCount = totalLifetimeCount + 1;
    final completed = newCount >= targetCount;

    return copyWith(
      currentCount: newCount,
      totalLifetimeCount: newTotalCount,
      isCompleted: completed,
      lastUsedAt: DateTime.now(),
    );
  }

  /// حساب النسبة المئوية للإنجاز
  double get completionPercentage {
    if (targetCount == 0) return 0.0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  /// هل تم الوصول للهدف أم لا
  bool get isTargetReached => currentCount >= targetCount;

  /// العدد المتبقي للوصول للهدف
  int get remainingCount {
    final remaining = targetCount - currentCount;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        arabicText,
        transliteration,
        meaning,
        currentCount,
        targetCount,
        isCompleted,
        lastUsedAt,
        totalLifetimeCount,
      ];

  @override
  String toString() {
    return 'SebhaEntity(id: $id, title: $title, currentCount: $currentCount, targetCount: $targetCount)';
  }
}

/// أنواع التسبيح المختلفة
enum SebhaType {
  subhanAllah('سبحان الله', 'Subhan Allah', 'Glory be to Allah'),
  alhamdulillah('الحمد لله', 'Alhamdulillah', 'Praise be to Allah'),
  laIlahaIllaAllah(
      'لا إله إلا الله', 'La ilaha illa Allah', 'There is no god but Allah'),
  allahuAkbar('الله أكبر', 'Allahu Akbar', 'Allah is the Greatest'),
  astaghfirullah(
      'أستغفر الله', 'Astaghfirullah', 'I seek forgiveness from Allah'),
  laCoolaTe('لا حول ولا قوة إلا بالله', 'La hawla wa la quwwata illa billah',
      'There is no power except with Allah'),
  salawat('اللهم صل على محمد', 'Allahumma salli ala Muhammad',
      'O Allah, send prayers upon Muhammad');

  const SebhaType(this.arabicText, this.transliteration, this.meaning);

  final String arabicText;
  final String transliteration;
  final String meaning;

  /// تحويل النوع إلى SebhaEntity
  SebhaEntity toEntity({
    required int id,
    int targetCount = 33,
  }) {
    return SebhaEntity(
      id: id,
      title: name,
      arabicText: arabicText,
      transliteration: transliteration,
      meaning: meaning,
      targetCount: targetCount,
    );
  }
}

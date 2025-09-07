import 'package:equatable/equatable.dart';
import '../../../prayer/domain/entities/prayer_entity.dart';
import '../../../azkar/domain/entities/azkar_entity.dart';
import '../../../sebha/domain/entities/sebha_entity.dart';
import '../../../quran/domain/entities/quran_entity.dart';

/// نموذج الإحصائيات الشاملة للتطبيق
/// Comprehensive App Statistics Model
class StatisticsEntity extends Equatable {
  final DateTime generatedAt; // تاريخ إنشاء الإحصائيات
  final PrayerStatistics prayerStats; // إحصائيات الصلوات
  final AzkarStatistics azkarStats; // إحصائيات الأذكار
  final SebhaStatistics sebhaStats; // إحصائيات التسبيح
  final QuranStatistics quranStats; // إحصائيات القرآن
  final GeneralUsageStats usageStats; // إحصائيات الاستخدام العامة
  final List<Achievement> achievements; // الإنجازات
  final UserProgress userProgress; // تقدم المستخدم

  const StatisticsEntity({
    required this.generatedAt,
    required this.prayerStats,
    required this.azkarStats,
    required this.sebhaStats,
    required this.quranStats,
    required this.usageStats,
    this.achievements = const [],
    required this.userProgress,
  });

  StatisticsEntity copyWith({
    DateTime? generatedAt,
    PrayerStatistics? prayerStats,
    AzkarStatistics? azkarStats,
    SebhaStatistics? sebhaStats,
    QuranStatistics? quranStats,
    GeneralUsageStats? usageStats,
    List<Achievement>? achievements,
    UserProgress? userProgress,
  }) {
    return StatisticsEntity(
      generatedAt: generatedAt ?? this.generatedAt,
      prayerStats: prayerStats ?? this.prayerStats,
      azkarStats: azkarStats ?? this.azkarStats,
      sebhaStats: sebhaStats ?? this.sebhaStats,
      quranStats: quranStats ?? this.quranStats,
      usageStats: usageStats ?? this.usageStats,
      achievements: achievements ?? this.achievements,
      userProgress: userProgress ?? this.userProgress,
    );
  }

  /// حساب النقاط الإجمالية
  int get totalPoints {
    return prayerStats.totalPoints +
        azkarStats.totalPoints +
        sebhaStats.totalPoints +
        quranStats.totalPoints;
  }

  /// متوسط الأداء اليومي (نسبة مئوية)
  double get dailyAveragePerformance {
    final performances = [
      prayerStats.dailyCompletionRate,
      azkarStats.dailyCompletionRate,
      sebhaStats.dailyUsageRate,
      quranStats.dailyReadingRate,
    ];

    final validPerformances = performances.where((p) => p > 0).toList();
    if (validPerformances.isEmpty) return 0.0;

    return validPerformances.reduce((a, b) => a + b) / validPerformances.length;
  }

  /// الشارة الحالية للمستخدم
  UserBadge get currentBadge {
    final points = totalPoints;
    if (points >= 10000) return UserBadge.master;
    if (points >= 5000) return UserBadge.advanced;
    if (points >= 2000) return UserBadge.intermediate;
    if (points >= 500) return UserBadge.beginner;
    return UserBadge.starter;
  }

  @override
  List<Object> get props => [
        generatedAt,
        prayerStats,
        azkarStats,
        sebhaStats,
        quranStats,
        usageStats,
        achievements,
        userProgress,
      ];
}

/// إحصائيات الصلوات المفصلة
class PrayerStatistics extends Equatable {
  final int totalPrayers; // إجمالي الصلوات
  final int completedPrayers; // الصلوات المؤداة
  final int missedPrayers; // الصلوات الفائتة
  final double completionRate; // معدل الأداء
  final double dailyCompletionRate; // معدل الأداء اليومي
  final int currentStreak; // السلسلة الحالية
  final int longestStreak; // أطول سلسلة
  final Map<PrayerType, int> prayerTypeStats; // إحصائيات حسب نوع الصلاة
  final Map<String, double> weeklyStats; // إحصائيات أسبوعية
  final Map<String, double> monthlyStats; // إحصائيات شهرية
  final int totalPoints; // النقاط المكتسبة
  final DateTime? lastPrayerTime; // آخر وقت صلاة

  const PrayerStatistics({
    required this.totalPrayers,
    required this.completedPrayers,
    required this.missedPrayers,
    required this.completionRate,
    required this.dailyCompletionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.prayerTypeStats,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.totalPoints,
    this.lastPrayerTime,
  });

  const PrayerStatistics.empty()
      : totalPrayers = 0,
        completedPrayers = 0,
        missedPrayers = 0,
        completionRate = 0.0,
        dailyCompletionRate = 0.0,
        currentStreak = 0,
        longestStreak = 0,
        prayerTypeStats = const {},
        weeklyStats = const {},
        monthlyStats = const {},
        totalPoints = 0,
        lastPrayerTime = null;

  @override
  List<Object?> get props => [
        totalPrayers,
        completedPrayers,
        missedPrayers,
        completionRate,
        dailyCompletionRate,
        currentStreak,
        longestStreak,
        prayerTypeStats,
        weeklyStats,
        monthlyStats,
        totalPoints,
        lastPrayerTime,
      ];
}

/// إحصائيات الأذكار المفصلة
class AzkarStatistics extends Equatable {
  final int totalAzkar; // إجمالي الأذكار
  final int completedAzkar; // الأذكار المكتملة
  final int favoriteAzkar; // الأذكار المفضلة
  final double completionRate; // معدل الإنجاز
  final double dailyCompletionRate; // معدل الإنجاز اليومي
  final Map<String, int> categoryStats; // إحصائيات حسب الفئة
  final int totalRecitations; // إجمالي التلاوات
  final int totalPoints; // النقاط المكتسبة
  final AzkarEntity? mostReadAzkar; // الذكر الأكثر قراءة
  final Map<String, int> weeklyReadings; // القراءات الأسبوعية
  final int currentDailyStreak; // السلسلة اليومية الحالية

  const AzkarStatistics({
    required this.totalAzkar,
    required this.completedAzkar,
    required this.favoriteAzkar,
    required this.completionRate,
    required this.dailyCompletionRate,
    required this.categoryStats,
    required this.totalRecitations,
    required this.totalPoints,
    this.mostReadAzkar,
    required this.weeklyReadings,
    required this.currentDailyStreak,
  });

  const AzkarStatistics.empty()
      : totalAzkar = 0,
        completedAzkar = 0,
        favoriteAzkar = 0,
        completionRate = 0.0,
        dailyCompletionRate = 0.0,
        categoryStats = const {},
        totalRecitations = 0,
        totalPoints = 0,
        mostReadAzkar = null,
        weeklyReadings = const {},
        currentDailyStreak = 0;

  @override
  List<Object?> get props => [
        totalAzkar,
        completedAzkar,
        favoriteAzkar,
        completionRate,
        dailyCompletionRate,
        categoryStats,
        totalRecitations,
        totalPoints,
        mostReadAzkar,
        weeklyReadings,
        currentDailyStreak,
      ];
}

/// إحصائيات التسبيح المفصلة
class SebhaStatistics extends Equatable {
  final int totalSebhaItems; // إجمالي عناصر التسبيح
  final int totalCounts; // إجمالي العدات
  final int todayCounts; // عدات اليوم
  final int weekCounts; // عدات الأسبوع
  final int monthCounts; // عدات الشهر
  final double dailyUsageRate; // معدل الاستخدام اليومي
  final SebhaEntity? mostUsedSebha; // التسبيح الأكثر استخداماً
  final int totalCompletedSessions; // إجمالي الجلسات المكتملة
  final int totalPoints; // النقاط المكتسبة
  final Map<String, int> sebhaTypeStats; // إحصائيات حسب نوع التسبيح
  final int currentSessionStreak; // السلسلة الحالية للجلسات

  const SebhaStatistics({
    required this.totalSebhaItems,
    required this.totalCounts,
    required this.todayCounts,
    required this.weekCounts,
    required this.monthCounts,
    required this.dailyUsageRate,
    this.mostUsedSebha,
    required this.totalCompletedSessions,
    required this.totalPoints,
    required this.sebhaTypeStats,
    required this.currentSessionStreak,
  });

  const SebhaStatistics.empty()
      : totalSebhaItems = 0,
        totalCounts = 0,
        todayCounts = 0,
        weekCounts = 0,
        monthCounts = 0,
        dailyUsageRate = 0.0,
        mostUsedSebha = null,
        totalCompletedSessions = 0,
        totalPoints = 0,
        sebhaTypeStats = const {},
        currentSessionStreak = 0;

  @override
  List<Object?> get props => [
        totalSebhaItems,
        totalCounts,
        todayCounts,
        weekCounts,
        monthCounts,
        dailyUsageRate,
        mostUsedSebha,
        totalCompletedSessions,
        totalPoints,
        sebhaTypeStats,
        currentSessionStreak,
      ];
}

/// إحصائيات القرآن المفصلة
class QuranStatistics extends Equatable {
  final int totalSurahs; // إجمالي السور
  final int readSurahs; // السور المقروءة
  final int totalVerses; // إجمالي الآيات
  final int readVerses; // الآيات المقروءة
  final double readingProgress; // تقدم القراءة
  final double dailyReadingRate; // معدل القراءة اليومي
  final int favoriteVersesCount; // عدد الآيات المفضلة
  final int bookmarkedVersesCount; // عدد الآيات المحفوظة
  final QuranEntity? currentlyReading; // السورة الحالية قيد القراءة
  final int totalReadingSessions; // إجمالي جلسات القراءة
  final int totalPoints; // النقاط المكتسبة
  final Map<int, double> surahProgress; // تقدم كل سورة

  const QuranStatistics({
    required this.totalSurahs,
    required this.readSurahs,
    required this.totalVerses,
    required this.readVerses,
    required this.readingProgress,
    required this.dailyReadingRate,
    required this.favoriteVersesCount,
    required this.bookmarkedVersesCount,
    this.currentlyReading,
    required this.totalReadingSessions,
    required this.totalPoints,
    required this.surahProgress,
  });

  const QuranStatistics.empty()
      : totalSurahs = 114,
        readSurahs = 0,
        totalVerses = 6236,
        readVerses = 0,
        readingProgress = 0.0,
        dailyReadingRate = 0.0,
        favoriteVersesCount = 0,
        bookmarkedVersesCount = 0,
        currentlyReading = null,
        totalReadingSessions = 0,
        totalPoints = 0,
        surahProgress = const {};

  @override
  List<Object?> get props => [
        totalSurahs,
        readSurahs,
        totalVerses,
        readVerses,
        readingProgress,
        dailyReadingRate,
        favoriteVersesCount,
        bookmarkedVersesCount,
        currentlyReading,
        totalReadingSessions,
        totalPoints,
        surahProgress,
      ];
}

/// إحصائيات الاستخدام العامة
class GeneralUsageStats extends Equatable {
  final DateTime? firstOpenDate; // تاريخ أول فتح
  final int totalAppOpens; // إجمالي مرات فتح التطبيق
  final int totalUsageMinutes; // إجمالي دقائق الاستخدام
  final int consecutiveDays; // الأيام المتتالية
  final double averageSessionDuration; // متوسط مدة الجلسة (بالدقائق)
  final Map<String, int> featureUsageStats; // إحصائيات استخدام المميزات
  final List<String> mostUsedFeatures; // المميزات الأكثر استخداماً
  final Map<String, double> timeSpentPerFeature; // الوقت المقضي في كل مميزة

  const GeneralUsageStats({
    this.firstOpenDate,
    required this.totalAppOpens,
    required this.totalUsageMinutes,
    required this.consecutiveDays,
    required this.averageSessionDuration,
    required this.featureUsageStats,
    required this.mostUsedFeatures,
    required this.timeSpentPerFeature,
  });

  const GeneralUsageStats.empty()
      : firstOpenDate = null,
        totalAppOpens = 0,
        totalUsageMinutes = 0,
        consecutiveDays = 0,
        averageSessionDuration = 0.0,
        featureUsageStats = const {},
        mostUsedFeatures = const [],
        timeSpentPerFeature = const {};

  @override
  List<Object?> get props => [
        firstOpenDate,
        totalAppOpens,
        totalUsageMinutes,
        consecutiveDays,
        averageSessionDuration,
        featureUsageStats,
        mostUsedFeatures,
        timeSpentPerFeature,
      ];
}

/// نموذج الإنجازات
class Achievement extends Equatable {
  final String id; // معرف الإنجاز
  final String title; // العنوان
  final String description; // الوصف
  final String iconPath; // مسار الأيقونة
  final int pointsReward; // نقاط المكافأة
  final bool isUnlocked; // هل تم إلغاء القفل
  final DateTime? unlockedAt; // تاريخ إلغاء القفل
  final AchievementCategory category; // فئة الإنجاز
  final int progress; // التقدم الحالي
  final int target; // الهدف المطلوب

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.pointsReward,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.category,
    this.progress = 0,
    required this.target,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    int? pointsReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    AchievementCategory? category,
    int? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      pointsReward: pointsReward ?? this.pointsReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  /// نسبة التقدم
  double get progressPercentage {
    if (target == 0) return 1.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// هل يمكن إلغاء القفل
  bool get canUnlock => progress >= target && !isUnlocked;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        iconPath,
        pointsReward,
        isUnlocked,
        unlockedAt,
        category,
        progress,
        target,
      ];
}

/// فئات الإنجازات
enum AchievementCategory {
  prayer('الصلوات', 'Prayers'),
  azkar('الأذكار', 'Azkar'),
  sebha('التسبيح', 'Sebha'),
  quran('القرآن', 'Quran'),
  general('عامة', 'General');

  const AchievementCategory(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// تقدم المستخدم
class UserProgress extends Equatable {
  final int currentLevel; // المستوى الحالي
  final int totalPoints; // إجمالي النقاط
  final int pointsToNextLevel; // النقاط المطلوبة للمستوى التالي
  final UserBadge currentBadge; // الشارة الحالية
  final double overallProgress; // التقدم الإجمالي
  final List<String> unlockedFeatures; // المميزات المفتوحة
  final Map<String, double> skillLevels; // مستويات المهارات

  const UserProgress({
    required this.currentLevel,
    required this.totalPoints,
    required this.pointsToNextLevel,
    required this.currentBadge,
    required this.overallProgress,
    this.unlockedFeatures = const [],
    this.skillLevels = const {},
  });

  const UserProgress.initial()
      : currentLevel = 1,
        totalPoints = 0,
        pointsToNextLevel = 100,
        currentBadge = UserBadge.starter,
        overallProgress = 0.0,
        unlockedFeatures = const [],
        skillLevels = const {};

  @override
  List<Object> get props => [
        currentLevel,
        totalPoints,
        pointsToNextLevel,
        currentBadge,
        overallProgress,
        unlockedFeatures,
        skillLevels,
      ];
}

/// شارات المستخدم
enum UserBadge {
  starter('مبتدئ', 'Starter', 0),
  beginner('مبتدى', 'Beginner', 500),
  intermediate('متوسط', 'Intermediate', 2000),
  advanced('متقدم', 'Advanced', 5000),
  master('محترف', 'Master', 10000);

  const UserBadge(this.arabicName, this.englishName, this.requiredPoints);

  final String arabicName;
  final String englishName;
  final int requiredPoints;
}

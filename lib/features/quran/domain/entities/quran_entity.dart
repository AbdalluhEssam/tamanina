import 'package:equatable/equatable.dart';

/// نموذج البيانات الخاص بالقرآن الكريم
/// Quran Data Model
class QuranEntity extends Equatable {
  final int surahNumber; // رقم السورة
  final String surahNameArabic; // اسم السورة بالعربي
  final String surahNameEnglish; // اسم السورة بالإنجليزي
  final String surahNameTransliteration; // اسم السورة بالحروف الإنجليزية
  final int totalVerses; // إجمالي عدد الآيات
  final String revelationType; // مكية أو مدنية
  final int revelationOrder; // ترتيب النزول
  final String surahMeaning; // معنى اسم السورة
  final List<VerseEntity> verses; // الآيات
  final bool isFavorite; // هل السورة مفضلة
  final DateTime? lastReadAt; // آخر وقت قراءة
  final int lastReadVerse; // آخر آية تم قراءتها

  const QuranEntity({
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.surahNameTransliteration,
    required this.totalVerses,
    required this.revelationType,
    required this.revelationOrder,
    required this.surahMeaning,
    this.verses = const [],
    this.isFavorite = false,
    this.lastReadAt,
    this.lastReadVerse = 0,
  });

  QuranEntity copyWith({
    int? surahNumber,
    String? surahNameArabic,
    String? surahNameEnglish,
    String? surahNameTransliteration,
    int? totalVerses,
    String? revelationType,
    int? revelationOrder,
    String? surahMeaning,
    List<VerseEntity>? verses,
    bool? isFavorite,
    DateTime? lastReadAt,
    int? lastReadVerse,
  }) {
    return QuranEntity(
      surahNumber: surahNumber ?? this.surahNumber,
      surahNameArabic: surahNameArabic ?? this.surahNameArabic,
      surahNameEnglish: surahNameEnglish ?? this.surahNameEnglish,
      surahNameTransliteration:
          surahNameTransliteration ?? this.surahNameTransliteration,
      totalVerses: totalVerses ?? this.totalVerses,
      revelationType: revelationType ?? this.revelationType,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      surahMeaning: surahMeaning ?? this.surahMeaning,
      verses: verses ?? this.verses,
      isFavorite: isFavorite ?? this.isFavorite,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
    );
  }

  /// تحديث آخر آية مقروءة
  QuranEntity updateLastRead(int verseNumber) {
    return copyWith(
      lastReadAt: DateTime.now(),
      lastReadVerse: verseNumber,
    );
  }

  /// تبديل حالة المفضلة
  QuranEntity toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  /// حساب نسبة القراءة
  double get readingProgress {
    if (totalVerses == 0) return 0.0;
    return (lastReadVerse / totalVerses).clamp(0.0, 1.0);
  }

  /// هل السورة مكتملة القراءة
  bool get isFullyRead => lastReadVerse >= totalVerses;

  /// هل السورة مكية
  bool get isMakki =>
      revelationType.toLowerCase().contains('مكية') ||
      revelationType.toLowerCase().contains('makki');

  /// هل السورة مدنية
  bool get isMadani =>
      revelationType.toLowerCase().contains('مدنية') ||
      revelationType.toLowerCase().contains('madani');

  @override
  List<Object?> get props => [
        surahNumber,
        surahNameArabic,
        surahNameEnglish,
        surahNameTransliteration,
        totalVerses,
        revelationType,
        revelationOrder,
        surahMeaning,
        verses,
        isFavorite,
        lastReadAt,
        lastReadVerse,
      ];
}

/// نموذج البيانات الخاص بالآية
/// Verse Data Model
class VerseEntity extends Equatable {
  final int surahNumber; // رقم السورة
  final int verseNumber; // رقم الآية
  final String arabicText; // النص العربي
  final String transliteration; // النطق بالحروف الإنجليزية
  final String translation; // الترجمة
  final String? tafseer; // التفسير (اختياري)
  final List<String> keywords; // الكلمات المفتاحية للبحث
  final String audioUrl; // رابط الصوت
  final bool isFavorite; // هل الآية مفضلة
  final bool isBookmarked; // هل الآية محفوظة كإشارة مرجعية
  final List<String> tags; // العلامات الشخصية
  final String? personalNote; // ملاحظة شخصية

  const VerseEntity({
    required this.surahNumber,
    required this.verseNumber,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.tafseer,
    this.keywords = const [],
    this.audioUrl = '',
    this.isFavorite = false,
    this.isBookmarked = false,
    this.tags = const [],
    this.personalNote,
  });

  VerseEntity copyWith({
    int? surahNumber,
    int? verseNumber,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? tafseer,
    List<String>? keywords,
    String? audioUrl,
    bool? isFavorite,
    bool? isBookmarked,
    List<String>? tags,
    String? personalNote,
  }) {
    return VerseEntity(
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      tafseer: tafseer ?? this.tafseer,
      keywords: keywords ?? this.keywords,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      personalNote: personalNote ?? this.personalNote,
    );
  }

  /// تبديل حالة المفضلة
  VerseEntity toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  /// تبديل حالة الإشارة المرجعية
  VerseEntity toggleBookmark() {
    return copyWith(isBookmarked: !isBookmarked);
  }

  /// إضافة علامة
  VerseEntity addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// حذف علامة
  VerseEntity removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// تحديث الملاحظة الشخصية
  VerseEntity updateNote(String note) {
    return copyWith(personalNote: note.isEmpty ? null : note);
  }

  /// هل تحتوي على صوت
  bool get hasAudio => audioUrl.isNotEmpty;

  /// المرجع الكامل (السورة:الآية)
  String get fullReference => '$surahNumber:$verseNumber';

  @override
  List<Object?> get props => [
        surahNumber,
        verseNumber,
        arabicText,
        transliteration,
        translation,
        tafseer,
        keywords,
        audioUrl,
        isFavorite,
        isBookmarked,
        tags,
        personalNote,
      ];
}

/// إحصائيات القرآن
class QuranStats {
  final int totalSurahsRead; // إجمالي السور المقروءة
  final int totalVersesRead; // إجمالي الآيات المقروءة
  final int favoriteSurahsCount; // عدد السور المفضلة
  final int favoriteVersesCount; // عدد الآيات المفضلة
  final int bookmarkedVersesCount; // عدد الآيات المحفوظة
  final double overallProgress; // التقدم الإجمالي
  final QuranEntity? currentlyReading; // السورة الحالية قيد القراءة
  final DateTime? lastReadingSession; // آخر جلسة قراءة
  final Map<int, double> surahProgress; // تقدم كل سورة

  const QuranStats({
    required this.totalSurahsRead,
    required this.totalVersesRead,
    required this.favoriteSurahsCount,
    required this.favoriteVersesCount,
    required this.bookmarkedVersesCount,
    required this.overallProgress,
    this.currentlyReading,
    this.lastReadingSession,
    required this.surahProgress,
  });

  const QuranStats.empty()
      : totalSurahsRead = 0,
        totalVersesRead = 0,
        favoriteSurahsCount = 0,
        favoriteVersesCount = 0,
        bookmarkedVersesCount = 0,
        overallProgress = 0.0,
        currentlyReading = null,
        lastReadingSession = null,
        surahProgress = const {};
}

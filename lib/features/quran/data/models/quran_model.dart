import '../../domain/entities/quran_entity.dart';

class QuranModel {
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final String surahNameTransliteration;
  final int totalVerses;
  final String revelationType;
  final int revelationOrder;
  final String surahMeaning;
  final List<VerseEntity> verses;
  final bool isFavorite;
  final DateTime? lastReadAt;
  final int lastReadVerse;

  const QuranModel({
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

  QuranEntity toEntity() {
    return QuranEntity(
      surahNumber: surahNumber,
      surahNameArabic: surahNameArabic,
      surahNameEnglish: surahNameEnglish,
      surahNameTransliteration: surahNameTransliteration,
      totalVerses: totalVerses,
      revelationType: revelationType,
      revelationOrder: revelationOrder,
      surahMeaning: surahMeaning,
      verses: verses,
      isFavorite: isFavorite,
      lastReadAt: lastReadAt,
      lastReadVerse: lastReadVerse,
    );
  }

  factory QuranModel.fromEntity(QuranEntity entity) {
    return QuranModel(
      surahNumber: entity.surahNumber,
      surahNameArabic: entity.surahNameArabic,
      surahNameEnglish: entity.surahNameEnglish,
      surahNameTransliteration: entity.surahNameTransliteration,
      totalVerses: entity.totalVerses,
      revelationType: entity.revelationType,
      revelationOrder: entity.revelationOrder,
      surahMeaning: entity.surahMeaning,
      verses: entity.verses,
      isFavorite: entity.isFavorite,
      lastReadAt: entity.lastReadAt,
      lastReadVerse: entity.lastReadVerse,
    );
  }
}

class VerseModel {
  final int surahNumber;
  final int verseNumber;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? tafseer;
  final List<String> keywords;
  final String audioUrl;
  final bool isFavorite;
  final bool isBookmarked;
  final List<String> tags;
  final String? personalNote;

  const VerseModel({
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

  VerseEntity toEntity() {
    return VerseEntity(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation,
      tafseer: tafseer,
      keywords: keywords,
      audioUrl: audioUrl,
      isFavorite: isFavorite,
      isBookmarked: isBookmarked,
      tags: tags,
      personalNote: personalNote,
    );
  }

  factory VerseModel.fromEntity(VerseEntity entity) {
    return VerseModel(
      surahNumber: entity.surahNumber,
      verseNumber: entity.verseNumber,
      arabicText: entity.arabicText,
      transliteration: entity.transliteration,
      translation: entity.translation,
      tafseer: entity.tafseer,
      keywords: entity.keywords,
      audioUrl: entity.audioUrl,
      isFavorite: entity.isFavorite,
      isBookmarked: entity.isBookmarked,
      tags: entity.tags,
      personalNote: entity.personalNote,
    );
  }
}

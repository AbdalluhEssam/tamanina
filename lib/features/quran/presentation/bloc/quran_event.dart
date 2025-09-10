import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load all surahs
class LoadAllSurahs extends QuranEvent {}

// Load specific surah
class LoadSurah extends QuranEvent {
  final int surahNumber;

  LoadSurah(this.surahNumber);

  @override
  List<Object> get props => [surahNumber];
}

// Load specific verse
class LoadVerse extends QuranEvent {
  final int surahNumber;
  final int verseNumber;

  LoadVerse(this.surahNumber, this.verseNumber);

  @override
  List<Object> get props => [surahNumber, verseNumber];
}

// Search in Quran
class SearchQuran extends QuranEvent {
  final String query;

  SearchQuran(this.query);

  @override
  List<Object> get props => [query];
}

// Load favorites
class LoadFavoriteSurahs extends QuranEvent {}

class LoadFavoriteVerses extends QuranEvent {}

class LoadBookmarkedVerses extends QuranEvent {}

// Toggle favorites and bookmarks
class ToggleSurahFavorite extends QuranEvent {
  final int surahNumber;

  ToggleSurahFavorite(this.surahNumber);

  @override
  List<Object> get props => [surahNumber];
}

class ToggleVerseFavorite extends QuranEvent {
  final int surahNumber;
  final int verseNumber;

  ToggleVerseFavorite(this.surahNumber, this.verseNumber);

  @override
  List<Object> get props => [surahNumber, verseNumber];
}

class ToggleVerseBookmark extends QuranEvent {
  final int surahNumber;
  final int verseNumber;

  ToggleVerseBookmark(this.surahNumber, this.verseNumber);

  @override
  List<Object> get props => [surahNumber, verseNumber];
}

// Update reading progress
class UpdateLastRead extends QuranEvent {
  final int surahNumber;
  final int verseNumber;

  UpdateLastRead(this.surahNumber, this.verseNumber);

  @override
  List<Object> get props => [surahNumber, verseNumber];
}

// Load reading stats
class LoadReadingStats extends QuranEvent {}

// Verse notes and tags
class AddVerseNote extends QuranEvent {
  final int surahNumber;
  final int verseNumber;
  final String note;

  AddVerseNote(this.surahNumber, this.verseNumber, this.note);

  @override
  List<Object> get props => [surahNumber, verseNumber, note];
}

class AddVerseTag extends QuranEvent {
  final int surahNumber;
  final int verseNumber;
  final String tag;

  AddVerseTag(this.surahNumber, this.verseNumber, this.tag);

  @override
  List<Object> get props => [surahNumber, verseNumber, tag];
}

class RemoveVerseTag extends QuranEvent {
  final int surahNumber;
  final int verseNumber;
  final String tag;

  RemoveVerseTag(this.surahNumber, this.verseNumber, this.tag);

  @override
  List<Object> get props => [surahNumber, verseNumber, tag];
}

// Load surah with translation
class LoadSurahWithTranslation extends QuranEvent {
  final int surahNumber;
  final String language;

  LoadSurahWithTranslation(this.surahNumber, this.language);

  @override
  List<Object> get props => [surahNumber, language];
}

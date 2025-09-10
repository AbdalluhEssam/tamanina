import 'package:equatable/equatable.dart';
import '../../domain/entities/quran_entity.dart';

abstract class QuranState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class QuranInitial extends QuranState {}

// Loading states
class QuranLoading extends QuranState {}

// Success states
class SurahsLoaded extends QuranState {
  final List<QuranEntity> surahs;

  SurahsLoaded(this.surahs);

  @override
  List<Object> get props => [surahs];
}

class SurahLoaded extends QuranState {
  final QuranEntity surah;

  SurahLoaded(this.surah);

  @override
  List<Object> get props => [surah];
}

class VerseLoaded extends QuranState {
  final VerseEntity verse;

  VerseLoaded(this.verse);

  @override
  List<Object> get props => [verse];
}

class SearchResultsLoaded extends QuranState {
  final List<VerseEntity> verses;
  final String query;

  SearchResultsLoaded(this.verses, this.query);

  @override
  List<Object> get props => [verses, query];
}

class FavoriteSurahsLoaded extends QuranState {
  final List<QuranEntity> surahs;

  FavoriteSurahsLoaded(this.surahs);

  @override
  List<Object> get props => [surahs];
}

class FavoriteVersesLoaded extends QuranState {
  final List<VerseEntity> verses;

  FavoriteVersesLoaded(this.verses);

  @override
  List<Object> get props => [verses];
}

class BookmarkedVersesLoaded extends QuranState {
  final List<VerseEntity> verses;

  BookmarkedVersesLoaded(this.verses);

  @override
  List<Object> get props => [verses];
}

class ReadingStatsLoaded extends QuranState {
  final QuranStats stats;

  ReadingStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

// Action success states
class SurahFavoriteToggled extends QuranState {
  final int surahNumber;
  final bool isFavorite;

  SurahFavoriteToggled(this.surahNumber, this.isFavorite);

  @override
  List<Object> get props => [surahNumber, isFavorite];
}

class VerseFavoriteToggled extends QuranState {
  final int surahNumber;
  final int verseNumber;
  final bool isFavorite;

  VerseFavoriteToggled(this.surahNumber, this.verseNumber, this.isFavorite);

  @override
  List<Object> get props => [surahNumber, verseNumber, isFavorite];
}

class VerseBookmarkToggled extends QuranState {
  final int surahNumber;
  final int verseNumber;
  final bool isBookmarked;

  VerseBookmarkToggled(this.surahNumber, this.verseNumber, this.isBookmarked);

  @override
  List<Object> get props => [surahNumber, verseNumber, isBookmarked];
}

class LastReadUpdated extends QuranState {
  final int surahNumber;
  final int verseNumber;

  LastReadUpdated(this.surahNumber, this.verseNumber);

  @override
  List<Object> get props => [surahNumber, verseNumber];
}

class VerseNoteAdded extends QuranState {
  final int surahNumber;
  final int verseNumber;
  final String note;

  VerseNoteAdded(this.surahNumber, this.verseNumber, this.note);

  @override
  List<Object> get props => [surahNumber, verseNumber, note];
}

class VerseTagAdded extends QuranState {
  final int surahNumber;
  final int verseNumber;
  final String tag;

  VerseTagAdded(this.surahNumber, this.verseNumber, this.tag);

  @override
  List<Object> get props => [surahNumber, verseNumber, tag];
}

class VerseTagRemoved extends QuranState {
  final int surahNumber;
  final int verseNumber;
  final String tag;

  VerseTagRemoved(this.surahNumber, this.verseNumber, this.tag);

  @override
  List<Object> get props => [surahNumber, verseNumber, tag];
}

// Error state
class QuranError extends QuranState {
  final String message;

  QuranError(this.message);

  @override
  List<Object> get props => [message];
}

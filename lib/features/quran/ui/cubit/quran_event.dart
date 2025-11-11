import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all surahs
class LoadAllSurahs extends QuranEvent {
  const LoadAllSurahs();
}

/// Event to load a specific surah
class LoadSurah extends QuranEvent {
  final int surahNumber;

  const LoadSurah(this.surahNumber);

  @override
  List<Object> get props => [surahNumber];
}

/// Event to load a specific verse
class LoadVerse extends QuranEvent {
  final int surahNumber;
  final int verseNumber;

  const LoadVerse(this.surahNumber, this.verseNumber);

  @override
  List<Object> get props => [surahNumber, verseNumber];
}

/// Event to search in Quran
class SearchQuran extends QuranEvent {
  final String query;

  const SearchQuran(this.query);

  @override
  List<Object> get props => [query];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../../domain/usecases/quran_usecases.dart';
import 'quran_event.dart';
import 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetAllSurahsUseCase getAllSurahsUseCase;
  final GetSurahUseCase getSurahUseCase;
  final GetVerseUseCase getVerseUseCase;
  final SearchQuranUseCase searchQuranUseCase;
  final GetFavoriteSurahsUseCase getFavoriteSurahsUseCase;
  final GetFavoriteVersesUseCase getFavoriteVersesUseCase;
  final GetBookmarkedVersesUseCase getBookmarkedVersesUseCase;
  final ToggleSurahFavoriteUseCase toggleSurahFavoriteUseCase;
  final ToggleVerseFavoriteUseCase toggleVerseFavoriteUseCase;
  final ToggleVerseBookmarkUseCase toggleVerseBookmarkUseCase;
  final UpdateLastReadUseCase updateLastReadUseCase;
  final GetReadingStatsUseCase getReadingStatsUseCase;

  QuranBloc({
    required this.getAllSurahsUseCase,
    required this.getSurahUseCase,
    required this.getVerseUseCase,
    required this.searchQuranUseCase,
    required this.getFavoriteSurahsUseCase,
    required this.getFavoriteVersesUseCase,
    required this.getBookmarkedVersesUseCase,
    required this.toggleSurahFavoriteUseCase,
    required this.toggleVerseFavoriteUseCase,
    required this.toggleVerseBookmarkUseCase,
    required this.updateLastReadUseCase,
    required this.getReadingStatsUseCase,
  }) : super(QuranInitial()) {
    on<LoadAllSurahs>(_onLoadAllSurahs);
    on<LoadSurah>(_onLoadSurah);
    on<LoadVerse>(_onLoadVerse);
    on<SearchQuran>(_onSearchQuran);
    on<LoadFavoriteSurahs>(_onLoadFavoriteSurahs);
    on<LoadFavoriteVerses>(_onLoadFavoriteVerses);
    on<LoadBookmarkedVerses>(_onLoadBookmarkedVerses);
    on<ToggleSurahFavorite>(_onToggleSurahFavorite);
    on<ToggleVerseFavorite>(_onToggleVerseFavorite);
    on<ToggleVerseBookmark>(_onToggleVerseBookmark);
    on<UpdateLastRead>(_onUpdateLastRead);
    on<LoadReadingStats>(_onLoadReadingStats);
    on<AddVerseNote>(_onAddVerseNote);
    on<AddVerseTag>(_onAddVerseTag);
    on<RemoveVerseTag>(_onRemoveVerseTag);
    on<LoadSurahWithTranslation>(_onLoadSurahWithTranslation);
  }

  Future<void> _onLoadAllSurahs(
      LoadAllSurahs event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await getAllSurahsUseCase(const NoParams());
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (surahs) => emit(SurahsLoaded(surahs)),
    );
  }

  Future<void> _onLoadSurah(LoadSurah event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result =
        await getSurahUseCase(GetSurahParams(surahNumber: event.surahNumber));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (surah) => emit(SurahLoaded(surah)),
    );
  }

  Future<void> _onLoadVerse(LoadVerse event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await getVerseUseCase(GetVerseParams(
      surahNumber: event.surahNumber,
      verseNumber: event.verseNumber,
    ));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (verse) => emit(VerseLoaded(verse)),
    );
  }

  Future<void> _onSearchQuran(
      SearchQuran event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await searchQuranUseCase(SearchParams(query: event.query));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (verses) => emit(SearchResultsLoaded(verses, event.query)),
    );
  }

  Future<void> _onLoadFavoriteSurahs(
      LoadFavoriteSurahs event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await getFavoriteSurahsUseCase(const NoParams());
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (surahs) => emit(FavoriteSurahsLoaded(surahs)),
    );
  }

  Future<void> _onLoadFavoriteVerses(
      LoadFavoriteVerses event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await getFavoriteVersesUseCase(const NoParams());
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (verses) => emit(FavoriteVersesLoaded(verses)),
    );
  }

  Future<void> _onLoadBookmarkedVerses(
      LoadBookmarkedVerses event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await getBookmarkedVersesUseCase(const NoParams());
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (verses) => emit(BookmarkedVersesLoaded(verses)),
    );
  }

  Future<void> _onToggleSurahFavorite(
      ToggleSurahFavorite event, Emitter<QuranState> emit) async {
    final result = await toggleSurahFavoriteUseCase(ToggleFavoriteParams(
      surahNumber: event.surahNumber,
    ));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (success) {
        // Reload surahs to get updated favorite status
        add(LoadAllSurahs());
      },
    );
  }

  Future<void> _onToggleVerseFavorite(
      ToggleVerseFavorite event, Emitter<QuranState> emit) async {
    final result = await toggleVerseFavoriteUseCase(ToggleVerseParams(
      surahNumber: event.surahNumber,
      verseNumber: event.verseNumber,
    ));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (success) {
        // Reload current surah to get updated verse status
        add(LoadSurah(event.surahNumber));
      },
    );
  }

  Future<void> _onToggleVerseBookmark(
      ToggleVerseBookmark event, Emitter<QuranState> emit) async {
    final result = await toggleVerseBookmarkUseCase(ToggleVerseParams(
      surahNumber: event.surahNumber,
      verseNumber: event.verseNumber,
    ));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (success) {
        // Reload current surah to get updated verse status
        add(LoadSurah(event.surahNumber));
      },
    );
  }

  Future<void> _onUpdateLastRead(
      UpdateLastRead event, Emitter<QuranState> emit) async {
    final result = await updateLastReadUseCase(UpdateLastReadParams(
      surahNumber: event.surahNumber,
      verseNumber: event.verseNumber,
    ));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (success) => emit(LastReadUpdated(event.surahNumber, event.verseNumber)),
    );
  }

  Future<void> _onLoadReadingStats(
      LoadReadingStats event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    final result = await getReadingStatsUseCase(const NoParams());
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (stats) => emit(ReadingStatsLoaded(stats)),
    );
  }

  Future<void> _onAddVerseNote(
      AddVerseNote event, Emitter<QuranState> emit) async {
    // This would need to be implemented with a use case
    // For now, emit success
    emit(VerseNoteAdded(event.surahNumber, event.verseNumber, event.note));
  }

  Future<void> _onAddVerseTag(
      AddVerseTag event, Emitter<QuranState> emit) async {
    // This would need to be implemented with a use case
    // For now, emit success
    emit(VerseTagAdded(event.surahNumber, event.verseNumber, event.tag));
  }

  Future<void> _onRemoveVerseTag(
      RemoveVerseTag event, Emitter<QuranState> emit) async {
    // This would need to be implemented with a use case
    // For now, emit success
    emit(VerseTagRemoved(event.surahNumber, event.verseNumber, event.tag));
  }

  Future<void> _onLoadSurahWithTranslation(
      LoadSurahWithTranslation event, Emitter<QuranState> emit) async {
    emit(QuranLoading());

    // This would use a specific translation use case
    // For now, load the regular surah
    final result =
        await getSurahUseCase(GetSurahParams(surahNumber: event.surahNumber));
    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (surah) => emit(SurahLoaded(surah)),
    );
  }
}

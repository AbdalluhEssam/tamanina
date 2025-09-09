import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/quran_local_datasource.dart';
import 'data/repositories/quran_repository_impl.dart';
import 'domain/repositories/quran_repository.dart';
import 'domain/usecases/quran_usecases.dart';
import 'presentation/bloc/quran_bloc.dart';

final sl = GetIt.instance;

Future<void> initQuranDependencies() async {
  // External dependencies: SharedPreferences is provided by the global service
  // locator (`lib/core/services/service_locator.dart`) so don't create or
  // register it again here to avoid duplicate registrations.

  // Data sources
  sl.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(
      localDataSource: sl<QuranLocalDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllSurahsUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetSurahUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetVerseUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(() => SearchQuranUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(
      () => GetFavoriteSurahsUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(
      () => GetFavoriteVersesUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(
      () => GetBookmarkedVersesUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(
      () => ToggleSurahFavoriteUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(
      () => ToggleVerseFavoriteUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(
      () => ToggleVerseBookmarkUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(() => UpdateLastReadUseCase(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetReadingStatsUseCase(sl<QuranRepository>()));

  // BLoC
  sl.registerFactory(
    () => QuranBloc(
      getAllSurahsUseCase: sl<GetAllSurahsUseCase>(),
      getSurahUseCase: sl<GetSurahUseCase>(),
      getVerseUseCase: sl<GetVerseUseCase>(),
      searchQuranUseCase: sl<SearchQuranUseCase>(),
      getFavoriteSurahsUseCase: sl<GetFavoriteSurahsUseCase>(),
      getFavoriteVersesUseCase: sl<GetFavoriteVersesUseCase>(),
      getBookmarkedVersesUseCase: sl<GetBookmarkedVersesUseCase>(),
      toggleSurahFavoriteUseCase: sl<ToggleSurahFavoriteUseCase>(),
      toggleVerseFavoriteUseCase: sl<ToggleVerseFavoriteUseCase>(),
      toggleVerseBookmarkUseCase: sl<ToggleVerseBookmarkUseCase>(),
      updateLastReadUseCase: sl<UpdateLastReadUseCase>(),
      getReadingStatsUseCase: sl<GetReadingStatsUseCase>(),
    ),
  );
}

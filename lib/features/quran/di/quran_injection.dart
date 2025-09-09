import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/quran_local_datasource.dart';
import '../data/repositories/quran_repository_impl.dart';
import '../domain/repositories/quran_repository.dart';
import '../domain/usecases/quran_usecases.dart';
import '../presentation/bloc/quran_bloc.dart';

final sl = GetIt.instance;

Future<void> initQuranDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Data sources
  sl.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllSurahsUseCase(sl()));
  sl.registerLazySingleton(() => GetSurahUseCase(sl()));
  sl.registerLazySingleton(() => GetVerseUseCase(sl()));
  sl.registerLazySingleton(() => SearchQuranUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteSurahsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteVersesUseCase(sl()));
  sl.registerLazySingleton(() => GetBookmarkedVersesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleSurahFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ToggleVerseFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ToggleVerseBookmarkUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLastReadUseCase(sl()));
  sl.registerLazySingleton(() => GetReadingStatsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => QuranBloc(
      getAllSurahsUseCase: sl(),
      getSurahUseCase: sl(),
      getVerseUseCase: sl(),
      searchQuranUseCase: sl(),
      getFavoriteSurahsUseCase: sl(),
      getFavoriteVersesUseCase: sl(),
      getBookmarkedVersesUseCase: sl(),
      toggleSurahFavoriteUseCase: sl(),
      toggleVerseFavoriteUseCase: sl(),
      toggleVerseBookmarkUseCase: sl(),
      updateLastReadUseCase: sl(),
      getReadingStatsUseCase: sl(),
    ),
  );
}

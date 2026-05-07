import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/quran_local_datasource.dart';
import 'data/repo/quran_repository_impl.dart';
import 'data/repo/quran_repository.dart';
import 'ui/cubit/quran_cubit.dart';
import 'ui/cubit/audio_cubit.dart';

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

  // Cubits
  sl.registerFactory(
    () => QuranCubit(repository: sl<QuranRepository>()),
  );

  sl.registerFactory(
    () => AudioCubit(repository: sl<QuranRepository>()),
  );
}

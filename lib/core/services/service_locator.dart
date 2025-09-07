import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features
import '../../features/splash/data/datasources/splash_local_data_source.dart';
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/usecases/splash_usecases.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';

import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // === SPLASH FEATURE ===
  // Data sources
  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CheckOnboardingStatusUseCase(sl()));
  sl.registerLazySingleton(() => CheckFirstRunUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => SplashCubit(
      checkOnboardingStatusUseCase: sl(),
      checkFirstRunUseCase: sl(),
    ),
  );

  // === ONBOARDING FEATURE ===
  // Data sources
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => OnboardingCubit(
      completeOnboardingUseCase: sl(),
    ),
  );
}

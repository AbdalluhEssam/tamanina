import '../datasources/splash_local_data_source.dart';
import 'splash_repository.dart';

/// تنفيذ مخزن البيانات للـ Splash
/// Implementation of splash repository
class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;

  SplashRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isOnboardingCompleted() async {
    return await localDataSource.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await localDataSource.setOnboardingCompleted();
  }

  @override
  Future<bool> isFirstRun() async {
    return await localDataSource.isFirstRun();
  }

  @override
  Future<void> setFirstRunCompleted() async {
    await localDataSource.setFirstRunCompleted();
  }
}

import '../datasources/onboarding_local_data_source.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// تنفيذ مخزن البيانات للتعريف
/// Implementation of onboarding repository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<void> completeOnboarding() async {
    await localDataSource.completeOnboarding();
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return await localDataSource.isOnboardingCompleted();
  }
}

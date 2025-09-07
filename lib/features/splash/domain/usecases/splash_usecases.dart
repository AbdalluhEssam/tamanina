import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../repositories/splash_repository.dart';

/// استخدام حالة للتحقق من إتمام الأونبوردنج
/// Use case to check if onboarding is completed
class CheckOnboardingStatusUseCase implements UseCase<bool, NoParams> {
  final SplashRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final isCompleted = await repository.isOnboardingCompleted();
      return Right(isCompleted);
    } catch (e) {
      return Left(
          CacheFailure('Failed to check onboarding status: ${e.toString()}'));
    }
  }
}

/// استخدام حالة للتحقق من التشغيل الأول
/// Use case to check if this is first run
class CheckFirstRunUseCase implements UseCase<bool, NoParams> {
  final SplashRepository repository;

  CheckFirstRunUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final isFirstRun = await repository.isFirstRun();
      return Right(isFirstRun);
    } catch (e) {
      return Left(
          CacheFailure('Failed to check first run status: ${e.toString()}'));
    }
  }
}

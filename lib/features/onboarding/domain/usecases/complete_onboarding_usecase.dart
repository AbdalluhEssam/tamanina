import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../repositories/onboarding_repository.dart';

/// استخدام حالة لإتمام التعريف
/// Use case to complete onboarding
class CompleteOnboardingUseCase implements UseCase<void, NoParams> {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await repository.completeOnboarding();
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to complete onboarding: ${e.toString()}'));
    }
  }
}

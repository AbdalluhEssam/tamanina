import '../entities/home_feature.dart';
import '../repositories/home_repository.dart';

/// Use case for getting home features
class GetHomeFeaturesUseCase {
  final HomeRepository repository;

  const GetHomeFeaturesUseCase(this.repository);

  List<HomeFeature> call() {
    return repository.getHomeFeatures();
  }
}

/// Use case for getting user greeting
class GetGreetingUseCase {
  final HomeRepository repository;

  const GetGreetingUseCase(this.repository);

  String call() {
    return repository.getGreetingMessage();
  }
}

/// Use case for getting user stats
class GetUserStatsUseCase {
  final HomeRepository repository;

  const GetUserStatsUseCase(this.repository);

  Map<String, int> call() {
    return repository.getUserStats();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/home_feature.dart';
import '../../data/repo/home_usecases.dart';
import 'home_state.dart';

/// Cubit for managing home screen state
class HomeCubit extends Cubit<HomeState> {
  final GetHomeFeaturesUseCase _getHomeFeaturesUseCase;
  final GetGreetingUseCase _getGreetingUseCase;
  final GetUserStatsUseCase _getUserStatsUseCase;

  HomeCubit({
    required GetHomeFeaturesUseCase getHomeFeaturesUseCase,
    required GetGreetingUseCase getGreetingUseCase,
    required GetUserStatsUseCase getUserStatsUseCase,
  })  : _getHomeFeaturesUseCase = getHomeFeaturesUseCase,
        _getGreetingUseCase = getGreetingUseCase,
        _getUserStatsUseCase = getUserStatsUseCase,
        super(HomeInitial());

  /// Load home data
  Future<void> loadHomeData() async {
    try {
      emit(HomeLoading());

      // Simulate loading delay for smooth animation
      await Future.delayed(const Duration(milliseconds: 300));

      final features = _getHomeFeaturesUseCase();
      final greeting = _getGreetingUseCase();
      final stats = _getUserStatsUseCase();

      const preferences = {
        'language': 'ar',
        'theme': 'light',
        'notifications': true,
      };

      emit(HomeLoaded(
        features: features,
        greeting: greeting,
        stats: stats,
        preferences: preferences,
      ));
    } catch (error) {
      emit(HomeError(error.toString()));
    }
  }

  /// Select a home feature
  void selectFeature(HomeFeature feature) {
    emit(HomeFeatureSelected(feature));
  }

  /// Refresh home data
  Future<void> refreshHomeData() async {
    await loadHomeData();
  }

  /// Update greeting based on current time
  void updateGreeting() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newGreeting = _getGreetingUseCase();

      emit(currentState.copyWith(greeting: newGreeting));
    }
  }

  /// Get updated stats
  void refreshStats() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newStats = _getUserStatsUseCase();

      emit(currentState.copyWith(stats: newStats));
    }
  }
}

import 'package:equatable/equatable.dart';
import '../../data/model/home_feature.dart';

/// States for the home screen
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {}

/// Loading state
class HomeLoading extends HomeState {}

/// Loaded state with all home data
class HomeLoaded extends HomeState {
  final List<HomeFeature> features;
  final String greeting;
  final Map<String, int> stats;
  final Map<String, dynamic> preferences;

  const HomeLoaded({
    required this.features,
    required this.greeting,
    required this.stats,
    required this.preferences,
  });

  @override
  List<Object?> get props => [features, greeting, stats, preferences];

  HomeLoaded copyWith({
    List<HomeFeature>? features,
    String? greeting,
    Map<String, int>? stats,
    Map<String, dynamic>? preferences,
  }) {
    return HomeLoaded(
      features: features ?? this.features,
      greeting: greeting ?? this.greeting,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Feature selection state
class HomeFeatureSelected extends HomeState {
  final HomeFeature feature;

  const HomeFeatureSelected(this.feature);

  @override
  List<Object?> get props => [feature];
}

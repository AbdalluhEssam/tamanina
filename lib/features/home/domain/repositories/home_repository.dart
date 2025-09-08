import '../entities/home_feature.dart';

/// Repository interface for home feature operations
abstract class HomeRepository {
  /// Get all available home features
  List<HomeFeature> getHomeFeatures();

  /// Get user preferences
  Map<String, dynamic> getUserPreferences();

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences);

  /// Get greeting message based on current time
  String getGreetingMessage();

  /// Get user's current stats (like daily azkar count, etc.)
  Map<String, int> getUserStats();
}

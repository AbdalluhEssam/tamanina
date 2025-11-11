import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing Home Layout Navigation
class HomeNavigationCubit extends Cubit<int> {
  HomeNavigationCubit() : super(0);

  /// Navigate to tab by index
  void navigateToTab(int index) {
    if (index >= 0 && index <= 3) {
      emit(index);
    }
  }

  /// Get current tab index
  int get currentIndex => state;

  /// Navigate to Home tab
  void navigateToHome() => navigateToTab(0);

  /// Navigate to Tasbeeh tab
  void navigateToTasbeeh() => navigateToTab(1);

  /// Navigate to Quran tab
  void navigateToQuran() => navigateToTab(2);

  /// Navigate to Settings tab
  void navigateToSettings() => navigateToTab(3);
}

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

/// مصدر البيانات المحلي للتعريف
/// Local data source for onboarding
abstract class OnboardingLocalDataSource {
  /// تحديد إتمام التعريف
  Future<void> completeOnboarding();

  /// التحقق من إتمام التعريف
  Future<bool> isOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> completeOnboarding() async {
    final saved = await sharedPreferences.setBool(
      AppConstants.prefKeyOnboardingCompleted,
      true,
    );
    if (!saved) throw StateError('Could not save onboarding progress');
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return sharedPreferences.getBool(AppConstants.prefKeyOnboardingCompleted) ??
        false;
  }
}

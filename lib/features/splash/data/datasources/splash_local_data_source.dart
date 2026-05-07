import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

/// مصدر البيانات المحلي للـ Splash
/// Local data source for splash functionality
abstract class SplashLocalDataSource {
  /// تحقق من إتمام الأونبوردنج من قبل
  Future<bool> isOnboardingCompleted();

  /// تحديث حالة إتمام الأونبوردنج
  Future<void> setOnboardingCompleted();

  /// تحقق من التشغيل الأول للتطبيق
  Future<bool> isFirstRun();

  /// تحديث حالة التشغيل الأول
  Future<void> setFirstRunCompleted();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final SharedPreferences sharedPreferences;

  SplashLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isOnboardingCompleted() async {
    return sharedPreferences.getBool(AppConstants.prefKeyOnboardingCompleted) ??
        false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await sharedPreferences.setBool(
        AppConstants.prefKeyOnboardingCompleted, true);
  }

  @override
  Future<bool> isFirstRun() async {
    return !(sharedPreferences.getBool(AppConstants.prefKeyFirstRun) ?? false);
  }

  @override
  Future<void> setFirstRunCompleted() async {
    await sharedPreferences.setBool(AppConstants.prefKeyFirstRun, true);
  }
}

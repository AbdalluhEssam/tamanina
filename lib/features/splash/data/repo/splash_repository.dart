abstract class SplashRepository {
  /// تحقق من إتمام الأونبوردنج من قبل
  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted();

  /// تحديث حالة إتمام الأونبوردنج
  /// Update onboarding completion status
  Future<void> setOnboardingCompleted();

  /// تحقق من التشغيل الأول للتطبيق
  /// Check if this is first app run
  Future<bool> isFirstRun();

  /// تحديث حالة التشغيل الأول
  /// Update first run status
  Future<void> setFirstRunCompleted();
}

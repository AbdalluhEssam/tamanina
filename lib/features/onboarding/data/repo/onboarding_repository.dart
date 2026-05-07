abstract class OnboardingRepository {
  /// تحديد إتمام التعريف
  /// Mark onboarding as completed
  Future<void> completeOnboarding();

  /// التحقق من إتمام التعريف
  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted();
}

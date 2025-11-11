import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repo/splash_usecases.dart';
import 'splash_state.dart';

/// Cubit لإدارة حالة الـ Splash Screen
/// Cubit for managing splash screen state
class SplashCubit extends Cubit<SplashState> {
  final CheckOnboardingStatusUseCase checkOnboardingStatusUseCase;
  final CheckFirstRunUseCase checkFirstRunUseCase;

  SplashCubit({
    required this.checkOnboardingStatusUseCase,
    required this.checkFirstRunUseCase,
  }) : super(const SplashInitial());

  /// بدء عملية الـ Splash
  /// Start splash process
  Future<void> startSplash() async {
    emit(const SplashLoading());

    try {
      // انتظار مدة عرض الـ splash (3 ثواني)
      // Wait for splash display duration (3 seconds)
      await Future.delayed(
          const Duration(milliseconds: AppConstants.splashDurationMs));

      // التحقق من حالة الأونبوردنج
      // Check onboarding status
      final onboardingResult =
          await checkOnboardingStatusUseCase(const NoParams());

      onboardingResult.fold(
        (failure) => emit(SplashError(message: failure.message)),
        (isOnboardingCompleted) {
          if (isOnboardingCompleted) {
            // الأونبوردنج مكتمل، انتقل للصفحة الرئيسية
            // Onboarding completed, navigate to home
            emit(const SplashNavigateToHome());
          } else {
            // الأونبوردنج غير مكتمل، انتقل للأونبوردنج
            // Onboarding not completed, navigate to onboarding
            emit(const SplashNavigateToOnboarding());
          }
        },
      );
    } catch (e) {
      emit(SplashError(message: 'حدث خطأ أثناء بدء التطبيق: $e'));
    }
  }

  /// فحص التشغيل الأول (للاستخدام المستقبلي)
  /// Check first run (for future use)
  Future<void> checkFirstRun() async {
    final result = await checkFirstRunUseCase(const NoParams());

    result.fold(
      (failure) => emit(SplashError(message: failure.message)),
      (isFirstRun) {
        // يمكن استخدام هذه المعلومة لعرض رسائل ترحيبية خاصة
        // This information can be used to show special welcome messages
        if (isFirstRun) {
          // التشغيل الأول للتطبيق
          // First time running the app
        }
      },
    );
  }
}

import 'package:equatable/equatable.dart';

/// حالات الـ Splash Screen
/// Splash screen states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// حالة التحميل الأولي
/// Initial loading state
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// حالة التحميل
/// Loading state while checking app status
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// حالة الانتقال للأونبوردنج
/// Navigate to onboarding state
class SplashNavigateToOnboarding extends SplashState {
  const SplashNavigateToOnboarding();
}

/// حالة الانتقال للصفحة الرئيسية
/// Navigate to home state
class SplashNavigateToHome extends SplashState {
  const SplashNavigateToHome();
}

/// حالة خطأ
/// Error state
class SplashError extends SplashState {
  final String message;

  const SplashError({required this.message});

  @override
  List<Object?> get props => [message];
}

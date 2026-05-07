import 'package:equatable/equatable.dart';

/// حالات شاشة التعريف (Onboarding)
/// Onboarding screen states
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// حالة تغيير الصفحة
/// Page changed state
class OnboardingPageChanged extends OnboardingState {
  final int currentPageIndex;
  final bool isLastPage;

  const OnboardingPageChanged({
    required this.currentPageIndex,
    required this.isLastPage,
  });

  @override
  List<Object?> get props => [currentPageIndex, isLastPage];
}

/// حالة إتمام التعريف والانتقال للتطبيق
/// Onboarding completed, navigate to app
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// حالة تخطي التعريف
/// Onboarding skipped
class OnboardingSkipped extends OnboardingState {
  const OnboardingSkipped();
}

/// حالة خطأ
/// Error state
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}

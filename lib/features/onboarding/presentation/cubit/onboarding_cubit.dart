import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../../domain/entities/onboarding_page.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

/// Cubit لإدارة حالة شاشات التعريف
/// Cubit for managing onboarding screens state
class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingCubit({
    required this.completeOnboardingUseCase,
  }) : super(const OnboardingInitial());

  final int totalPages = 4;
  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;
  bool get isLastPage => _currentPageIndex == totalPages - 1;

  /// صفحات التعريف المُعدة مسبقاً
  /// Pre-configured onboarding pages
  List<OnboardingPageModel> get onboardingPages => [
        const OnboardingPageModel(
          titleAr: 'أهلاً بك في طمأنينة',
          titleEn: 'Welcome to Tamanina',
          descriptionAr:
              'رفيقك الروحي في رحلة الإيمان والسكينة الداخلية. اجعل كل يوم فرصة للتقرب من الله والسلام النفسي.',
          descriptionEn:
              'Your spiritual companion in the journey of faith and inner peace. Make every day an opportunity to get closer to God and mental peace.',
          imagePath: 'assets/images/onboarding_1.png',
          lottieAnimation: 'assets/lottie/welcome.json',
          iconEmoji: '✨',
        ),
        const OnboardingPageModel(
          titleAr: 'تسبيح وذكر',
          titleEn: 'Tasbih & Dhikr',
          descriptionAr:
              'عداد التسبيح الذكي لمساعدتك في الذكر والتسبيح اليومي. احتفظ بورادك اليومي واجعل كل تسبيحة خطوة نحو النور.',
          descriptionEn:
              'Smart tasbih counter to help you with daily dhikr and glorification. Keep your daily wird and make every tasbih a step towards light.',
          imagePath: 'assets/images/onboarding_2.png',
          lottieAnimation: 'assets/lottie/tasbih.json',
          iconEmoji: '📿',
        ),
        const OnboardingPageModel(
          titleAr: 'أذكار الصباح والمساء',
          titleEn: 'Morning & Evening Azkar',
          descriptionAr:
              'أذكار الصباح والمساء المأثورة لتحصين يومك. ابدأ وأنهي يومك بالذكر والدعاء الذي يجلب البركة والسكينة.',
          descriptionEn:
              'Traditional morning and evening remembrances to fortify your day. Start and end your day with dhikr and prayer that brings blessings and tranquility.',
          imagePath: 'assets/images/onboarding_3.png',
          lottieAnimation: 'assets/lottie/mosque.json',
          iconEmoji: '🕌',
        ),
        const OnboardingPageModel(
          titleAr: 'وردك اليومي من القرآن',
          titleEn: 'Daily Quran Recitation',
          descriptionAr:
              'اقرأ جزء من القرآن الكريم يومياً واجعل كلام الله جزءاً من روتينك اليومي. نور قلبك بآيات الذكر الحكيم.',
          descriptionEn:
              'Read a portion of the Holy Quran daily and make God\'s word part of your daily routine. Illuminate your heart with verses of wise remembrance.',
          imagePath: 'assets/images/onboarding_4.png',
          lottieAnimation: 'assets/lottie/quran.json',
          iconEmoji: '📖',
        ),
      ];

  /// تغيير صفحة التعريف
  /// Change onboarding page
  void onPageChanged(int pageIndex) {
    _currentPageIndex = pageIndex;
    emit(OnboardingPageChanged(
      currentPageIndex: pageIndex,
      isLastPage: isLastPage,
    ));
  }

  /// الانتقال للصفحة التالية
  /// Go to next page
  void nextPage() {
    if (!isLastPage) {
      _currentPageIndex++;
      emit(OnboardingPageChanged(
        currentPageIndex: _currentPageIndex,
        isLastPage: isLastPage,
      ));
    }
  }

  /// الانتقال للصفحة السابقة
  /// Go to previous page
  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      emit(OnboardingPageChanged(
        currentPageIndex: _currentPageIndex,
        isLastPage: isLastPage,
      ));
    }
  }

  /// تخطي التعريف والانتقال للتطبيق
  /// Skip onboarding and go to app
  Future<void> skipOnboarding() async {
    try {
      final result = await completeOnboardingUseCase(const NoParams());
      result.fold(
        (failure) => emit(OnboardingError(message: failure.message)),
        (_) => emit(const OnboardingSkipped()),
      );
    } catch (e) {
      emit(OnboardingError(message: 'حدث خطأ أثناء تخطي التعريف: $e'));
    }
  }

  /// إتمام التعريف والانتقال للتطبيق
  /// Complete onboarding and go to app
  Future<void> completeOnboarding() async {
    try {
      final result = await completeOnboardingUseCase(const NoParams());
      result.fold(
        (failure) => emit(OnboardingError(message: failure.message)),
        (_) => emit(const OnboardingCompleted()),
      );
    } catch (e) {
      emit(OnboardingError(message: 'حدث خطأ أثناء إتمام التعريف: $e'));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../../data/model/onboarding_page.dart';
import '../../data/repo/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

/// Cubit لإدارة حالة شاشات التعريف
/// Cubit for managing onboarding screens state
class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingCubit({required this.completeOnboardingUseCase})
    : super(const OnboardingInitial());

  static const _pages = [
    OnboardingPageModel(
      titleAr: 'كل يوم يبدأ بطمأنينة',
      titleEn: 'Every day begins with peace',
      descriptionAr:
          'كل ما تحتاجه ليومك من مواقيت الصلاة والأذكار في مكان واحد.',
      descriptionEn:
          'Prayer times and daily remembrance, together in one place.',
      imagePath: 'assets/images/journey_sunrise.webp',
    ),
    OnboardingPageModel(
      titleAr: 'صلاتك في وقتها، أينما كنت',
      titleEn: 'Pray on time, wherever you are',
      descriptionAr: 'مواقيت صلاة دقيقة وتنبيهات تذكّرك بصلاتك أينما كنت.',
      descriptionEn: 'Accurate prayer times and reminders wherever you are.',
      imagePath: 'assets/images/journey_mosque.webp',
    ),
    OnboardingPageModel(
      titleAr: 'رفيق عاداتك وذكرك اليومي',
      titleEn: 'Your companion for daily dhikr',
      descriptionAr:
          'سبحة إلكترونية تحفظ تسبيحك، وأذكار الصباح والمساء لتطمئن يومك ويطيب قلبك.',
      descriptionEn:
          'Keep your place in tasbeeh and make time for morning and evening adhkar.',
      imagePath: 'assets/images/journey_tasbeeh.webp',
    ),
    OnboardingPageModel(
      titleAr: 'مساحتك الخاصة للسكينة',
      titleEn: 'Your space for stillness',
      descriptionAr:
          'كل ما يقرّب قلبك إلى الله، في تجربة واحدة تجمع الذكر والقرآن والطمأنينة.',
      descriptionEn:
          'Draw closer to Allah with dhikr, the Quran, and quiet moments of reflection.',
      imagePath: 'assets/images/journey_quran.webp',
    ),
  ];

  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;
  int get totalPages => _pages.length;
  bool get isLastPage => _currentPageIndex == totalPages - 1;
  List<OnboardingPageModel> get onboardingPages => _pages;

  /// تغيير صفحة التعريف
  /// Change onboarding page
  void onPageChanged(int pageIndex) {
    _currentPageIndex = pageIndex;
    emit(
      OnboardingPageChanged(
        currentPageIndex: pageIndex,
        isLastPage: isLastPage,
      ),
    );
  }

  /// الانتقال للصفحة التالية
  /// Go to next page
  void nextPage() {
    if (!isLastPage) {
      _currentPageIndex++;
      emit(
        OnboardingPageChanged(
          currentPageIndex: _currentPageIndex,
          isLastPage: isLastPage,
        ),
      );
    }
  }

  /// الانتقال للصفحة السابقة
  /// Go to previous page
  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      emit(
        OnboardingPageChanged(
          currentPageIndex: _currentPageIndex,
          isLastPage: isLastPage,
        ),
      );
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

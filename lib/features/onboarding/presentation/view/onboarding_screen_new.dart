import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service.dart';
import '../../domain/entities/onboarding_page.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// شاشة التعريف بالتطبيق (Onboarding Screen)
/// Onboarding Screen for Tamanina App with Islamic design
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted || state is OnboardingSkipped) {
            NavigationService.pushReplacementNamed(AppRoutes.home);
          } else if (state is OnboardingError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildBackgroundGradient(),
          child: SafeArea(
            child: Column(
              children: [
                // شريط التحكم العلوي
                _buildTopBar(),

                // محتوى الصفحات
                Expanded(
                  flex: 8,
                  child: _buildPageView(),
                ),

                // مؤشرات الصفحات
                _buildPageIndicators(),

                SizedBox(height: 20.h),

                // أزرار التحكم
                _buildBottomControls(),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء خلفية متدرجة
  /// Build gradient background
  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.backgroundLight,
          AppColors.creamAccent,
          AppColors.lightBeige,
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  /// بناء شريط التحكم العلوي
  /// Build top control bar
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // شعار التطبيق الصغير
          FadeIn(
            duration: const Duration(milliseconds: 800),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.mosque,
                    color: AppColors.backgroundLight,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.amiri(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // زر التخطي
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final cubit = context.read<OnboardingCubit>();
              if (cubit.isLastPage) {
                return const SizedBox.shrink();
              }

              return FadeIn(
                duration: const Duration(milliseconds: 800),
                child: TextButton(
                  onPressed: () => cubit.skipOnboarding(),
                  child: Text(
                    context.locale.languageCode == 'ar' ? 'تخطي' : 'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// بناء عرض الصفحات
  /// Build page view
  Widget _buildPageView() {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            cubit.onPageChanged(index);
            _restartAnimations();
          },
          itemCount: cubit.onboardingPages.length,
          itemBuilder: (context, index) {
            return _buildOnboardingPage(cubit.onboardingPages[index]);
          },
        );
      },
    );
  }

  /// بناء صفحة تعريف واحدة
  /// Build single onboarding page
  Widget _buildOnboardingPage(OnboardingPageModel page) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // الرسوم المتحركة أو الصورة
          _buildPageIllustration(page),

          const Spacer(flex: 1),

          // العنوان
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              isArabic ? page.titleAr : page.titleEn,
              style: GoogleFonts.amiri(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 20.h),

          // الوصف
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 500),
            child: Text(
              isArabic ? page.descriptionAr : page.descriptionEn,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  /// بناء الرسوم التوضيحية للصفحة
  /// Build page illustrations
  Widget _buildPageIllustration(OnboardingPageModel page) {
    return FadeInDown(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: 250.w,
        height: 250.w,
        decoration: BoxDecoration(
          gradient: AppColors.calmGradient,
          borderRadius: BorderRadius.circular(125.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الخلفية الدائرية
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),

            // الرمز التعبيري
            Text(
              page.iconEmoji,
              style: TextStyle(fontSize: 80.sp),
            ),

            // تأثير التوهج
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء مؤشرات الصفحات
  /// Build page indicators
  Widget _buildPageIndicators() {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return FadeIn(
          duration: const Duration(milliseconds: 800),
          child: SmoothPageIndicator(
            controller: _pageController,
            count: cubit.totalPages,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primaryGreen,
              dotColor: AppColors.textSecondary.withOpacity(0.3),
              dotHeight: 8.h,
              dotWidth: 8.w,
              expansionFactor: 4,
              spacing: 8.w,
            ),
          ),
        );
      },
    );
  }

  /// بناء أزرار التحكم السفلية
  /// Build bottom control buttons
  Widget _buildBottomControls() {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Row(
            children: [
              // زر الرجوع (إن وجد)
              if (cubit.currentPageIndex > 0) ...[
                _buildBackButton(),
                SizedBox(width: 16.w),
              ],

              // زر التالي / ابدأ
              Expanded(
                child: cubit.isLastPage
                    ? _buildGetStartedButton()
                    : _buildNextButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// زر الرجوع
  /// Back button
  Widget _buildBackButton() {
    return BounceInLeft(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            final cubit = context.read<OnboardingCubit>();
            cubit.previousPage();
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryGreen,
            size: 20.r,
          ),
        ),
      ),
    );
  }

  /// زر التالي
  /// Next button
  Widget _buildNextButton() {
    return BounceInRight(
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final cubit = context.read<OnboardingCubit>();
            cubit.nextPage();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.locale.languageCode == 'ar' ? 'التالي' : 'Next',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.backgroundLight,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.backgroundLight,
                size: 18.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// زر البدء
  /// Get started button
  Widget _buildGetStartedButton() {
    return BounceInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldAccent.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => context.read<OnboardingCubit>().completeOnboarding(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.locale.languageCode == 'ar' ? 'ابدأ' : 'Get Started',
                style: GoogleFonts.amiri(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.textPrimary,
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// إعادة تشغيل الرسوم المتحركة
  /// Restart animations
  void _restartAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  /// عرض رسالة خطأ
  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

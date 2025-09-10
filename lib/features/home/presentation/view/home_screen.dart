import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tamanina/core/extensions/navigation_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/welcome_card.dart';
import '../widgets/home_feature_card.dart';

/// Home Screen - Main features overview
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return _buildLoadingState();
        } else if (state is HomeLoaded) {
          return _buildLoadedState(state, context);
        } else if (state is HomeError) {
          return _buildErrorState(state.message, context);
        }
        return _buildInitialState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            strokeWidth: 3,
          ),
          AppSpacing.verticalSpaceLG,
          Text(
            'جاري التحميل...',
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(HomeLoaded state, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeCubit>().refreshHomeData();
      },
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: AppSizing.appBarHeight,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          bottom: 60.h, // Space for FAB and BottomNav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            WelcomeCard(
              greeting: state.greeting,
              stats: state.stats,
            ),

            AppSpacing.verticalSpaceXL,

            // Features Section Title
            _buildSectionTitle('الخصائص الرئيسية', 'Main Features'),

            AppSpacing.verticalSpaceLG,

            // Features Grid
            _buildFeaturesGrid(state.features, context),

            AppSpacing.verticalSpaceXL,

            // Quick Access Section
            _buildQuickAccessSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'حدث خطأ',
              style: AppTypography.h5Arabic.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadHomeData(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(String arabicTitle, String englishTitle) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.goldAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        AppSpacing.horizontalSpaceMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arabicTitle,
                style: AppTypography.h6Arabic.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                englishTitle,
                style: AppTypography.captionEnglish.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(List features, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final colors = _getFeatureColors(feature.color);

        return HomeFeatureCard(
          titleArabic: feature.titleArabic,
          titleEnglish: feature.titleEnglish,
          iconPath: feature.iconPath,
          color: colors,
          isActive: feature.isActive,
          onTap: () => _navigateToFeature(feature, context),
        );
      },
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.goldAccent,
                size: AppSizing.iconMD,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                'وصول سريع',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAccessButton(
                'التسبيح',
                Icons.radio_button_checked,
                AppColors.primaryGreen,
                () => context.pushNamed(AppRoutes.sebha),
              ),
              _buildQuickAccessButton(
                'القبلة',
                Icons.navigation_rounded,
                AppColors.primaryBlue,
                () => Navigator.pushNamed(context, '/qibla'),
              ),
              _buildQuickAccessButton(
                'الأذكار',
                Icons.auto_stories_rounded,
                AppColors.goldAccent,
                () => Navigator.pushNamed(context, '/azkar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.md,
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizing.iconMD,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            title,
            style: AppTypography.captionArabic.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFeatureColors(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return AppColors.primaryGreen;
      case 'blue':
        return AppColors.primaryBlue;
      case 'gold':
        return AppColors.goldAccent;
      case 'orange':
        return AppColors.warning;
      case 'purple':
        return AppColors.ishaColor;
      case 'teal':
        return AppColors.info;
      default:
        return AppColors.primaryGreen;
    }
  }

  void _navigateToFeature(dynamic feature, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم فتح ${feature.titleArabic} قريباً إن شاء الله'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
        ),
      ),
    );
  }
}

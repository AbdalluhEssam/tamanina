import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';

/// Quran Tab Screen Content
class QuranTabScreen extends StatelessWidget {
  const QuranTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSizing.appBarHeight + 40.h,
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom: 100.h, // Space for BottomNav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),

          AppSpacing.verticalSpaceXL,

          // Last Read Section
          _buildLastReadSection(),

          AppSpacing.verticalSpaceLG,

          // Popular Surahs
          _buildPopularSurahs(),

          AppSpacing.verticalSpaceLG,

          // Quick Access Buttons
          _buildQuickAccessButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.goldAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.2),
              borderRadius: AppRadius.md,
            ),
            child: Icon(
              Icons.book_rounded,
              color: AppColors.primaryGreen,
              size: AppSizing.iconLG,
            ),
          ),
          AppSpacing.horizontalSpaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'القرآن الكريم',
                  style: AppTypography.h5Arabic.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  'اقرأ واستمع إلى كتاب الله',
                  style: AppTypography.bodyMediumArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastReadSection() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bookmark_rounded,
                color: AppColors.primaryGreen,
                size: AppSizing.iconMD,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                'آخر قراءة',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.goldAccent.withOpacity(0.2),
              child: Text(
                '2',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'سورة البقرة',
              style: AppTypography.bodyLargeArabic.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'الآية 142 من 286',
              style: AppTypography.captionArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryGreen,
              size: 16.w,
            ),
            onTap: () {
              // Navigate to specific surah
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSurahs() {
    final List<Map<String, dynamic>> surahs = [
      {
        'number': 1,
        'name': 'الفاتحة',
        'englishName': 'Al-Fatiha',
        'verses': 7,
        'type': 'مكية',
      },
      {
        'number': 18,
        'name': 'الكهف',
        'englishName': 'Al-Kahf',
        'verses': 110,
        'type': 'مكية',
      },
      {
        'number': 36,
        'name': 'يس',
        'englishName': 'Ya-Sin',
        'verses': 83,
        'type': 'مكية',
      },
      {
        'number': 67,
        'name': 'الملك',
        'englishName': 'Al-Mulk',
        'verses': 30,
        'type': 'مكية',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السور المشهورة',
          style: AppTypography.h6Arabic.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        ...surahs.map((surah) => _buildSurahItem(surah)).toList(),
      ],
    );
  }

  Widget _buildSurahItem(Map<String, dynamic> surah) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: AppRadius.sm,
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              '${surah['number']}',
              style: AppTypography.labelMediumArabic.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          surah['name'],
          style: AppTypography.bodyLargeArabic.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${surah['verses']} آية • ${surah['type']}',
          style: AppTypography.captionArabic.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.goldAccent.withOpacity(0.1),
            borderRadius: AppRadius.sm,
          ),
          child: Text(
            'اقرأ',
            style: AppTypography.captionArabic.copyWith(
              color: AppColors.goldAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          // Navigate to specific surah
        },
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            'فهرس السور',
            Icons.list_alt_rounded,
            AppColors.primaryGreen,
            () {},
          ),
        ),
        AppSpacing.horizontalSpaceMD,
        Expanded(
          child: _buildQuickButton(
            'البحث',
            Icons.search_rounded,
            AppColors.goldAccent,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.md,
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: AppSizing.iconMD,
            ),
            AppSpacing.horizontalSpaceSM,
            Text(
              title,
              style: AppTypography.labelMediumArabic.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

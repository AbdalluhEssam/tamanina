import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// أزرار الوصول السريع
/// Quick Action Buttons Widget
class QuickActionButtons extends StatelessWidget {
  final bool isDark;

  const QuickActionButtons({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: AppColors.goldAccent,
                size: 22.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'وصول سريع',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // First row of buttons
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.menu_book_rounded,
                  label: 'القرآن',
                  color: AppColors.primaryGreen,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/quran'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.auto_stories_rounded,
                  label: 'الأذكار',
                  color: AppColors.goldAccent,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/azkar'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.explore_rounded,
                  label: 'القبلة',
                  color: AppColors.primaryBlue,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/qibla'),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Second row of buttons
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.access_time_rounded,
                  label: 'المواقيت',
                  color: AppColors.fajrColor,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/prayer-times'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.radio_button_checked_rounded,
                  label: 'التسبيح',
                  color: AppColors.asrColor,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/sebha'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.settings_rounded,
                  label: 'الإعدادات',
                  color: AppColors.textSecondary,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// زر الوصول السريع
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.w,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTypography.captionArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

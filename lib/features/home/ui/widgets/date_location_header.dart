import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// رأس التاريخ والموقع
/// Date and Location Header Widget
class DateLocationHeader extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;
  final String cityName;
  final String countryName;
  final bool isDark;

  const DateLocationHeader({
    super.key,
    required this.hijriDate,
    required this.gregorianDate,
    required this.cityName,
    required this.countryName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldAccent.withValues(alpha: 0.15),
            AppColors.primaryGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Islamic decorative element
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeElement(),
              SizedBox(width: 12.w),
              Icon(
                Icons.mosque_rounded,
                color: AppColors.goldAccent,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              _buildDecorativeElement(),
            ],
          ),

          SizedBox(height: 16.h),

          // Hijri date
          Text(
            hijriDate,
            style: AppTypography.h5Arabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Gregorian date
          Text(
            gregorianDate,
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // Location
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryGreen,
                  size: 18.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  cityName,
                  style: AppTypography.labelLargeArabic.copyWith(
                    color: isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (countryName.isNotEmpty) ...[
                  Text(
                    '، ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    countryName,
                    style: AppTypography.captionArabic.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElement() {
    return Container(
      width: 50.w,
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.goldAccent,
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }
}

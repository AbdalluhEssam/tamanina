import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/prayer_service.dart';

/// بطاقة وقت الصلاة
/// Prayer Time Card Widget
class PrayerTimeCard extends StatelessWidget {
  final PrayerTimeData prayer;
  final bool isDark;

  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = prayer.isNext;
    final isPassed = prayer.timeSince != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryGreen.withValues(alpha: 0.15)
            : isPassed
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.withValues(alpha: 0.05))
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isNext
            ? Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Prayer icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: _getPrayerColor().withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(),
              color: _getPrayerColor(),
              size: 22.w,
            ),
          ),

          SizedBox(width: 12.w),

          // Prayer name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayer.nameArabic,
                      style: AppTypography.labelLargeArabic.copyWith(
                        color: isDark
                            ? AppColors.textOnSurfaceDark
                            : AppColors.textPrimary,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (isNext) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (prayer.timeUntil != null || prayer.timeSince != null)
                  Text(
                    _getTimeStatus(),
                    style: AppTypography.captionArabic.copyWith(
                      color: isNext
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
              ],
            ),
          ),

          // Prayer time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prayer.formattedTime,
                style: AppTypography.h6Arabic.copyWith(
                  color: isNext
                      ? AppColors.primaryGreen
                      : isPassed
                          ? AppColors.textSecondary
                          : (isDark
                              ? AppColors.textOnSurfaceDark
                              : AppColors.textPrimary),
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              Text(
                prayer.formattedTime24,
                style: AppTypography.captionArabic.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPrayerColor() {
    switch (prayer.name.toLowerCase()) {
      case 'fajr':
        return AppColors.fajrColor;
      case 'sunrise':
        return AppColors.dhuhrColor;
      case 'dhuhr':
        return AppColors.dhuhrColor;
      case 'asr':
        return AppColors.asrColor;
      case 'maghrib':
        return AppColors.maghribColor;
      case 'isha':
        return AppColors.ishaColor;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getPrayerIcon() {
    switch (prayer.name.toLowerCase()) {
      case 'fajr':
        return Icons.nights_stay_rounded;
      case 'sunrise':
        return Icons.wb_sunny_rounded;
      case 'dhuhr':
        return Icons.light_mode_rounded;
      case 'asr':
        return Icons.wb_twilight_rounded;
      case 'maghrib':
        return Icons.nightlight_rounded;
      case 'isha':
        return Icons.dark_mode_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  String _getTimeStatus() {
    if (prayer.timeUntil != null) {
      return 'باقي ${_formatDuration(prayer.timeUntil!)}';
    } else if (prayer.timeSince != null) {
      return 'منذ ${_formatDuration(prayer.timeSince!)}';
    }
    return '';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours س $minutes د';
    } else {
      return '$minutes دقيقة';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// بطاقة عرض وقت الصلاة
/// Prayer Time Card Widget
class PrayerCard extends StatelessWidget {
  final String prayerNameAr;
  final String prayerTime;
  final String emoji;
  final bool isNext;
  final Color? color;

  const PrayerCard({
    super.key,
    required this.prayerNameAr,
    required this.prayerTime,
    required this.emoji,
    this.isNext = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: isNext
            ? LinearGradient(
                colors: [
                  color ?? AppColors.primaryGreen,
                  (color ?? AppColors.primaryGreen).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isNext
            ? null
            : isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: isNext
                ? (color ?? AppColors.primaryGreen).withValues(alpha: 0.3)
                : AppColors.shadow,
            blurRadius: isNext ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isNext
              ? Colors.transparent
              : isDark
                  ? AppColors.dividerDark
                  : AppColors.divider,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: () {
            // Could add more interaction later
          },
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                // Prayer Emoji Icon
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.white.withValues(alpha: 0.2)
                        : (color ?? AppColors.primaryGreen).withValues(alpha: 0.1),
                    borderRadius: AppRadius.md,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                // Prayer Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayerNameAr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isNext
                              ? Colors.white
                              : isDark
                                  ? AppColors.textOnSurfaceDark
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      if (isNext) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'الصلاة القادمة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Prayer Time
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.white.withValues(alpha: 0.2)
                        : isDark
                            ? AppColors.backgroundDark
                            : AppColors.creamAccent.withValues(alpha: 0.5),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    prayerTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isNext
                          ? Colors.white
                          : color ?? AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

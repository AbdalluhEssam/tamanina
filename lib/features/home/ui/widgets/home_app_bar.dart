import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Custom app bar with transparent design and Islamic styling
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;

  const HomeAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onNotificationPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppSizing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Row(
            children: [
              // Menu button
              _buildIconButton(
                icon: Icons.menu_rounded,
                onPressed: onMenuPressed,
              ),

              const Spacer(),

              // App title with Arabic and English
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'طمأنينة',
                    style: AppTypography.h6Arabic.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    'Tamanina',
                    style: AppTypography.labelMediumEnglish.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10.sp,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Notification button
              _buildIconButton(
                icon: Icons.notifications_rounded,
                onPressed: onNotificationPressed,
                showBadge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
    bool showBadge = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: AppRadius.md,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.divider,
              width: 0.5,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: AppColors.textPrimary,
              size: AppSizing.iconSM,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),

        // Notification badge
        if (showBadge)
          Positioned(
            right: 6.w,
            top: 6.w,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Welcome card widget with Islamic gradient background
class WelcomeCard extends StatefulWidget {
  final String greeting;
  final Map<String, int> stats;

  const WelcomeCard({
    super.key,
    required this.greeting,
    required this.stats,
  });

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.gentle,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.gentle,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.islamicGradient,
                borderRadius: AppRadius.xl,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: AppSpacing.paddingXL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with greeting and bismillah
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting
                              Text(
                                'السلام عليكم',
                                style: AppTypography.h4Arabic.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              AppSpacing.verticalSpaceSM,

                              Text(
                                widget.greeting,
                                style: AppTypography.bodyLargeArabic.copyWith(
                                  color:
                                      AppColors.textOnPrimary.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Islamic decoration
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                            borderRadius: AppRadius.circular,
                            border: Border.all(
                              color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.mosque_rounded,
                            color: AppColors.textOnPrimary,
                            size: AppSizing.iconLG,
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.verticalSpaceLG,

                    // App name and tagline
                    Text(
                      'طمأنينة – Tamanina',
                      style: AppTypography.h5Arabic.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.verticalSpaceXS,

                    Text(
                      'رفيقك في رحلة الإيمان',
                      style: AppTypography.bodyMediumArabic.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),

                    AppSpacing.verticalSpaceMD,

                    // Quick stats row
                    _buildStatsRow(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('أذكار اليوم', '${widget.stats['todayAzkar'] ?? 0}'),
        const Spacer(),
        _buildStatItem('التسبيح', '${widget.stats['todaySebha'] ?? 0}'),
        const Spacer(),
        _buildStatItem('القرآن', '${widget.stats['todayQuran'] ?? 0} صفحات'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h6Arabic.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          label,
          style: AppTypography.captionArabic.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}

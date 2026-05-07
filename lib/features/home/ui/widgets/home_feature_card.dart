import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Individual feature card widget with Islamic design
/// Theme-aware: responds to dark/light mode changes
class HomeFeatureCard extends StatefulWidget {
  final String titleArabic;
  final String titleEnglish;
  final String iconPath;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const HomeFeatureCard({
    super.key,
    required this.titleArabic,
    required this.titleEnglish,
    required this.iconPath,
    required this.color,
    required this.onTap,
    this.isActive = true,
  });

  @override
  State<HomeFeatureCard> createState() => _HomeFeatureCardState();
}

class _HomeFeatureCardState extends State<HomeFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.gentle,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.isActive ? widget.onTap : null,
            child: Container(
              decoration: BoxDecoration(
                // Professional Card Design with Soft Background - Theme aware
                color: isDark
                    ? colorScheme.surface
                    : const Color(0xFFFAFAFA), // #FAFAFA for light mode
                borderRadius:
                    BorderRadius.circular(24.r), // 2xl rounded corners
                boxShadow: [
                  // Elegant Shadow
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: widget.color.withOpacity(isDark ? 0.15 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? widget.color.withOpacity(0.15)
                      : widget.color.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Container with Gradient
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withOpacity(0.15),
                            widget.color.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: widget.color.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _getIconFromPath(widget.iconPath),
                          color: widget.color,
                          size: 24.w,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Arabic title with Cairo font
                    Flexible(
                      child: Text(
                        widget.titleArabic,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface, // Theme aware text
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          height: 1.2,
                          fontFamily: 'Cairo', // Islamic font
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // English subtitle
                    Flexible(
                      child: Text(
                        widget.titleEnglish,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface
                              .withOpacity(0.6), // Theme aware secondary text
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get icon from path for fallback
  IconData _getIconFromPath(String path) {
    if (path.contains('sebha')) return Icons.radio_button_checked_rounded;
    if (path.contains('azkar')) return Icons.auto_stories_rounded;
    if (path.contains('quran')) return Icons.book_rounded;
    if (path.contains('prayer')) return Icons.schedule_rounded;
    if (path.contains('audio')) return Icons.headphones_rounded;
    if (path.contains('statistics')) return Icons.bar_chart_rounded;
    return Icons.apps_rounded;
  }
}

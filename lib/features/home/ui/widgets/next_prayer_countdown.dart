import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/prayer_service.dart';

/// بطاقة العد التنازلي للصلاة التالية
/// Next Prayer Countdown Widget
class NextPrayerCountdown extends StatefulWidget {
  final PrayerTimeData? nextPrayer;
  final PrayerTimeData? currentPrayer;
  final bool isDark;

  const NextPrayerCountdown({
    super.key,
    required this.nextPrayer,
    required this.currentPrayer,
    required this.isDark,
  });

  @override
  State<NextPrayerCountdown> createState() => _NextPrayerCountdownState();
}

class _NextPrayerCountdownState extends State<NextPrayerCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _updateTimeRemaining();
    _startTimer();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateTimeRemaining() {
    if (widget.nextPrayer != null) {
      final now = DateTime.now();
      if (widget.nextPrayer!.time.isAfter(now)) {
        _timeRemaining = widget.nextPrayer!.time.difference(now);
      } else {
        _timeRemaining = Duration.zero;
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateTimeRemaining();
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(NextPrayerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTimeRemaining();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nextPrayer == null) {
      return const SizedBox.shrink();
    }

    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Current prayer info
                  if (widget.currentPrayer != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 16.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'الوقت الحالي: ${widget.currentPrayer!.nameArabic}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 12.h),

                  // Next prayer name
                  Text(
                    'الصلاة القادمة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 28.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        widget.nextPrayer!.nameArabic,
                        style: AppTypography.h3Arabic.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Prayer time
                  Text(
                    widget.nextPrayer!.formattedTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Countdown timer
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeUnit(
                              hours.toString().padLeft(2, '0'), 'ساعة'),
                          _buildSeparator(),
                          _buildTimeUnit(
                              minutes.toString().padLeft(2, '0'), 'دقيقة'),
                          _buildSeparator(),
                          _buildTimeUnit(
                              seconds.toString().padLeft(2, '0'), 'ثانية'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Time difference info
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'باقي ${_formatTimeRemaining()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTimeRemaining() {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (minutes > 0) {
      return '$minutes دقيقة';
    } else {
      return 'أقل من دقيقة';
    }
  }
}

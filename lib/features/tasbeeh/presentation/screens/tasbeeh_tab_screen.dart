import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';

/// Tasbeeh Tab Screen Content
class TasbeehTabScreen extends StatefulWidget {
  const TasbeehTabScreen({super.key});

  @override
  State<TasbeehTabScreen> createState() => _TasbeehTabScreenState();
}

class _TasbeehTabScreenState extends State<TasbeehTabScreen>
    with TickerProviderStateMixin {
  int _currentCount = 0;
  int _currentTasbeehIndex = 0;
  int _completedCycles = 0;
  bool _isVibrationEnabled = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _tasbeehList = [
    {
      'text': 'سُبْحَانَ اللهِ',
      'english': 'Subhan Allah',
      'meaning': 'Glory be to Allah',
      'count': 33,
      'color': AppColors.primaryGreen,
      'gradient': [AppColors.primaryGreen, Color(0xFF2E7D32)],
    },
    {
      'text': 'الْحَمْدُ للهِ',
      'english': 'Alhamdulillah',
      'meaning': 'Praise be to Allah',
      'count': 33,
      'color': AppColors.goldAccent,
      'gradient': [AppColors.goldAccent, Color(0xFFFF8F00)],
    },
    {
      'text': 'اللهُ أَكْبَر',
      'english': 'Allahu Akbar',
      'meaning': 'Allah is Greatest',
      'count': 34,
      'color': AppColors.primaryBlue,
      'gradient': [AppColors.primaryBlue, Color(0xFF1565C0)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentTasbeeh =>
      _tasbeehList[_currentTasbeehIndex];
  int get _targetCount => _currentTasbeeh['count'] as int;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSizing.appBarHeight,
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom: 60.h, // Space for BottomNav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          _buildHeader(),

          AppSpacing.verticalSpaceXL,

          // Counter Display
          _buildCounterDisplay(),

          AppSpacing.verticalSpaceXL,

          // Count Button
          _buildCountButton(),

          AppSpacing.verticalSpaceLG,

          // Progress Bar
          _buildProgressBar(),

          AppSpacing.verticalSpaceXL,

          // Tasbeeh List
          _buildTasbeehList(),

          AppSpacing.verticalSpaceLG,

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentTasbeeh['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: (_currentTasbeeh['color'] as Color).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: (_currentTasbeeh['color'] as Color).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: AppSizing.iconLG,
                ),
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'التسبيح الذكي',
              style: AppTypography.h5Arabic.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              _currentTasbeeh['meaning'] as String,
              style: AppTypography.bodyMediumEnglish.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.sm,
              ),
              child: Text(
                'المرحلة ${_currentTasbeehIndex + 1} من 3 • الدورة ${_completedCycles + 1}',
                style: AppTypography.captionArabic.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterDisplay() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 220.w,
        height: 220.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              (_currentTasbeeh['color'] as Color).withOpacity(0.1),
              (_currentTasbeeh['color'] as Color).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: (_currentTasbeeh['color'] as Color).withOpacity(0.4),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: (_currentTasbeeh['color'] as Color).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentTasbeeh['text'] as String,
              textAlign: TextAlign.center,
              style: AppTypography.h5Arabic.copyWith(
                color: _currentTasbeeh['color'] as Color,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '$_currentCount',
              style: AppTypography.h2Arabic.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 56.sp,
              ),
            ),
            Text(
              'من $_targetCount',
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              _currentTasbeeh['english'] as String,
              style: AppTypography.captionEnglish.copyWith(
                color: (_currentTasbeeh['color'] as Color).withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: _incrementCounter,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _currentTasbeeh['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_currentTasbeeh['color'] as Color).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: (_currentTasbeeh['color'] as Color).withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 32.w,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'سبّح',
                      style: AppTypography.labelMediumArabic.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
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

  Widget _buildProgressBar() {
    final progress = _currentCount / _targetCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: _currentTasbeeh['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          Container(
            height: 12.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: AppRadius.sm,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.sm,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _currentTasbeeh['color'] as Color,
                ),
                minHeight: 12.h,
              ),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isActive = index == _currentTasbeehIndex;
              final isCompleted = index < _currentTasbeehIndex;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 24.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : isActive
                          ? _currentTasbeeh['color'] as Color
                          : AppColors.surfaceLight,
                  borderRadius: AppRadius.sm,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTasbeehList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مراحل التسبيح',
            style: AppTypography.h6Arabic.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceMD,
          ..._tasbeehList.asMap().entries.map((entry) {
            final index = entry.key;
            final tasbeeh = entry.value;
            return _buildTasbeehItem(tasbeeh, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTasbeehItem(Map<String, dynamic> tasbeeh, int index) {
    final isActive = _currentTasbeehIndex == index;
    final isCompleted = index < _currentTasbeehIndex;
    final isNext = index == _currentTasbeehIndex + 1;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: isActive
              ? (tasbeeh['color'] as Color).withOpacity(0.15)
              : isCompleted
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : Colors.white,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isActive
                ? tasbeeh['color'] as Color
                : isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (tasbeeh['color'] as Color).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: isActive
                    ? tasbeeh['color'] as Color
                    : isCompleted
                        ? AppColors.primaryGreen
                        : (tasbeeh['color'] as Color).withOpacity(0.2),
                borderRadius: AppRadius.sm,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: AppSizing.iconMD,
                      )
                    : Text(
                        '${tasbeeh['count']}',
                        style: AppTypography.labelMediumArabic.copyWith(
                          color: isActive
                              ? Colors.white
                              : tasbeeh['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasbeeh['text'] as String,
                    style: AppTypography.bodyLargeArabic.copyWith(
                      color: isActive
                          ? tasbeeh['color'] as Color
                          : AppColors.textPrimary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(
                    tasbeeh['english'] as String,
                    style: AppTypography.captionEnglish.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (isActive && _currentCount > 0)
                    Text(
                      'تم $_currentCount من ${tasbeeh['count']}',
                      style: AppTypography.captionArabic.copyWith(
                        color: tasbeeh['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                if (isCompleted)
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.primaryGreen,
                    size: AppSizing.iconMD,
                  )
                else if (isActive)
                  Icon(
                    Icons.play_circle_filled_rounded,
                    color: tasbeeh['color'] as Color,
                    size: AppSizing.iconMD,
                  )
                else if (isNext)
                  Icon(
                    Icons.schedule_rounded,
                    color: AppColors.textSecondary,
                    size: AppSizing.iconMD,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة تعيين'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                foregroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md,
                  side: BorderSide(
                    color: AppColors.error.withOpacity(0.3),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ),
          AppSpacing.horizontalSpaceMD,
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _toggleVibration,
              icon: Icon(_isVibrationEnabled
                  ? Icons.vibration_rounded
                  : Icons.vibration),
              label: Text(_isVibrationEnabled ? 'اهتزاز مفعل' : 'اهتزاز متوقف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVibrationEnabled
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColors.textSecondary.withOpacity(0.1),
                foregroundColor: _isVibrationEnabled
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md,
                  side: BorderSide(
                    color: (_isVibrationEnabled
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary)
                        .withOpacity(0.3),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _currentCount++;
      if (_currentCount >= _targetCount) {
        _moveToNextTasbeeh();
      }
    });

    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    if (_isVibrationEnabled) {
      _vibrate();
    }
  }

  void _moveToNextTasbeeh() {
    if (_currentTasbeehIndex < _tasbeehList.length - 1) {
      // Move to next tasbeeh
      setState(() {
        _currentTasbeehIndex++;
        _currentCount = 0;
      });

      // Restart fade animation for smooth transition
      _fadeController.reset();
      _fadeController.forward();

      _showTransitionMessage();
    } else {
      // Complete full cycle
      setState(() {
        _completedCycles++;
        _currentTasbeehIndex = 0;
        _currentCount = 0;
      });

      _fadeController.reset();
      _fadeController.forward();

      _showCompletionDialog();
    }
  }

  void _showTransitionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.arrow_forward_rounded, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'انتقال إلى ${_currentTasbeeh['text']}',
                style: AppTypography.bodyMediumArabic.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _currentTasbeeh['color'] as Color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
        ),
      ),
    );
  }

  void _resetCounter() {
    setState(() {
      _currentCount = 0;
      _currentTasbeehIndex = 0;
      _completedCycles = 0;
    });

    _fadeController.reset();
    _fadeController.forward();
  }

  void _toggleVibration() {
    setState(() {
      _isVibrationEnabled = !_isVibrationEnabled;
    });
  }

  void _vibrate() {
    HapticFeedback.lightImpact();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        child: Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            borderRadius: AppRadius.lg,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen.withOpacity(0.1),
                AppColors.goldAccent.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.goldAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 40.w,
                ),
              ),
              AppSpacing.verticalSpaceLG,
              Text(
                'مبارك! 🎉',
                style: AppTypography.h5Arabic.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalSpaceMD,
              Text(
                'لقد أكملت دورة كاملة من التسبيح\n${_completedCycles} دورة مكتملة',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMediumArabic.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              AppSpacing.verticalSpaceMD,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'إجمالي التسبيحات:',
                      style: AppTypography.labelMediumArabic.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${33 + 33 + 34} تسبيحة',
                      style: AppTypography.h6Arabic.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpaceLG,
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('إنهاء'),
                    ),
                  ),
                  AppSpacing.horizontalSpaceMD,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Don't reset here - the cycle continues
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.md,
                        ),
                        elevation: 2,
                      ),
                      child: const Text('متابعة التسبيح'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

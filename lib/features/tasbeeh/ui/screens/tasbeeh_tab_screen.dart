import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import 'dart:math' as math;

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

  // Draggable button position
  Offset? _buttonPosition;

  // Animation controller for smooth movement
  late AnimationController _moveController;
  late Animation<Offset> _moveAnimation;

  // Get safe initial button position
  Offset _getSafeButtonPosition(BuildContext context) {
    if (_buttonPosition != null) return _buttonPosition!;

    final screenSize = MediaQuery.of(context).size;
    final buttonSize = 80.w; // Button size

    return Offset(
      screenSize.width - buttonSize - 20.w, // margin from right
      screenSize.height / 2 - buttonSize / 2, // center vertically
    );
  }

  // Get safe position within screen bounds
  Offset _getSafePosition(Offset position, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final buttonSize = 80.w;
    final margin = 10.w; // Margin from edges

    final safeX = position.dx.clamp(
      margin,
      screenSize.width - buttonSize - margin,
    );

    final safeY = position.dy.clamp(
      safeArea.top + margin, // Below status bar with margin
      screenSize.height -
          buttonSize -
          safeArea.bottom -
          100.h -
          margin, // Above bottom nav with margin
    );

    return Offset(safeX, safeY);
  }

  // Snap to edge if close enough (optional feature)
  Offset _getSnapPosition(Offset position, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = 80.w;
    final snapDistance = 50.w; // Distance to trigger snap

    final safePosition = _getSafePosition(position, context);

    // Check if close to left or right edge
    if (safePosition.dx < snapDistance) {
      return Offset(10.w, safePosition.dy); // Snap to left
    } else if (safePosition.dx > screenSize.width - buttonSize - snapDistance) {
      return Offset(screenSize.width - buttonSize - 10.w,
          safePosition.dy); // Snap to right
    }

    return safePosition; // No snapping needed
  }

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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Smooth movement animation controller
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentTasbeeh =>
      _tasbeehList[_currentTasbeehIndex];
  int get _targetCount => _currentTasbeeh['count'] as int;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Compact Header
                _buildCompactHeader(),

                SizedBox(height: 24.h),

                // Main Tasbeeh Circle with Prayer Beads (without button)
                _buildTasbeehWithBeads(),

                SizedBox(height: 20.h),

                // Progress Info
                _buildProgressInfo(),

                SizedBox(height: 24.h),

                // Action Buttons
                _buildActionButtons(),

                // Extra space for draggable button
                SizedBox(height: 100.h),
              ],
            ),
          ),

          // Draggable Counter Button
          _buildDraggableCountButton(context),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentTasbeeh['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: (_currentTasbeeh['color'] as Color).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.brightness_7,
                  size: 20.w,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التسبيح الذكي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'المرحلة ${_currentTasbeehIndex + 1} • الدورة ${_completedCycles + 1}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbeehWithBeads() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: 300.w,
        height: 300.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Prayer Beads Circle
            CustomPaint(
              size: Size(300.w, 300.w),
              painter: BeadsPainter(
                totalBeads: _targetCount,
                activeBeads: _currentCount,
                activeColor: _currentTasbeeh['color'] as Color,
                inactiveColor: Colors.grey.shade300,
              ),
            ),

            // Main Counter Circle (without clickable button)
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: (_currentTasbeeh['color'] as Color).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentTasbeeh['text'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _currentTasbeeh['color'] as Color,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '$_currentCount',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'من $_targetCount',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Draggable Counter Button
  Widget _buildDraggableCountButton(BuildContext context) {
    final currentPosition = _buttonPosition ?? _getSafeButtonPosition(context);

    return AnimatedBuilder(
      animation: _moveAnimation,
      builder: (context, child) {
        final animatedPosition = _moveController.isAnimating
            ? Offset(
                _moveAnimation.value.dx,
                _moveAnimation.value.dy,
              )
            : currentPosition;

        return Positioned(
          left: animatedPosition.dx,
          top: animatedPosition.dy,
          child: Draggable(
            feedback: Material(
              color: Colors.transparent,
              child: _buildCountButton(isDragging: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildCountButton(),
            ),
            onDragUpdate: (details) {
              // Provide haptic feedback during drag
              HapticFeedback.selectionClick();
            },
            onDragEnd: (details) {
              final newPosition = _getSnapPosition(details.offset, context);

              // Animate to safe position with smooth easing
              _moveAnimation = Tween<Offset>(
                begin: currentPosition,
                end: newPosition,
              ).animate(CurvedAnimation(
                parent: _moveController,
                curve: Curves.easeOutBack,
              ));

              setState(() {
                _buttonPosition = newPosition;
              });

              _moveController.reset();
              _moveController.forward();

              // Provide success haptic feedback
              HapticFeedback.mediumImpact();
            },
            child: _buildCountButton(),
          ),
        );
      },
    );
  }

  /// Count Button Widget
  Widget _buildCountButton({bool isDragging = false}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Transform.scale(
            scale: _pulseAnimation.value * (isDragging ? 1.1 : 1.0),
            child: GestureDetector(
              onTap: isDragging ? null : _incrementCounter,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _currentTasbeeh['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_currentTasbeeh['color'] as Color)
                          .withOpacity(isDragging ? 0.6 : 0.4),
                      blurRadius: isDragging ? 25 : 15,
                      offset: Offset(0, isDragging ? 12 : 6),
                      spreadRadius: isDragging ? 4 : 0,
                    ),
                    // Inner glow for dragging state
                    if (isDragging)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                        spreadRadius: -2,
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDragging ? Icons.open_with : Icons.touch_app,
                      color: Colors.white,
                      size: 24.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isDragging ? 'اسحب' : 'اضغط',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
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

  Widget _buildProgressInfo() {
    final progress = _currentCount / _targetCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (_currentTasbeeh['color'] as Color).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentTasbeeh['meaning'] as String,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: _currentTasbeeh['color'] as Color,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _currentTasbeeh['color'] as Color,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = index == _currentTasbeehIndex;
                final isCompleted = index < _currentTasbeehIndex;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 16.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primaryGreen
                        : isActive
                            ? _currentTasbeeh['color'] as Color
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                );
              }),
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
              icon: Icon(Icons.refresh_rounded, size: 18.w),
              label: Text('إعادة تعيين'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                foregroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _toggleVibration,
              icon: Icon(
                _isVibrationEnabled
                    ? Icons.vibration_rounded
                    : Icons.phone_android,
                size: 18.w,
              ),
              label: Text(_isVibrationEnabled ? 'اهتزاز مفعل' : 'اهتزاز متوقف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVibrationEnabled
                    ? (_currentTasbeeh['color'] as Color).withOpacity(0.1)
                    : AppColors.textSecondary.withOpacity(0.1),
                foregroundColor: _isVibrationEnabled
                    ? _currentTasbeeh['color'] as Color
                    : AppColors.textSecondary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
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
      HapticFeedback.lightImpact();
    }
  }

  void _moveToNextTasbeeh() {
    if (_currentTasbeehIndex < _tasbeehList.length - 1) {
      setState(() {
        _currentTasbeehIndex++;
        _currentCount = 0;
      });
      _fadeController.reset();
      _fadeController.forward();
      _showTransitionMessage();
    } else {
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
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _currentTasbeeh['color'] as Color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
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
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 40.w,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'مبارك! 🎉',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'لقد أكملت دورة كاملة من التسبيح\n$_completedCycles دورة مكتملة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'أجر عظيم إن شاء الله',
                  style: TextStyle(
                    color: AppColors.goldAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('إنهاء'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetCounter();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text('جولة أخرى'),
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

/// Custom Painter for Drawing Prayer Beads Around the Circle
class BeadsPainter extends CustomPainter {
  final int totalBeads;
  final int activeBeads;
  final Color activeColor;
  final Color inactiveColor;

  BeadsPainter({
    required this.totalBeads,
    required this.activeBeads,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 30;

    // Calculate angle between each bead
    final angleStep = (2 * math.pi) / totalBeads;

    for (int i = 0; i < totalBeads; i++) {
      final angle = i * angleStep - (math.pi / 2); // Start from top
      final beadX = center.dx + radius * math.cos(angle);
      final beadY = center.dy + radius * math.sin(angle);
      final beadCenter = Offset(beadX, beadY);

      final isActive = i < activeBeads;
      final beadColor = isActive ? activeColor : inactiveColor;
      final beadSize = isActive ? 8.0 : 6.0;

      // Draw bead shadow
      if (isActive) {
        final shadowPaint = Paint()
          ..color = beadColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(beadX + 1, beadY + 1),
          beadSize,
          shadowPaint,
        );
      }

      // Draw the main bead
      final paint = Paint()
        ..color = beadColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(beadCenter, beadSize, paint);

      // Draw inner highlight for active beads
      if (isActive) {
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(beadCenter, beadSize * 0.4, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

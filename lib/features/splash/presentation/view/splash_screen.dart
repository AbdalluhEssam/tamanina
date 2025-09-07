import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

/// Tamanina Islamic App Splash Screen - طمأنينة 🕌
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _breatheController;
  late final AnimationController _particlesController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSlide;
  late final Animation<double> _breathe;
  late final Animation<double> _particles;

  late final DateTime _startTime;
  static const Duration _minTime = Duration(milliseconds: 3200);

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _setupAnimations();
    _startSequence();
    context.read<SplashCubit>().startSplash();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: Curves.easeInOutCubic
      ),
    );

    _textSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: Curves.easeOutBack
      ),
    );

    _breathe = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(
          parent: _breatheController,
          curve: Curves.easeInOutSine
      ),
    );

    _particles = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _particlesController,
          curve: Curves.linear
      ),
    );
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.lightImpact();

    // اللوجو الأول
    _logoController.forward();

    // بعدها النص
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();
  }

  Future<void> _handleNavigation(SplashState state) async {
    final elapsed = DateTime.now().difference(_startTime);
    final remaining = _minTime - elapsed;

    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    if (state is SplashNavigateToOnboarding) {
      NavigationService.pushReplacementNamed(AppRoutes.onboarding);
    } else if (state is SplashNavigateToHome) {
      NavigationService.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _breatheController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding ||
              state is SplashNavigateToHome) {
            _handleNavigation(state);
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: _buildIslamicBackground(isDark),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // زخارف إسلامية خفيفة في الخلفية
              _buildIslamicPatterns(isDark),

              // جسيمات متحركة
              _buildFloatingParticles(isDark),

              // المحتوى الرئيسي
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // الشعار الكبير
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_logoController, _breatheController]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value * _breathe.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: _buildLargeLogo(isDark),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 40.h),

                    // اسم التطبيق بالعربي
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: _buildAppNameArabic(isDark),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    // اسم التطبيق بالإنجليزي
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlide.value * 0.7),
                          child: Opacity(
                            opacity: _textOpacity.value * 0.9,
                            child: _buildAppNameEnglish(isDark),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 3),

                    // آية قرآنية أو حديث
                    _buildQuranVerse(isDark),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildIslamicBackground(bool isDark) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.8,
        colors: isDark
            ? [
          const Color(0xFF0F2D1F), // أخضر داكن جداً
          const Color(0xFF1B4332),
          const Color(0xFF2D5A44),
          AppColors.primaryGreenDark,
        ]
            : [
          const Color(0xFFE8F5E9), // أخضر فاتح جداً
          const Color(0xFFF1F8E9),
          const Color(0xFFF9FBE7),
          const Color(0xFFFFFFFF),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ),
    );
  }

  Widget _buildIslamicPatterns(bool isDark) {
    return CustomPaint(
      painter: IslamicGeometryPainter(
        isDark: isDark,
        animation: _breathe.value,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildFloatingParticles(bool isDark) {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return CustomPaint(
          painter: FloatingParticlesPainter(
            isDark: isDark,
            animation: _particles.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLargeLogo(bool isDark) {
    return Container(
      width: 280.w,
      height: 280.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? [
            AppColors.goldAccent.withOpacity(0.4),
            AppColors.goldAccent.withOpacity(0.2),
            Colors.transparent,
          ]
              : [
            AppColors.primaryGreen.withOpacity(0.3),
            AppColors.primaryGreen.withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
          radius: 0.75,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: AppColors.goldAccent.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            )
          else
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: 200.w,
          height: 200.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.goldLight : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.goldAccent.withOpacity(0.5)
                    : AppColors.primaryGreen.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.goldAccent : AppColors.primaryGreen,
              width: 3,
            ),
          ),
          padding: EdgeInsets.all(30.w),
          child: Image.asset(
            AppAssets.logo,
            color: isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildAppNameArabic(bool isDark) {
    return Text(
      'طمأنينة',
      style: GoogleFonts.tajawal(
        fontSize: 52.sp,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.goldAccent : AppColors.primaryGreen,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildAppNameEnglish(bool isDark) {
    return Text(
      'TAMANINA',
      style: GoogleFonts.poppins(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.goldAccent.withOpacity(0.9)
            : AppColors.primaryGreen.withOpacity(0.8),
        letterSpacing: 8.0,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranVerse(bool isDark) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value * 0.8,
          child: Text(
            "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            style: GoogleFonts.amiri(
              fontSize: 18.sp,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? AppColors.goldLight.withOpacity(0.7)
                  : AppColors.primaryGreenDark.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

// رسام الزخارف الإسلامية الهندسية
class IslamicGeometryPainter extends CustomPainter {
  final bool isDark;
  final double animation;

  IslamicGeometryPainter({required this.isDark, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.8;

    // رسم أنماط إسلامية هندسية
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = isDark
          ? AppColors.goldAccent.withOpacity(0.15 * animation)
          : AppColors.primaryGreen.withOpacity(0.1 * animation);

    // رسم دوائر متحدة المركز
    for (int i = 1; i <= 5; i++) {
      final radius = maxRadius * 0.2 * i;
      canvas.drawCircle(center, radius, paint);
    }

    // رسم نجمة إسلامية
    final starPath = Path();
    final points = 8; // نجمة ثمانية
    final innerRadius = maxRadius * 0.3;
    final outerRadius = maxRadius * 0.5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final angle = math.pi * i / points;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// رسام الجسيمات العائمة
class FloatingParticlesPainter extends CustomPainter {
  final bool isDark;
  final double animation;

  FloatingParticlesPainter({required this.isDark, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark
          ? AppColors.goldAccent.withOpacity(0.2)
          : AppColors.primaryGreen.withOpacity(0.15);

    final random = math.Random(42);
    final particleCount = 15;

    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 2 + random.nextDouble() * 3;
      final offset = Offset(x, y);

      // جعل الجسيمات تتحرك قليلاً
      final movingY = y + math.sin(animation * 2 * math.pi + i) * 10;
      final movingOffset = Offset(x, movingY);

      canvas.drawCircle(movingOffset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
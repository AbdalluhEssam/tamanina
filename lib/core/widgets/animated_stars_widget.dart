import 'dart:math';
import 'package:flutter/material.dart';

/// Widget للنجوم المتحركة في الخلفية
/// Animated particles/stars widget for background
class AnimatedStarsWidget extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double opacity;
  final double minSize;
  final double maxSize;
  final Duration animationDuration;

  const AnimatedStarsWidget({
    super.key,
    this.particleCount = 25,
    this.color = Colors.white,
    this.opacity = 0.6,
    this.minSize = 2.0,
    this.maxSize = 6.0,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<AnimatedStarsWidget> createState() => _AnimatedStarsWidgetState();
}

class _AnimatedStarsWidgetState extends State<AnimatedStarsWidget>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _twinkleController;
  late List<StarParticle> particles;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _twinkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    particles = [];
    _moveController.repeat();
    _twinkleController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeParticles();
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;
    particles = List.generate(widget.particleCount, (index) {
      return StarParticle(
        x: Random().nextDouble() * size.width,
        y: Random().nextDouble() * size.height,
        size: widget.minSize +
            Random().nextDouble() * (widget.maxSize - widget.minSize),
        speed: 0.2 + Random().nextDouble() * 0.8,
        twinkleOffset: Random().nextDouble() * 2 * pi,
        direction: Random().nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (particles.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_moveController, _twinkleController]),
        builder: (context, child) {
          return CustomPaint(
            painter: StarsPainter(
              particles: particles,
              moveProgress: _moveController.value,
              twinkleProgress: _twinkleController.value,
              color: widget.color,
              opacity: widget.opacity,
              canvasSize: MediaQuery.of(context).size,
            ),
          );
        },
      ),
    );
  }
}

/// فئة بيانات النجمة
/// Star particle data class
class StarParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double twinkleOffset;
  final double direction;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.twinkleOffset,
    required this.direction,
  });
}

/// مرسام النجوم
/// Stars painter
class StarsPainter extends CustomPainter {
  final List<StarParticle> particles;
  final double moveProgress;
  final double twinkleProgress;
  final Color color;
  final double opacity;
  final Size canvasSize;

  StarsPainter({
    required this.particles,
    required this.moveProgress,
    required this.twinkleProgress,
    required this.color,
    required this.opacity,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // حساب الموضع الحالي للنجمة
      final currentX = (particle.x +
              cos(particle.direction) * particle.speed * moveProgress * 100) %
          size.width;
      final currentY = (particle.y +
              sin(particle.direction) * particle.speed * moveProgress * 100) %
          size.height;

      // حساب شفافية الوميض
      final twinkleValue =
          sin(twinkleProgress * 2 * pi + particle.twinkleOffset) * 0.5 + 0.5;
      final currentOpacity = opacity * twinkleValue;

      final paint = Paint()
        ..color = color.withValues(alpha: currentOpacity)
        ..style = PaintingStyle.fill;

      // رسم النجمة
      _drawStar(canvas, paint, currentX, currentY, particle.size);
    }
  }

  /// رسم النجمة
  /// Draw star shape
  void _drawStar(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    const int points = 4; // نجمة رباعية بسيطة
    final outerRadius = size;
    final innerRadius = size * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi) / points - pi / 2;
      final pointX = x + radius * cos(angle);
      final pointY = y + radius * sin(angle);

      if (i == 0) {
        path.moveTo(pointX, pointY);
      } else {
        path.lineTo(pointX, pointY);
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    // إضافة توهج خفيف
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is StarsPainter &&
        (oldDelegate.moveProgress != moveProgress ||
            oldDelegate.twinkleProgress != twinkleProgress);
  }
}

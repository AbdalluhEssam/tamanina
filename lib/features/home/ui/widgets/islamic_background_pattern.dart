import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';

/// Islamic Background Pattern Widget
class IslamicBackgroundPattern extends StatelessWidget {
  final Widget child;
  final double opacity;

  const IslamicBackgroundPattern({
    super.key,
    required this.child,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Pattern
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(opacity: opacity),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  final double opacity;

  IslamicPatternPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final goldPaint = Paint()
      ..color = AppColors.goldAccent.withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw Islamic geometric patterns
    _drawIslamicStars(canvas, size, paint);
    _drawCrescentMoons(canvas, size, goldPaint);
    _drawGeometricLines(canvas, size, paint);
  }

  void _drawIslamicStars(Canvas canvas, Size size, Paint paint) {
    const int starsCount = 8;
    const double starSize = 20.0;

    for (int i = 0; i < starsCount; i++) {
      final double x = (size.width / starsCount) * i + starSize;
      final double y = size.height * 0.2 + (i % 2) * 100;

      _drawStar(canvas, Offset(x, y), starSize, paint);
    }

    for (int i = 0; i < starsCount; i++) {
      final double x = (size.width / starsCount) * i + starSize / 2;
      final double y = size.height * 0.7 + (i % 2) * 80;

      _drawStar(canvas, Offset(x, y), starSize * 0.7, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    const int points = 8;
    const double angle = 2 * math.pi / points;

    final Path path = Path();

    for (int i = 0; i < points; i++) {
      final double radius = (i % 2 == 0) ? size : size * 0.5;
      final double x = center.dx + radius * math.cos(i * angle);
      final double y = center.dy + radius * math.sin(i * angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCrescentMoons(Canvas canvas, Size size, Paint paint) {
    const int moonsCount = 6;
    const double moonSize = 15.0;

    for (int i = 0; i < moonsCount; i++) {
      final double x = size.width * 0.8 + (i % 2) * 40;
      final double y = (size.height / moonsCount) * i + moonSize;

      _drawCrescent(canvas, Offset(x, y), moonSize, paint);
    }

    for (int i = 0; i < moonsCount; i++) {
      final double x = size.width * 0.1 - (i % 2) * 30;
      final double y = (size.height / moonsCount) * i + moonSize * 2;

      _drawCrescent(canvas, Offset(x, y), moonSize * 0.8, paint);
    }
  }

  void _drawCrescent(Canvas canvas, Offset center, double size, Paint paint) {
    final Rect outerCircle = Rect.fromCircle(center: center, radius: size);
    final Rect innerCircle = Rect.fromCircle(
      center: Offset(center.dx + size * 0.3, center.dy),
      radius: size * 0.8,
    );

    final Path path = Path()
      ..addOval(outerCircle)
      ..addOval(innerCircle);

    canvas.drawPath(path, paint);
  }

  void _drawGeometricLines(Canvas canvas, Size size, Paint paint) {
    // Subtle geometric connecting lines
    paint.strokeWidth = 0.5;

    // Horizontal decorative lines
    for (int i = 0; i < 5; i++) {
      final double y = size.height * 0.15 * (i + 1);
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.3, y),
        paint,
      );

      canvas.drawLine(
        Offset(size.width * 0.7, y),
        Offset(size.width * 0.9, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

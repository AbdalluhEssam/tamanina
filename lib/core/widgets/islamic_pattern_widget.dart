import 'dart:math';
import 'package:flutter/material.dart';

/// Widget للزخارف الإسلامية الخفيفة في الخلفية
/// Islamic pattern widget for subtle background decoration
class IslamicPatternWidget extends StatefulWidget {
  final double opacity;
  final Color color;
  final double size;
  final bool animate;

  const IslamicPatternWidget({
    super.key,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.size = 60,
    this.animate = false,
  });

  @override
  State<IslamicPatternWidget> createState() => _IslamicPatternWidgetState();
}

class _IslamicPatternWidgetState extends State<IslamicPatternWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_animationController);

    if (widget.animate) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: IslamicPatternPainter(
              opacity: widget.opacity,
              color: widget.color,
              size: widget.size,
              rotation: widget.animate ? _rotationAnimation.value : 0,
            ),
          );
        },
      ),
    );
  }
}

/// مرسام الزخارف الإسلامية
/// Islamic pattern painter
class IslamicPatternPainter extends CustomPainter {
  final double opacity;
  final Color color;
  final double size;
  final double rotation;

  IslamicPatternPainter({
    required this.opacity,
    required this.color,
    required this.size,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // حساب عدد الأنماط بناءً على حجم الشاشة
    final horizontalCount = (canvasSize.width / size).ceil() + 1;
    final verticalCount = (canvasSize.height / size).ceil() + 1;

    // رسم الأنماط في شبكة
    for (int i = -1; i < horizontalCount; i++) {
      for (int j = -1; j < verticalCount; j++) {
        final centerX = i * size + (j % 2) * (size / 2);
        final centerY = j * size;

        canvas.save();
        canvas.translate(centerX, centerY);
        canvas.rotate(rotation);

        // رسم النمط الإسلامي الثماني
        _drawIslamicOctagon(canvas, paint, size / 3);

        canvas.restore();
      }
    }
  }

  /// رسم النمط الإسلامي الثماني (نجمة ثمانية)
  /// Draw Islamic octagonal pattern (eight-pointed star)
  void _drawIslamicOctagon(Canvas canvas, Paint paint, double radius) {
    const int sides = 8;
    final path = Path();

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi) / sides - (pi / 2);
      final x = radius * cos(angle);
      final y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    // رسم النجمة الداخلية
    final innerPath = Path();
    final innerRadius = radius * 0.6;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi) / sides - (pi / 2) + (pi / sides);
      final x = innerRadius * cos(angle);
      final y = innerRadius * sin(angle);

      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }

    innerPath.close();
    canvas.drawPath(innerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is IslamicPatternPainter &&
        (oldDelegate.opacity != opacity ||
            oldDelegate.color != color ||
            oldDelegate.size != size ||
            oldDelegate.rotation != rotation);
  }
}

import 'package:flutter/material.dart';

/// Widget لتأثير التوهج خلف اللوجو
/// Glow effect widget for logo background
class GlowEffectWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double glowOpacity;
  final bool animate;
  final Duration animationDuration;

  const GlowEffectWidget({
    super.key,
    required this.child,
    this.glowColor = Colors.white,
    this.glowRadius = 20.0,
    this.glowOpacity = 0.6,
    this.animate = true,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<GlowEffectWidget> createState() => _GlowEffectWidgetState();
}

class _GlowEffectWidgetState extends State<GlowEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animate) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // طبقات التوهج المتعددة
              _buildGlowLayer(
                radius: widget.glowRadius * _pulseAnimation.value * 1.5,
                opacity: widget.glowOpacity * _opacityAnimation.value * 0.3,
              ),
              _buildGlowLayer(
                radius: widget.glowRadius * _pulseAnimation.value,
                opacity: widget.glowOpacity * _opacityAnimation.value * 0.6,
              ),
              _buildGlowLayer(
                radius: widget.glowRadius * _pulseAnimation.value * 0.7,
                opacity: widget.glowOpacity * _opacityAnimation.value,
              ),
              // العنصر الأساسي
              widget.child,
            ],
          );
        },
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildGlowLayer(
            radius: widget.glowRadius * 1.5,
            opacity: widget.glowOpacity * 0.3,
          ),
          _buildGlowLayer(
            radius: widget.glowRadius,
            opacity: widget.glowOpacity * 0.6,
          ),
          _buildGlowLayer(
            radius: widget.glowRadius * 0.7,
            opacity: widget.glowOpacity,
          ),
          widget.child,
        ],
      );
    }
  }

  Widget _buildGlowLayer({required double radius, required double opacity}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(opacity),
            blurRadius: radius,
            spreadRadius: radius * 0.3,
          ),
        ],
      ),
    );
  }
}

/// Widget لتأثير التوهج المخصص مع المرسام
/// Custom glow effect widget with painter
class CustomGlowWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double glowOpacity;
  final bool animate;

  const CustomGlowWidget({
    super.key,
    required this.child,
    this.glowColor = Colors.white,
    this.glowRadius = 30.0,
    this.glowOpacity = 0.5,
    this.animate = true,
  });

  @override
  State<CustomGlowWidget> createState() => _CustomGlowWidgetState();
}

class _CustomGlowWidgetState extends State<CustomGlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: GlowPainter(
            glowColor: widget.glowColor,
            glowRadius: widget.glowRadius,
            glowOpacity: widget.glowOpacity * (0.5 + 0.5 * _animation.value),
            animationValue: _animation.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// مرسام التوهج
/// Glow painter
class GlowPainter extends CustomPainter {
  final Color glowColor;
  final double glowRadius;
  final double glowOpacity;
  final double animationValue;

  GlowPainter({
    required this.glowColor,
    required this.glowRadius,
    required this.glowOpacity,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) + glowRadius * (0.8 + 0.4 * animationValue);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(glowOpacity),
          glowColor.withOpacity(glowOpacity * 0.7),
          glowColor.withOpacity(glowOpacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is GlowPainter &&
        oldDelegate.animationValue != animationValue;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Smooth, internal typing animation without triggering parent rebuilds.
/// Handles growing text (streaming) gracefully without reset/flicker.
class TypingAnimationWidget extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;

  /// Duration per character. Default ~65ms/char for calm typing.
  final Duration? typingSpeed;
  final VoidCallback? onComplete;
  final bool autoStart;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final Color? cursorColor;
  final bool showCursor;

  const TypingAnimationWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.typingSpeed,
    this.onComplete,
    this.autoStart = true,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
    this.cursorColor,
    this.showCursor = true,
  });

  @override
  State<TypingAnimationWidget> createState() => _TypingAnimationWidgetState();
}

class _TypingAnimationWidgetState extends State<TypingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  // Internal incremental typing without resetting on new text
  String _targetText = '';
  String _displayedText = '';
  bool _isCompleted = false;
  Duration get _perChar =>
      widget.typingSpeed ?? const Duration(milliseconds: 65);
  DateTime _lastTick = DateTime.now();
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _targetText = widget.text;

    // Cursor blinking
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _cursorAnimation = CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    );

    // Lightweight ticker to append characters at fixed pace
    _ticker = createTicker(_onTick);
    if (widget.autoStart) {
      _ticker?.start();
    }
  }

  void _onTick(Duration _) {
    if (_displayedText.length == _targetText.length) {
      if (!_isCompleted) {
        _isCompleted = true;
        widget.onComplete?.call();
      }
      return; // done, keep cursor blinking only
    }

    // throttle by perChar
    final now = DateTime.now();
    if (now.difference(_lastTick) >= _perChar) {
      _lastTick = now;
      final nextLen = (_displayedText.length + 1).clamp(0, _targetText.length);
      if (mounted) {
        setState(() {
          _displayedText = _targetText.substring(0, nextLen);
        });
      }
    }
  }

  @override
  void didUpdateWidget(TypingAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // Extend target without resetting displayed text to avoid flicker
      _targetText = widget.text;
      _isCompleted = false;
      if (_ticker?.isActive != true && widget.autoStart) {
        _ticker?.start();
      }
    }
  }

  void startTyping() {
    if (_ticker?.isActive != true) _ticker?.start();
  }

  void stopTyping() {
    if (_ticker?.isActive == true) _ticker?.stop();
  }

  void resetTyping() {
    _displayedText = '';
    _isCompleted = false;
    _lastTick = DateTime.now();
    _ticker?.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorAnimation,
      builder: (context, child) {
        return RichText(
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: _displayedText,
                style: widget.textStyle ??
                    AppTypography.bodyMediumArabic.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.8,
                      fontSize: 15.sp,
                    ),
              ),
              if (widget.showCursor && !_isCompleted)
                TextSpan(
                  text: '│',
                  style: TextStyle(
                    color: (widget.cursorColor ?? AppColors.primaryGreen)
                        .withOpacity(_cursorAnimation.value),
                    fontSize: (widget.textStyle?.fontSize ?? 15.sp) * 1.1,
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Simplified typing animation for easy use
class SimpleTypingText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  /// Duration per char
  final Duration? speed;
  final VoidCallback? onComplete;
  final TextDirection textDirection;
  final TextAlign textAlign;

  const SimpleTypingText({
    super.key,
    required this.text,
    this.style,
    this.speed,
    this.onComplete,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return TypingAnimationWidget(
      text: text,
      textStyle: style,
      typingSpeed: speed,
      onComplete: onComplete,
      textDirection: textDirection,
      textAlign: textAlign,
      showCursor: true,
    );
  }
}

/// Loading dots animation for typing indicator
class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const TypingIndicator({
    super.key,
    this.color,
    this.size = 8.0,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      )..repeat(
          reverse: true, period: Duration(milliseconds: 700 + index * 140)),
    );

    _animations = _animationControllers
        .map((controller) =>
            CurvedAnimation(parent: controller, curve: Curves.easeInOut))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: 0.3 + (_animations[index].value * 0.7),
                child: Transform.scale(
                  scale: 0.75 + (_animations[index].value * 0.25),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color ?? AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

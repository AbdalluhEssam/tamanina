import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget for chat input with Islamic-inspired design
class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;

  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Text input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : AppColors.creamAccent.withOpacity(0.5),
                    borderRadius: AppRadius.xl,
                    border: Border.all(
                      color: AppColors.divider,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.isEnabled,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: AppTypography.bodyMediumArabic,
                    decoration: InputDecoration(
                      hintText: 'اكتب سؤالك هنا...',
                      hintStyle: AppTypography.bodyMediumArabic.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                    onChanged: (text) {
                      setState(() {
                        // Rebuild to update send button state
                      });
                    },
                  ),
                ),
              ),

              AppSpacing.horizontalSpaceSM,

              // Send button
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      onTapDown: (_) => _scaleController.forward(),
                      onTapUp: (_) => _scaleController.reverse(),
                      onTapCancel: () => _scaleController.reverse(),
                      onTap: _canSend() ? _handleSendPressed : null,
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          gradient: _canSend()
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen,
                                    AppColors.primaryGreen.withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _canSend()
                              ? null
                              : AppColors.divider.withOpacity(0.5),
                          shape: BoxShape.circle,
                          boxShadow: _canSend()
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: _canSend()
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: AppSizing.iconMD,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if message can be sent
  bool _canSend() {
    return widget.isEnabled && _controller.text.trim().isNotEmpty;
  }

  /// Handle send button pressed
  void _handleSendPressed() {
    if (_canSend()) {
      final text = _controller.text.trim();
      _controller.clear();
      widget.onSendMessage(text);
    }
  }

  /// Handle text submitted
  void _handleSubmitted(String text) {
    _handleSendPressed();
  }
}

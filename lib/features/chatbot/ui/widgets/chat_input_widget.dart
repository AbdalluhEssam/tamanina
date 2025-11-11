import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
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
      duration: const Duration(milliseconds: 90),
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
        gradient: LinearGradient(
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.97),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? const [Color(0xFF2C2C2C), Color(0xFF3A3A3A)]
                          : const [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: widget.isEnabled
                          ? AppColors.primaryGreen.withOpacity(0.25)
                          : AppColors.divider.withOpacity(0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.isEnabled,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: AppTypography.bodyMediumArabic.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 16.sp,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.isEnabled
                          ? 'اكتب سؤالك الإسلامي هنا...'
                          : 'يرجى الانتظار...',
                      hintStyle: AppTypography.bodyMediumArabic.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 12.h,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Send button
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final canSend = _canSend();
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      onTapDown: (_) => _scaleController.forward(),
                      onTapUp: (_) {
                        _scaleController.reverse();
                        _handleSendPressed();
                      },
                      onTapCancel: () => _scaleController.reverse(),
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          gradient: canSend
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF66BB6A)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    AppColors.divider,
                                    AppColors.divider.withOpacity(0.85),
                                  ],
                                ),
                          shape: BoxShape.circle,
                          boxShadow: canSend
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color:
                              canSend ? Colors.white : AppColors.textSecondary,
                          size: 20.w,
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
      setState(() {});
    }
  }

  /// Handle text submitted
  void _handleSubmitted(String text) {
    _handleSendPressed();
  }
}

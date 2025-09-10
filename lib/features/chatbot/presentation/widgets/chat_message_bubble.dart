import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_message.dart';

/// Widget for displaying individual chat messages
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;
  final bool isStreaming;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) _buildAssistantAvatar(),
          if (!message.isUser) AppSpacing.horizontalSpaceXS,
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress ?? () => _showMessageOptions(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: _buildBubbleDecoration(context),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.isLoading) _buildLoadingIndicator(),
                    if (!message.isLoading) _buildMessageContent(context),
                    if (!message.isLoading) _buildMessageTimestamp(context),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) AppSpacing.horizontalSpaceXS,
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  /// Build bubble decoration based on message type and sender
  BoxDecoration _buildBubbleDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      // User message bubble
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.lg.topLeft,
          topRight: AppRadius.lg.topRight,
          bottomLeft: AppRadius.lg.bottomLeft,
          bottomRight: Radius.circular(4.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      // Assistant message bubble
      Color bubbleColor;
      Color shadowColor;

      switch (message.type) {
        case MessageType.quran:
          bubbleColor = isDarkMode
              ? AppColors.primaryGreen.withOpacity(0.2)
              : AppColors.primaryGreen.withOpacity(0.1);
          shadowColor = AppColors.primaryGreen.withOpacity(0.2);
          break;
        case MessageType.hadith:
          bubbleColor = isDarkMode
              ? AppColors.goldAccent.withOpacity(0.2)
              : AppColors.goldAccent.withOpacity(0.1);
          shadowColor = AppColors.goldAccent.withOpacity(0.2);
          break;
        case MessageType.dua:
          bubbleColor = isDarkMode
              ? AppColors.info.withOpacity(0.2)
              : AppColors.info.withOpacity(0.1);
          shadowColor = AppColors.info.withOpacity(0.2);
          break;
        case MessageType.error:
          bubbleColor = isDarkMode
              ? AppColors.error.withOpacity(0.2)
              : AppColors.error.withOpacity(0.1);
          shadowColor = AppColors.error.withOpacity(0.2);
          break;
        default:
          bubbleColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
          shadowColor = Colors.black.withOpacity(0.1);
      }

      return BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.lg.topLeft,
          topRight: AppRadius.lg.topRight,
          bottomRight: AppRadius.lg.bottomRight,
          bottomLeft: Radius.circular(4.r),
        ),
        border: Border.all(
          color: _getBorderColor(),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  /// Get border color based on message type
  Color _getBorderColor() {
    switch (message.type) {
      case MessageType.quran:
        return AppColors.primaryGreen.withOpacity(0.3);
      case MessageType.hadith:
        return AppColors.goldAccent.withOpacity(0.3);
      case MessageType.dua:
        return AppColors.info.withOpacity(0.3);
      case MessageType.error:
        return AppColors.error.withOpacity(0.3);
      default:
        return AppColors.divider;
    }
  }

  /// Build message content based on type
  Widget _buildMessageContent(BuildContext context) {
    final textColor = message.isUser ? Colors.white : AppColors.textPrimary;

    switch (message.type) {
      case MessageType.quran:
        return _buildQuranContent(context, textColor);
      case MessageType.hadith:
        return _buildHadithContent(context, textColor);
      case MessageType.dua:
        return _buildDuaContent(context, textColor);
      default:
        return _buildTextContent(context, textColor);
    }
  }

  /// Build regular text content
  Widget _buildTextContent(BuildContext context, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          message.content,
          style: message.isUser
              ? AppTypography.bodyMediumArabic.copyWith(color: textColor)
              : AppTypography.bodyMediumArabic.copyWith(color: textColor),
          textDirection: _getTextDirection(),
        ),
        // Show typing indicator when streaming
        if (isStreaming && !message.isUser) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              _buildTypingIndicator(),
              SizedBox(width: 8.w),
              Text(
                'جاري الكتابة...',
                style: AppTypography.captionArabic.copyWith(
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build Quran verse content with special styling
  Widget _buildQuranContent(BuildContext context, Color textColor) {
    final parts = message.content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arabic verse with special styling
        if (parts.isNotEmpty)
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: AppRadius.sm,
            ),
            child: SelectableText(
              parts.first,
              style: AppTypography.quranText,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),

        if (parts.length > 1) AppSpacing.verticalSpaceSM,

        // Translation and reference
        if (parts.length > 1)
          SelectableText(
            parts.sublist(1).join('\n\n'),
            style: AppTypography.bodyMediumArabic.copyWith(color: textColor),
            textDirection: _getTextDirection(),
          ),
      ],
    );
  }

  /// Build Hadith content with special styling
  Widget _buildHadithContent(BuildContext context, Color textColor) {
    return SelectableText(
      message.content,
      style: AppTypography.azkarText.copyWith(color: textColor),
      textDirection: _getTextDirection(),
    );
  }

  /// Build Dua content with special styling
  Widget _buildDuaContent(BuildContext context, Color textColor) {
    final parts = message.content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arabic dua with special styling
        if (parts.isNotEmpty)
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: AppRadius.sm,
            ),
            child: SelectableText(
              parts.first,
              style: AppTypography.azkarText.copyWith(
                color: AppColors.info,
                fontSize: 18.sp,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),

        if (parts.length > 1) AppSpacing.verticalSpaceSM,

        // Translation
        if (parts.length > 1)
          SelectableText(
            parts.sublist(1).join('\n\n'),
            style: AppTypography.bodyMediumArabic.copyWith(color: textColor),
            textDirection: _getTextDirection(),
          ),
      ],
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen.withOpacity(0.7),
            ),
          ),
        ),
        AppSpacing.horizontalSpaceSM,
        Text(
          'يكتب...',
          style: AppTypography.captionArabic.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build timestamp
  Widget _buildMessageTimestamp(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        _formatTime(message.timestamp),
        style: AppTypography.captionArabic.copyWith(
          color: message.isUser
              ? Colors.white.withOpacity(0.8)
              : AppColors.textSecondary,
          fontSize: 10.sp,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  /// Build user avatar
  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primaryGreen,
        size: AppSizing.iconSM,
      ),
    );
  }

  /// Build assistant avatar
  Widget _buildAssistantAvatar() {
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: AppColors.goldAccent.withOpacity(0.1),
      child: Icon(
        Icons.mosque_rounded,
        color: AppColors.goldAccent,
        size: AppSizing.iconSM,
      ),
    );
  }

  /// Get text direction based on content
  TextDirection _getTextDirection() {
    // Simple heuristic: if the message starts with Arabic characters
    if (message.content.isNotEmpty) {
      final firstChar = message.content.codeUnitAt(0);
      // Arabic Unicode range
      if (firstChar >= 0x0600 && firstChar <= 0x06FF) {
        return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// Show message options on long press
  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: AppRadius.lg.topLeft),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacing.verticalSpaceSM,

              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppRadius.xs,
                ),
              ),

              AppSpacing.verticalSpaceLG,

              // Copy option
              ListTile(
                leading: Icon(
                  Icons.copy_rounded,
                  color: AppColors.primaryGreen,
                ),
                title: Text(
                  'نسخ النص',
                  style: AppTypography.bodyMediumArabic,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ النص'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.sm,
                      ),
                    ),
                  );
                },
              ),

              AppSpacing.verticalSpaceSM,
            ],
          ),
        ),
      ),
    );
  }

  /// Build animated typing indicator
  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 20.w,
      height: 12.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeInOut,
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/model/chat_message.dart';
import 'typing_animation_widget.dart';

/// Widget for displaying individual chat messages
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;
  final bool isStreaming;
  final VoidCallback? onTypingComplete;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
    this.isStreaming = false,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) _buildAssistantAvatar(),
            if (!message.isUser) SizedBox(width: 6.w),
            Flexible(
              child: GestureDetector(
                onLongPress: onLongPress ?? () => _showMessageOptions(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: _buildBubbleDecoration(context),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                    minWidth: 60.w,
                  ),
                  child: Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isLoading)
                        _buildLoadingIndicator()
                      else ...[
                        _buildMessageContent(context),
                        if (!isStreaming && !message.isUser)
                          _buildHighlightBox(context),
                        SizedBox(height: 2.h),
                        _buildMessageTimestamp(context),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (message.isUser) SizedBox(width: 6.w),
            if (message.isUser) _buildUserAvatar(),
          ],
        ),
      ),
    );
  }

  /// Build bubble decoration based on message type and sender
  BoxDecoration _buildBubbleDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      // User message bubble with beautiful gradient
      return BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFF1B5E20), // Darker deep green
            Color(0xFF2E7D32), // Deep green
            Color(0xFF43A047), // Medium green
            Color(0xFF4CAF50), // Primary green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(18.r),
          topEnd: Radius.circular(18.r),
          bottomEnd: Radius.circular(6.r),
          bottomStart: Radius.circular(18.r),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      );
    } else {
      // Assistant message bubble with elegant design
      List<Color> gradientColors;
      Color borderTint;
      List<Color> shadowColors;

      switch (message.type) {
        case MessageType.quran:
          gradientColors = isDarkMode
              ? const [Color(0xFF0D5016), Color(0xFF1B5E20), Color(0xFF2E7D32)]
              : const [Color(0xFFE8F5E8), Color(0xFFF1F8E9), Color(0xFFFFFFFF)];
          borderTint = const Color(0xFF4CAF50);
          shadowColors = [
            const Color(0xFF4CAF50).withValues(alpha: 0.2),
            const Color(0xFF2E7D32).withValues(alpha: 0.1),
          ];
          break;
        case MessageType.hadith:
          gradientColors = isDarkMode
              ? const [Color(0xFF3D3D1A), Color(0xFF4A4A2A), Color(0xFF5D5D3A)]
              : const [Color(0xFFFFF3C4), Color(0xFFFFF8E1), Color(0xFFFFFFFF)];
          borderTint = const Color(0xFFFFB74D);
          shadowColors = [
            const Color(0xFFFFB74D).withValues(alpha: 0.2),
            const Color(0xFFF57C00).withValues(alpha: 0.1),
          ];
          break;
        case MessageType.dua:
          gradientColors = isDarkMode
              ? const [Color(0xFF0A1A5E), Color(0xFF1A237E), Color(0xFF283593)]
              : const [Color(0xFFBBDEFB), Color(0xFFE3F2FD), Color(0xFFFFFFFF)];
          borderTint = const Color(0xFF2196F3);
          shadowColors = [
            const Color(0xFF2196F3).withValues(alpha: 0.2),
            const Color(0xFF1976D2).withValues(alpha: 0.1),
          ];
          break;
        case MessageType.error:
          gradientColors = isDarkMode
              ? const [Color(0xFF3E1723), Color(0xFF5C2C47), Color(0xFF7A4464)]
              : const [Color(0xFFFFCDD2), Color(0xFFFFEBEE), Color(0xFFFFFFFF)];
          borderTint = const Color(0xFFE57373);
          shadowColors = [
            const Color(0xFFE57373).withValues(alpha: 0.2),
            const Color(0xFFD32F2F).withValues(alpha: 0.1),
          ];
          break;
        default:
          gradientColors = isDarkMode
              ? const [Color(0xFF212121), Color(0xFF2C2C2C), Color(0xFF3A3A3A)]
              : const [Color(0xFFF8F9FA), Color(0xFFFFFFFF), Color(0xFFFAFAFA)];
          borderTint = isDarkMode ? Colors.white24 : Colors.black12;
          shadowColors = [
            borderTint.withValues(alpha: 0.15),
            borderTint.withValues(alpha: 0.05),
          ];
      }

      return BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(18.r),
          topEnd: Radius.circular(18.r),
          bottomEnd: Radius.circular(18.r),
          bottomStart: Radius.circular(6.r),
        ),
        border: Border.all(
          color: borderTint.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColors[0],
            blurRadius: 14,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: shadowColors[1],
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          if (!isDarkMode)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.7),
              blurRadius: 3,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
        ],
      );
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

  /// Build regular text content (with optional typing effect for streaming)
  Widget _buildTextContent(BuildContext context, Color textColor) {
    if (isStreaming && !message.isUser) {
      return SimpleTypingText(
        text: message.content,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: textColor,
          height: 1.6,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        textDirection: _getTextDirection(),
        textAlign: TextAlign.right,
        speed: const Duration(milliseconds: 60),
        onComplete: onTypingComplete,
      );
    }

    return SelectableText(
      message.content,
      style: message.isUser
          ? TextStyle(
              fontFamily: 'Cairo',
              color: textColor,
              height: 1.5,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 0.5),
                  blurRadius: 1,
                ),
              ],
            )
          : TextStyle(
              fontFamily: 'Cairo',
              color: textColor,
              height: 1.6,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
      textDirection: _getTextDirection(),
      textAlign: TextAlign.right,
    );
  }

  /// Build a small highlight panel emphasizing the key takeaway
  Widget _buildHighlightBox(BuildContext context) {
    final highlight = _extractHighlight(message.content);
    if (highlight == null || highlight.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.10),
            AppColors.primaryGreen.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 12.w,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'النقطة المهمة:',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0.1,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 2.h),
                Text(
                  highlight,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.5,
                    fontSize: 13.sp,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _extractHighlight(String content) {
    // If content contains a closing statement, use the sentence before it
    final closingIdx = content.indexOf('والله أعلم');
    String base = content;
    if (closingIdx > 0) {
      base = content.substring(0, closingIdx).trim();
    }

    // Split into sentences by Arabic punctuation or newlines
    final sentences = base
        .split(RegExp(r"[\n\r]+|[.!؟]+|[،]+"))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (sentences.isEmpty) return null;

    // Heuristic: choose a mid-length sentence that likely carries the ruling
    sentences.sort(
      (a, b) => (a.length - 80).abs().compareTo((b.length - 80).abs()),
    );
    final candidate = sentences.first;

    // Ensure it’s concise
    return candidate.length > 160
        ? '${candidate.substring(0, 160).trim()}…'
        : candidate;
  }

  /// Build Quran verse content with special styling
  Widget _buildQuranContent(BuildContext context, Color textColor) {
    final parts = message.content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parts.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withValues(alpha: 0.12),
                  AppColors.primaryGreen.withValues(alpha: 0.06),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primaryGreen,
                  size: 18.w,
                ),
                SizedBox(height: 6.h),
                SelectableText(
                  parts.first,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                    letterSpacing: 0.3,
                    color: AppColors.textPrimary,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        if (parts.length > 1) SizedBox(height: 8.h),
        if (parts.length > 1)
          SelectableText(
            parts.sublist(1).join('\n\n'),
            style: TextStyle(
              fontFamily: 'Cairo',
              color: textColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textDirection: _getTextDirection(),
            textAlign: TextAlign.right,
          ),
      ],
    );
  }

  /// Build Hadith content with special styling
  Widget _buildHadithContent(BuildContext context, Color textColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldAccent.withValues(alpha: 0.10),
            AppColors.goldAccent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: AppColors.goldAccent,
                size: 16.w,
              ),
              SizedBox(width: 6.w),
              Text(
                'حديث شريف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SelectableText(
            message.content,
            style: TextStyle(
              fontFamily: 'Amiri',
              color: textColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.7,
              letterSpacing: 0.3,
            ),
            textDirection: _getTextDirection(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build Dua content with special styling
  Widget _buildDuaContent(BuildContext context, Color textColor) {
    final parts = message.content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parts.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withValues(alpha: 0.12),
                  AppColors.info.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: AppColors.info,
                      size: 16.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'دعاء مبارك',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.info,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SelectableText(
                  parts.first,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: AppColors.info,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        if (parts.length > 1) SizedBox(height: 8.h),
        if (parts.length > 1)
          SelectableText(
            parts.sublist(1).join('\n\n'),
            style: TextStyle(
              fontFamily: 'Cairo',
              color: textColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textDirection: _getTextDirection(),
            textAlign: TextAlign.right,
          ),
      ],
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.08),
            AppColors.primaryGreen.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TypingIndicator(color: AppColors.primaryGreen, size: 6.w),
          SizedBox(width: 8.w),
          Text(
            'جاري الكتابة...',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Build timestamp
  Widget _buildMessageTimestamp(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text(
        _formatTime(message.timestamp),
        style: TextStyle(
          fontFamily: 'Cairo',
          color: message.isUser
              ? Colors.white.withValues(alpha: 0.85)
              : AppColors.textSecondary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  /// Build user avatar
  Widget _buildUserAvatar() {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: 16.w),
    );
  }

  /// Build assistant avatar
  Widget _buildAssistantAvatar() {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8F00), Color(0xFFFFB74D), Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB74D).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(Icons.mosque_rounded, color: Colors.white, size: 16.w),
    );
  }

  /// Get text direction based on content
  TextDirection _getTextDirection() {
    if (message.content.isNotEmpty) {
      final firstChar = message.content.codeUnitAt(0);
      if (firstChar >= 0x0600 && firstChar <= 0x06FF) {
        return TextDirection.rtl;
      }
    }
    return TextDirection.rtl; // Force RTL alignment for Arabic-first UX
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
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppRadius.xs,
                ),
              ),
              AppSpacing.verticalSpaceLG,
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    color: AppColors.primaryGreen,
                    size: 20.w,
                  ),
                ),
                title: Text(
                  'نسخ النص',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                subtitle: Text(
                  'انسخ محتوى الرسالة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'تم نسخ النص بنجاح',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      duration: const Duration(seconds: 2),
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
}

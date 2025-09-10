import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/chat_message_bubble.dart';

/// Main chatbot screen with Islamic assistant interface
class ChatbotScreen extends StatefulWidget {
  final String? userId;

  const ChatbotScreen({
    super.key,
    this.userId,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _titleAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize title animations
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    // Start title animation
    _titleAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ChatbotCubit, ChatbotState>(
        listener: (context, state) {
          if (state is ChatbotLoaded && state.error != null) {
            _showErrorSnackBar(context, state.error!);
            context.read<ChatbotCubit>().clearError();
          }

          // Auto scroll to bottom when new message arrives
          if (state is ChatbotLoaded &&
              state.currentSession.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        },
        builder: (context, state) {
          if (state is ChatbotInitial || state is ChatbotLoading) {
            return _buildLoadingView();
          } else if (state is ChatbotError) {
            return _buildErrorView(context, state.message);
          } else if (state is ChatbotStreamingResponse) {
            return _buildStreamingChatView(context, state);
          } else if (state is ChatbotLoaded) {
            return _buildChatView(context, state);
          }

          return _buildLoadingView();
        },
      ),
    );
  }

  /// Build app bar with Islamic styling
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      title: AnimatedBuilder(
        animation:
            Listenable.merge([_titleFadeAnimation, _titleSlideAnimation]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _titleFadeAnimation,
            child: SlideTransition(
              position: _titleSlideAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: AppSizing.iconSM,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المساعد الإسلامي الذكي',
                        style: AppTypography.h6Arabic.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI Islamic Assistant',
                        style: AppTypography.captionEnglish.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        // More options menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
          ),
          color: Colors.white,
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'new_chat',
              child: Row(
                children: [
                  Icon(Icons.add_comment_rounded,
                      color: AppColors.primaryGreen),
                  AppSpacing.horizontalSpaceSM,
                  Text('محادثة جديدة', style: AppTypography.bodyMediumArabic),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_history',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                  AppSpacing.horizontalSpaceSM,
                  Text('مسح التاريخ', style: AppTypography.bodyMediumArabic),
                ],
              ),
            ),
          ],
        ),
      ],
      systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
    );
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
          AppSpacing.verticalSpaceLG,
          Text(
            'جاري تهيئة المساعد...',
            style: AppTypography.bodyLargeArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'عذراً، حدث خطأ',
              style: AppTypography.h5Arabic.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              error,
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton.icon(
              onPressed: () => context.read<ChatbotCubit>().initialize(
                    widget.userId ?? 'anonymous_user',
                  ),
              icon: Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main chat view
  Widget _buildChatView(BuildContext context, ChatbotLoaded state) {
    final messages = state.currentSession.messages;

    return Column(
      children: [
        // Messages list
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.lg,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatMessageBubble(
                      message: message,
                      onLongPress: () {
                        // Handle message long press if needed
                      },
                    );
                  },
                ),
        ),

        // Chat input
        ChatInputWidget(
          onSendMessage: (message) {
            context.read<ChatbotCubit>().sendStreamingMessage(message);
          },
          isEnabled: !state.isTyping,
        ),
      ],
    );
  }

  /// Build streaming chat view with real-time typing effect
  Widget _buildStreamingChatView(
      BuildContext context, ChatbotStreamingResponse state) {
    final messages = List<ChatMessage>.from(state.currentSession.messages);

    // Add a temporary streaming message if we have streaming text
    if (state.currentStreamText.isNotEmpty) {
      final streamingMessage = ChatMessage.assistant(
        id: 'streaming_temp',
        content: state.currentStreamText,
        type: MessageType.text,
      );
      messages.add(streamingMessage);
    }

    return Column(
      children: [
        // Messages list
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.lg,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isStreaming = message.id == 'streaming_temp';

                    return ChatMessageBubble(
                      message: message,
                      isStreaming: isStreaming,
                      onLongPress: () {
                        // Handle message long press if needed
                      },
                    );
                  },
                ),
        ),

        // Chat input (disabled during streaming)
        ChatInputWidget(
          onSendMessage: (message) {
            context.read<ChatbotCubit>().sendStreamingMessage(message);
          },
          isEnabled: false, // Disabled during streaming
        ),
      ],
    );
  }

  /// Build empty state when no messages
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Islamic greeting icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.1),
                    AppColors.goldAccent.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.mosque_rounded,
                size: 40.w,
                color: AppColors.primaryGreen,
              ),
            ),

            AppSpacing.verticalSpaceXL,

            Text(
              'السلام عليكم ورحمة الله وبركاته',
              style: AppTypography.h5Arabic.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSpaceSM,

            Text(
              'مرحباً بك في المساعد الإسلامي الذكي\nيمكنني مساعدتك في أسئلتك الإسلامية',
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSpaceXL,

            // Quick suggestions
            _buildQuickSuggestions(context),
          ],
        ),
      ),
    );
  }

  /// Build quick suggestion buttons
  Widget _buildQuickSuggestions(BuildContext context) {
    final suggestions = [
      {
        'icon': Icons.menu_book_rounded,
        'text': 'آية من القرآن',
        'query': 'أريد آية من القرآن'
      },
      {
        'icon': Icons.star_rounded,
        'text': 'حديث شريف',
        'query': 'أريد حديث نبوي شريف'
      },
      {
        'icon': Icons.favorite_rounded,
        'text': 'دعاء مأثور',
        'query': 'أريد دعاء من السنة'
      },
      {
        'icon': Icons.schedule_rounded,
        'text': 'عن الصلاة',
        'query': 'أخبرني عن الصلاة'
      },
    ];

    return Column(
      children: [
        Text(
          'اقتراحات سريعة:',
          style: AppTypography.captionArabic.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: suggestions.map((suggestion) {
            return InkWell(
              onTap: () => context.read<ChatbotCubit>().sendStreamingMessage(
                    suggestion['query'] as String,
                  ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: AppRadius.lg,
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      suggestion['icon'] as IconData,
                      size: AppSizing.iconSM,
                      color: AppColors.primaryGreen,
                    ),
                    AppSpacing.horizontalSpaceXS,
                    Text(
                      suggestion['text'] as String,
                      style: AppTypography.captionArabic.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'new_chat':
        context.read<ChatbotCubit>().createNewSession();
        break;
      case 'clear_history':
        _showClearHistoryDialog(context);
        break;
    }
  }

  /// Show clear history confirmation dialog
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'مسح تاريخ المحادثات',
          style: AppTypography.h6Arabic,
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في مسح جميع المحادثات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: AppTypography.bodyMediumArabic,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatbotCubit>().clearHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text('مسح'),
          ),
        ],
      ),
    );
  }

  /// Show error snack bar
  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sm,
        ),
        action: SnackBarAction(
          label: 'موافق',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

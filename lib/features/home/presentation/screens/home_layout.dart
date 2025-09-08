import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/usecases/home_usecases.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../cubit/home_navigation_cubit.dart';
import '../cubit/home_cubit.dart';
import '../view/home_screen.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/modern_bottom_nav_bar.dart';
import '../../../tasbeeh/presentation/screens/tasbeeh_screen.dart';
import '../../../quran/presentation/screens/quran_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Main Home Layout with Bottom Navigation and AppBar
class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  // Draggable FAB position - start with safe default position
  Offset? _fabPosition;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
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

  // Get safe initial FAB position - centered on screen
  Offset _getSafeFabPosition(BuildContext context) {
    if (_fabPosition != null) return _fabPosition!;

    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final fabSize = 60.w; // Approximate FAB size

    return Offset(
      screenSize.width - fabSize - 16, // 16 = margin من اليمين
      screenSize.height - fabSize - safeArea.bottom - 200, // 16 = margin من تحت
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getAppBarTitle(int currentIndex) {
    final titles = [
      'الرئيسية',
      'القرآن الكريم',
      'التسبيح',
      'الإعدادات',
    ];
    return titles[currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeNavigationCubit()),
        BlocProvider(
          create: (context) {
            final repository = HomeRepositoryImpl();
            return HomeCubit(
              getHomeFeaturesUseCase: GetHomeFeaturesUseCase(repository),
              getGreetingUseCase: GetGreetingUseCase(repository),
              getUserStatsUseCase: GetUserStatsUseCase(repository),
            )..loadHomeData();
          },
        ),
      ],
      child: BlocBuilder<HomeNavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            // extendBody: true,
            // extendBodyBehindAppBar: true,

            // Custom AppBar
            appBar: HomeAppBar(
              title: _getAppBarTitle(currentIndex),
              onMenuPressed: () {
                // Handle menu action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('القائمة قريباً إن شاء الله'),
                    backgroundColor: AppColors.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md,
                    ),
                  ),
                );
              },
              onNotificationPressed: () {
                // Handle notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('الإشعارات قريباً إن شاء الله'),
                    backgroundColor: AppColors.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md,
                    ),
                  ),
                );
              },
            ),

            // Body with different screens and draggable FAB
            body: Stack(
              children: [
                _buildBody(currentIndex),
                _buildDraggableChatbot(context),
              ],
            ),

            // Bottom Navigation Bar
            bottomNavigationBar: ModernBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                context.read<HomeNavigationCubit>().navigateToTab(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 2:
        return const TasbeehScreen();
      case 1:
        return const QuranScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  /// Draggable Floating Chatbot Button
  Widget _buildDraggableChatbot(BuildContext context) {
    final currentPosition = _fabPosition ?? _getSafeFabPosition(context);

    return Positioned(
      left: currentPosition.dx,
      top: currentPosition.dy,
      child: Draggable(
        feedback: _buildChatbotButton(context, isDragging: true),
        childWhenDragging: Container(), // Hide original when dragging
        onDragEnd: (details) {
          setState(() {
            // Keep FAB within screen bounds
            final screenSize = MediaQuery.of(context).size;
            final safeArea = MediaQuery.of(context).padding;
            final fabSize = 60.w; // Approximate FAB size

            _fabPosition = Offset(
              details.offset.dx.clamp(0, screenSize.width - fabSize),
              details.offset.dy.clamp(
                AppSizing.appBarHeight + safeArea.top + 20.h,
                screenSize.height -
                    kBottomNavigationBarHeight -
                    safeArea.bottom -
                    20.h, // Safe margin above bottom nav
              ),
            );
          });
        },
        child: _buildChatbotButton(context),
      ),
    );
  }

  /// Chatbot Button Widget
  Widget _buildChatbotButton(BuildContext context, {bool isDragging = false}) {
    return GestureDetector(
      onTap: isDragging ? null : () => _showChatbotBottomSheet(context),
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * _scaleAnimation.value,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    blurRadius: isDragging ? 20 : 12,
                    offset: const Offset(0, 4),
                  ),
                  // Glow effect
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: isDragging ? 30 : 20,
                    spreadRadius: isDragging ? 5 : 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pulse circle
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Main icon
                  Icon(
                    Icons.mosque_rounded, // Islamic mosque icon
                    color: Colors.white,
                    size: AppSizing.iconMD,
                  ),
                  // Chat indicator
                  Positioned(
                    top: 12.w,
                    right: 12.w,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show Chatbot Bottom Sheet
  void _showChatbotBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChatbotBottomSheet(context),
    );
  }

  /// Chatbot Bottom Sheet Content
  Widget _buildChatbotBottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl.topLeft.x),
          topRight: Radius.circular(AppRadius.xl.topRight.x),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: AppRadius.sm,
            ),
          ),

          // Header
          Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.goldAccent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl.topLeft.x),
                topRight: Radius.circular(AppRadius.xl.topRight.x),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: AppSizing.iconMD,
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المساعد الإسلامي الذكي',
                        style: AppTypography.h6Arabic.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI Islamic Assistant',
                        style: AppTypography.captionEnglish.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Chat content (placeholder)
          Expanded(
            child: Container(
              padding: AppSpacing.paddingLG,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: AppSpacing.paddingXL,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 48.w,
                          color: AppColors.primaryGreen,
                        ),
                        AppSpacing.verticalSpaceMD,
                        Text(
                          'مرحباً بك في المساعد الإسلامي الذكي',
                          textAlign: TextAlign.center,
                          style: AppTypography.h6Arabic.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.verticalSpaceSM,
                        Text(
                          'يمكنني مساعدتك في:\n• أسئلة حول الإسلام\n• تفسير القرآن\n• الأحاديث النبوية\n• أحكام الصلاة والزكاة\n• الأذكار والأدعية',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMediumArabic.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        AppSpacing.verticalSpaceLG,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withOpacity(0.1),
                            borderRadius: AppRadius.md,
                          ),
                          child: Text(
                            'قريباً إن شاء الله',
                            style: AppTypography.labelMediumArabic.copyWith(
                              color: AppColors.goldAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

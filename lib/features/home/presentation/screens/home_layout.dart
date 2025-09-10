import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations for center FAB
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

            // Body with different screens
            body: _buildBody(currentIndex),

            // Floating Action Button in center
            floatingActionButton: _buildCenterFloatingButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

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

  /// Center Floating Action Button
  Widget _buildCenterFloatingButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chatbot'),
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * _scaleAnimation.value,
            child: Container(
              width: 65.w,
              height: 65.w,
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
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                  // Glow effect
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pulse circle
                  Container(
                    width: 55.w,
                    height: 55.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Main icon
                  Icon(
                    Icons.mosque_rounded, // Islamic mosque icon
                    color: Colors.white,
                    size: AppSizing.iconLG,
                  ),
                  // Chat indicator
                  Positioned(
                    top: 10.w,
                    right: 10.w,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
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
                        size: 8.w,
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
}

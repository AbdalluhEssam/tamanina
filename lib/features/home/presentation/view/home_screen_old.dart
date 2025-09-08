import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/home_usecases.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/welcome_card.dart';
import '../widgets/home_feature_card.dart';
import '../widgets/modern_bottom_nav_bar.dart';
import '../widgets/tab_screens/quran_tab_screen.dart';
import '../widgets/tab_screens/tasbeeh_tab_screen.dart';
import '../widgets/tab_screens/settings_tab_screen.dart';

/// Main Home Screen with Clean Architecture and Islamic Design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attempt to read HomeCubit; if not found, don't call it here. The
    // widget's build() will create a local Provider if necessary.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final cubit = context.read<HomeCubit>();
        cubit.loadHomeData();
      } catch (e) {
        // No HomeCubit provided above this widget; skip. A local cubit
        // will be created in build() when needed.
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background

      appBar: HomeAppBar(
        title: _getAppBarTitle(),
        onMenuPressed: () => _showDrawer(context),
        onNotificationPressed: () => _showNotifications(context),
      ),
      body: Stack(
        // fit: StackFit.expand,
        children: [
          // Islamic Background Pattern
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: CustomPaint(
              painter: _IslamicBackgroundPainter(),
              child: Container(),
            ),
          ),

          // Main Content with Tab Navigation
          Builder(builder: (ctx) {
            // Show different content based on current tab
            if (_currentNavIndex == 1) {
              return const QuranTabScreen();
            } else if (_currentNavIndex == 2) {
              return const TasbeehTabScreen();
            } else if (_currentNavIndex == 3) {
              return const SettingsTabScreen();
            }

            // Default Home Tab (index 0)
            try {
              ctx.read<HomeCubit>();
              // HomeCubit exists above
              return BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return _buildLoadingState();
                  } else if (state is HomeLoaded) {
                    return _buildLoadedState(state);
                  } else if (state is HomeError) {
                    return _buildErrorState(state.message);
                  }
                  return _buildInitialState();
                },
              );
            } catch (e) {
              // No HomeCubit provided; create a local one
              final repository = HomeRepositoryImpl();
              final cubit = HomeCubit(
                getHomeFeaturesUseCase: GetHomeFeaturesUseCase(repository),
                getGreetingUseCase: GetGreetingUseCase(repository),
                getUserStatsUseCase: GetUserStatsUseCase(repository),
              );
              // Load data for local cubit
              cubit.loadHomeData();

              return BlocProvider<HomeCubit>.value(
                value: cubit,
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return _buildLoadingState();
                    } else if (state is HomeLoaded) {
                      return _buildLoadedState(state);
                    } else if (state is HomeError) {
                      return _buildErrorState(state.message);
                    }
                    return _buildInitialState();
                  },
                ),
              );
            }
          }),
        ],
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          _handleBottomNavTap(index);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            strokeWidth: 3,
          ),
          AppSpacing.verticalSpaceLG,
          Text(
            'جاري التحميل...',
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(HomeLoaded state) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<HomeCubit>().refreshHomeData();
          },
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: AppSizing.appBarHeight,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              bottom: 60.h, // Space for FAB and BottomNav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                WelcomeCard(
                  greeting: state.greeting,
                  stats: state.stats,
                ),

                AppSpacing.verticalSpaceXL,

                // Features Section Title
                _buildSectionTitle('الخصائص الرئيسية', 'Main Features'),

                AppSpacing.verticalSpaceLG,

                // Features Grid
                _buildFeaturesGrid(state.features),

                AppSpacing.verticalSpaceXL,

                // Quick Access Section
                _buildQuickAccessSection(),
              ],
            ),
          ),
        ),

        // Simple Floating Chat Button - Only in Home Tab
        Positioned(
          right: 20.w,
          bottom: 100.h,
          child: _buildChatFAB(),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
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
              'حدث خطأ',
              style: AppTypography.h5Arabic.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadHomeData(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const SizedBox.shrink();
  }

  Widget _buildChatFAB() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E7D32), // Dark Green
              Color(0xFF388E3C), // Slightly lighter green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: AppColors.goldAccent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: _openChatBot,
          borderRadius: BorderRadius.circular(28.r),
          child: Center(
            child: Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 22.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String arabicTitle, String englishTitle) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.goldAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        AppSpacing.horizontalSpaceMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arabicTitle,
                style: AppTypography.h6Arabic.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                englishTitle,
                style: AppTypography.captionEnglish.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(List features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15, // Better proportions to avoid overflow
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final colors = _getFeatureColors(feature.color);

        return HomeFeatureCard(
          titleArabic: feature.titleArabic,
          titleEnglish: feature.titleEnglish,
          iconPath: feature.iconPath,
          color: colors,
          isActive: feature.isActive,
          onTap: () => _navigateToFeature(feature),
        );
      },
    );
  }

  Widget _buildQuickAccessSection() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.goldAccent,
                size: AppSizing.iconMD,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                'وصول سريع',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAccessButton(
                'التسبيح',
                Icons.radio_button_checked,
                AppColors.primaryGreen,
                () => Navigator.pushNamed(context, '/sebha'),
              ),
              _buildQuickAccessButton(
                'القبلة',
                Icons.navigation_rounded,
                AppColors.primaryBlue,
                () => Navigator.pushNamed(context, '/qibla'),
              ),
              _buildQuickAccessButton(
                'الأذكار',
                Icons.auto_stories_rounded,
                AppColors.goldAccent,
                () => Navigator.pushNamed(context, '/azkar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.md,
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizing.iconMD,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            title,
            style: AppTypography.captionArabic.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openChatBot() {
    // Navigate to chatbot screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('سيتم إضافة المساعد الذكي قريباً إن شاء الله'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    // No navigation, just update state to show different content
    // The setState is already handled in the onTap callback above
  }

  String _getAppBarTitle() {
    switch (_currentNavIndex) {
      case 0:
        return 'طمأنينة';
      case 1:
        return 'القرآن الكريم';
      case 2:
        return 'التسبيح';
      case 3:
        return 'الإعدادات';
      default:
        return 'طمأنينة';
    }
  }

  Color _getFeatureColors(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return AppColors.primaryGreen;
      case 'blue':
        return AppColors.primaryBlue;
      case 'gold':
        return AppColors.goldAccent;
      case 'orange':
        return AppColors.warning;
      case 'purple':
        return AppColors.ishaColor;
      case 'teal':
        return AppColors.info;
      default:
        return AppColors.primaryGreen;
    }
  }

  void _navigateToFeature(dynamic feature) {
    // Show a snackbar for now since we don't have all screens implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم فتح ${feature.titleArabic} قريباً إن شاء الله'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
        ),
      ),
    );
  }

  void _showDrawer(BuildContext context) {
    // Implement drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('سيتم إضافة القائمة الجانبية قريباً'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    // Implement notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('لا توجد إشعارات جديدة'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

/// Custom Painter for Islamic Background Pattern
class _IslamicBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final goldPaint = Paint()
      ..color = AppColors.goldAccent.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw subtle Islamic patterns
    _drawSubtleStars(canvas, size, paint);
    _drawSubtleLines(canvas, size, goldPaint);
  }

  void _drawSubtleStars(Canvas canvas, Size size, Paint paint) {
    const int starsCount = 8;
    const double starSize = 15.0;

    for (int i = 0; i < starsCount; i++) {
      final double x = (size.width / starsCount) * i + starSize;
      final double y = size.height * 0.15 + (i % 2) * 80;

      _drawSimpleStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  void _drawSimpleStar(Canvas canvas, Offset center, double size, Paint paint) {
    const int points = 8;
    const double angle = 2 * math.pi / points;

    final Path path = Path();

    for (int i = 0; i < points; i++) {
      final double radius = (i % 2 == 0) ? size : size * 0.5;
      final double x = center.dx + radius * math.cos(angle * i);
      final double y = center.dy + radius * math.sin(angle * i);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSubtleLines(Canvas canvas, Size size, Paint paint) {
    // Gentle decorative lines
    paint.strokeWidth = 0.5;

    for (int i = 0; i < 4; i++) {
      final double y = size.height * 0.2 * (i + 1);
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.25, y),
        paint,
      );

      canvas.drawLine(
        Offset(size.width * 0.75, y),
        Offset(size.width * 0.95, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

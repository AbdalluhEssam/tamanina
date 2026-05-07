import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/location_service.dart';
import '../cubit/prayer_home_cubit.dart';
import '../cubit/prayer_home_state.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/next_prayer_countdown.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/date_location_header.dart';

/// الشاشة الرئيسية المحسنة
/// Enhanced Home Screen with Prayer Times
class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdownTimer();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // Refresh countdown
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => PrayerHomeCubit()..loadPrayerTimes(),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: BlocBuilder<PrayerHomeCubit, PrayerHomeState>(
          builder: (context, state) {
            if (state is PrayerHomeLoading) {
              return _buildLoadingState();
            } else if (state is PrayerHomeLoaded) {
              return _buildLoadedState(context, state, isDark);
            } else if (state is PrayerHomeError) {
              return _buildErrorState(context, state, isDark);
            } else if (state is PrayerHomeLocationDenied) {
              return _buildLocationDeniedState(context, state, isDark);
            }
            return _buildLoadingState();
          },
        ),
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
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل أوقات الصلاة...',
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
      BuildContext context, PrayerHomeLoaded state, bool isDark) {
    return RefreshIndicator(
      onRefresh: () => context.read<PrayerHomeCubit>().refreshPrayerTimes(),
      color: AppColors.primaryGreen,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header with date and location
            SliverToBoxAdapter(
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: DateLocationHeader(
                  hijriDate: state.prayerTimes.hijriDate,
                  gregorianDate: state.prayerTimes.gregorianDate,
                  cityName: state.prayerTimes.cityName,
                  countryName: state.prayerTimes.countryName,
                  isDark: isDark,
                ),
              ),
            ),

            // Next prayer countdown card
            SliverToBoxAdapter(
              child: FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
                child: NextPrayerCountdown(
                  nextPrayer: state.prayerTimes.nextPrayer,
                  currentPrayer: state.prayerTimes.currentPrayer,
                  isDark: isDark,
                ),
              ),
            ),

            // Prayer times list
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                  child: _buildPrayerTimesSection(state.prayerTimes, isDark),
                ),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: QuickActionButtons(isDark: isDark),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 100.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesSection(DailyPrayerTimes prayerTimes, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppColors.primaryGreen,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'مواقيت الصلاة',
                style: AppTypography.h6Arabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Prayer times grid
          ...prayerTimes.allPrayers.map((prayer) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: PrayerTimeCard(
                  prayer: prayer,
                  isDark: isDark,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, PrayerHomeError state, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ',
              style: AppTypography.h5Arabic.copyWith(
                color: isDark
                    ? AppColors.textOnSurfaceDark
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<PrayerHomeCubit>().loadPrayerTimes(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDeniedState(
      BuildContext context, PrayerHomeLocationDenied state, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 64.w,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'يلزم تفعيل الموقع',
              style: AppTypography.h5Arabic.copyWith(
                color: isDark
                    ? AppColors.textOnSurfaceDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final locationService = LocationService();
                    if (state.errorType == LocationErrorType.serviceDisabled) {
                      await locationService.openLocationSettings();
                    } else {
                      await locationService.openAppSettings();
                    }
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('فتح الإعدادات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<PrayerHomeCubit>().useManualLocation(),
                  icon: const Icon(Icons.edit_location_rounded),
                  label: const Text('اختيار يدوي'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

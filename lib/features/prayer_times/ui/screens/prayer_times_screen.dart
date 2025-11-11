import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/model/prayer_time_model.dart';
import '../cubit/prayer_times_cubit.dart';
import '../widgets/prayer_card.dart';

/// شاشة مواقيت الصلاة
/// Prayer Times Screen
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('🕌 مواقيت الصلاة'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
        builder: (context, state) {
          if (state is PrayerTimesInitial) {
            // Auto-load on first open
            context.read<PrayerTimesCubit>().loadPrayerTimes();
            return _buildLoadingView();
          } else if (state is PrayerTimesLoading) {
            return _buildLoadingView();
          } else if (state is PrayerTimesLoaded) {
            return _buildLoadedView(context, state);
          } else if (state is PrayerTimesError) {
            return _buildErrorView(context, state);
          } else if (state is PrayerTimesLocationDenied) {
            return _buildLocationDeniedView(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Loading view
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'جاري تحميل أوقات الصلاة...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Loaded view with prayer times
  Widget _buildLoadedView(BuildContext context, PrayerTimesLoaded state) {
    final prayers = _buildPrayersList(state.prayerTimes, state.nextPrayer);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => context.read<PrayerTimesCubit>().refreshPrayerTimes(),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          // Date Header
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _buildDateHeader(state, isDark),
          ),

          SizedBox(height: AppSpacing.md),

          // Next Prayer Countdown
          if (state.nextPrayer != null && state.timeUntilNextPrayer != null)
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: _buildNextPrayerCard(
                state.nextPrayer!,
                state.timeUntilNextPrayer!,
                isDark,
              ),
            ),

          SizedBox(height: AppSpacing.lg),

          // Prayer Times List
          ...prayers.asMap().entries.map((entry) {
            final index = entry.key;
            final prayer = entry.value;
            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: 200 + (index * 100)),
              child: prayer,
            );
          }),

          SizedBox(height: AppSpacing.xl),

          // Location Info
          FadeIn(
            duration: const Duration(milliseconds: 600),
            child: _buildLocationInfo(state, isDark),
          ),
        ],
      ),
    );
  }

  /// Date header with Hijri and Gregorian dates
  Widget _buildDateHeader(PrayerTimesLoaded state, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: AppColors.islamicGradient,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hijri Date
          Text(
            state.prayerTimes.hijriDate,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Container(
            height: 1,
            width: 100.w,
            color: Colors.white.withOpacity(0.5),
          ),
          SizedBox(height: AppSpacing.xs),
          // Gregorian Date
          Text(
            state.prayerTimes.readableDate,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Next prayer countdown card
  Widget _buildNextPrayerCard(
    String prayerName,
    Duration timeRemaining,
    bool isDark,
  ) {
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);
    final seconds = timeRemaining.inSeconds.remainder(60);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldAccent,
            AppColors.goldDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '⏰ الصلاة القادمة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            prayerName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'ساعة'),
              Text(
                ' : ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'دقيقة'),
              Text(
                ' : ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'ثانية'),
            ],
          ),
        ],
      ),
    );
  }

  /// Time unit for countdown
  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  /// Build list of prayer cards
  List<Widget> _buildPrayersList(
      PrayerTimeModel prayerTimes, String? nextPrayer) {
    final prayers = [
      Prayer(
        nameAr: 'الفجر',
        nameEn: 'Fajr',
        time: prayerTimes.fajr,
        emoji: '🌅',
      ),
      Prayer(
        nameAr: 'الظهر',
        nameEn: 'Dhuhr',
        time: prayerTimes.dhuhr,
        emoji: '☀️',
      ),
      Prayer(
        nameAr: 'العصر',
        nameEn: 'Asr',
        time: prayerTimes.asr,
        emoji: '🌤️',
      ),
      Prayer(
        nameAr: 'المغرب',
        nameEn: 'Maghrib',
        time: prayerTimes.maghrib,
        emoji: '🌇',
      ),
      Prayer(
        nameAr: 'العشاء',
        nameEn: 'Isha',
        time: prayerTimes.isha,
        emoji: '🌙',
      ),
    ];

    final prayerColors = {
      'الفجر': AppColors.fajrColor,
      'الظهر': AppColors.dhuhrColor,
      'العصر': AppColors.asrColor,
      'المغرب': AppColors.maghribColor,
      'العشاء': AppColors.ishaColor,
    };

    return prayers.map((prayer) {
      final isNext = prayer.nameAr == nextPrayer;
      return PrayerCard(
        prayerNameAr: prayer.nameAr,
        prayerTime: prayer.time,
        emoji: prayer.emoji,
        isNext: isNext,
        color: prayerColors[prayer.nameAr],
      );
    }).toList();
  }

  /// Location info footer
  Widget _buildLocationInfo(PrayerTimesLoaded state, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.creamAccent.withOpacity(0.3),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 16.sp,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            '${state.city}${state.country.isNotEmpty ? ', ${state.country}' : ''}',
            style: TextStyle(
              color: isDark
                  ? AppColors.textOnSurfaceDark
                  : AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Error view
  Widget _buildErrorView(BuildContext context, PrayerTimesError state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textOnSurfaceDark
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<PrayerTimesCubit>().loadPrayerTimes(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  /// Location denied view
  Widget _buildLocationDeniedView(
    BuildContext context,
    PrayerTimesLocationDenied state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80.sp,
              color: AppColors.warning,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'إذن الموقع مطلوب',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textOnSurfaceDark
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<PrayerTimesCubit>().loadPrayerTimesByLocation(),
              icon: const Icon(Icons.location_on),
              label: const Text('السماح بالوصول إلى الموقع'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/location_service.dart';

/// حالات شاشة القبلة
enum QiblaState { loading, loaded, error, noCompass, noLocation }

/// شاشة القبلة
/// Qibla Compass Screen
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  QiblaState _state = QiblaState.loading;
  String _errorMessage = '';
  double _qiblaDirection = 0;
  double _currentHeading = 0;
  double _distanceToKaaba = 0;
  StreamSubscription<CompassEvent>? _compassSubscription;
  final LocationService _locationService = LocationService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;

  // Kaaba coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initQibla();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _initQibla() async {
    setState(() => _state = QiblaState.loading);

    try {
      // Check compass availability
      final hasCompass = await FlutterCompass.events != null;
      if (!hasCompass) {
        setState(() {
          _state = QiblaState.noCompass;
          _errorMessage = 'جهازك لا يدعم البوصلة';
        });
        return;
      }

      // Initialize location service
      await _locationService.initialize();

      // Get location
      final locationResult = await _locationService.getCurrentLocation();
      if (!locationResult.isSuccess) {
        setState(() {
          _state = QiblaState.noLocation;
          _errorMessage =
              locationResult.errorMessage ?? 'تعذر الحصول على الموقع';
        });
        return;
      }

      // Calculate Qibla direction
      _qiblaDirection = _calculateQiblaDirection(
        locationResult.latitude!,
        locationResult.longitude!,
      );

      // Calculate distance to Kaaba
      _distanceToKaaba = Geolocator.distanceBetween(
            locationResult.latitude!,
            locationResult.longitude!,
            _kaabaLat,
            _kaabaLng,
          ) /
          1000; // Convert to km

      // Start compass updates
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (mounted && event.heading != null) {
          setState(() {
            _currentHeading = event.heading!;
          });
        }
      });

      setState(() => _state = QiblaState.loaded);
    } catch (e) {
      setState(() {
        _state = QiblaState.error;
        _errorMessage = e.toString();
      });
    }
  }

  double _calculateQiblaDirection(double lat, double lng) {
    // Convert to radians
    final latRad = lat * (math.pi / 180);
    final lngRad = lng * (math.pi / 180);
    final kaabaLatRad = _kaabaLat * (math.pi / 180);
    final kaabaLngRad = _kaabaLng * (math.pi / 180);

    // Calculate direction
    final y = math.sin(kaabaLngRad - lngRad);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(kaabaLngRad - lngRad);

    var qibla = math.atan2(y, x) * (180 / math.pi);
    if (qibla < 0) qibla += 360;

    return qibla;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '🕋 اتجاه القبلة',
          style: AppTypography.appBarTitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    switch (_state) {
      case QiblaState.loading:
        return _buildLoadingState();
      case QiblaState.loaded:
        return _buildCompassView(isDark);
      case QiblaState.noCompass:
        return _buildNoCompassState(isDark);
      case QiblaState.noLocation:
        return _buildNoLocationState(isDark);
      case QiblaState.error:
        return _buildErrorState(isDark);
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحديد اتجاه القبلة...',
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView(bool isDark) {
    // Calculate the rotation needed to point to Qibla
    final qiblaAngle = _qiblaDirection - _currentHeading;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Info card
          _buildInfoCard(isDark),

          SizedBox(height: 24.h),

          // Compass
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildCompass(qiblaAngle, isDark),
              );
            },
          ),

          SizedBox(height: 24.h),

          // Direction info
          _buildDirectionInfo(isDark),

          SizedBox(height: 16.h),

          // Instructions
          _buildInstructions(isDark),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldAccent.withOpacity(0.15),
            AppColors.primaryGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: AppColors.primaryGreen,
              size: 30.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المسافة إلى الكعبة المشرفة',
                  style: AppTypography.labelLargeArabic.copyWith(
                    color: isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_distanceToKaaba.toStringAsFixed(0)} كم',
                  style: AppTypography.h5Arabic.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(double qiblaAngle, bool isDark) {
    return Container(
      width: 300.w,
      height: 300.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass background with cardinal directions
          Transform.rotate(
            angle: -_currentHeading * (math.pi / 180),
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.goldAccent.withOpacity(0.5),
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  // Cardinal directions
                  _buildCardinalDirection('N', 'ش', 0),
                  _buildCardinalDirection('E', 'شر', 90),
                  _buildCardinalDirection('S', 'ج', 180),
                  _buildCardinalDirection('W', 'غ', 270),

                  // Degree markers
                  ...List.generate(72, (index) {
                    final angle = index * 5 * (math.pi / 180);
                    final isMajor = index % 18 == 0;
                    return Transform.rotate(
                      angle: angle,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: isMajor ? 2 : 1,
                          height: isMajor ? 15.h : 8.h,
                          color: isMajor
                              ? AppColors.goldAccent
                              : AppColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Qibla indicator (arrow pointing to Kaaba)
          Transform.rotate(
            angle: qiblaAngle * (math.pi / 180),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 28.w,
                  ),
                ),
                Container(
                  width: 4.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          ),

          // Center indicator
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppColors.goldAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardinalDirection(String en, String ar, double angle) {
    return Transform.rotate(
      angle: angle * (math.pi / 180),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Transform.rotate(
            angle: -angle * (math.pi / 180),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ar,
                  style: TextStyle(
                    color: angle == 0 ? Colors.red : AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionInfo(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            'اتجاه القبلة',
            '${_qiblaDirection.toStringAsFixed(1)}°',
            Icons.explore_rounded,
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.primaryGreen.withOpacity(0.3),
          ),
          _buildInfoItem(
            'اتجاهك الحالي',
            '${_currentHeading.toStringAsFixed(1)}°',
            Icons.navigation_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 24.w),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.captionArabic.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.h6Arabic.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'تعليمات الاستخدام',
                style: AppTypography.labelLargeArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInstructionItem('أمسك الجهاز بشكل أفقي'),
          _buildInstructionItem('ابتعد عن المعادن والأجهزة الإلكترونية'),
          _buildInstructionItem('اتجه نحو الأيقونة الخضراء'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.primaryGreen, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmallArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCompassState(bool isDark) {
    return _buildErrorContent(
      icon: Icons.explore_off_rounded,
      title: 'البوصلة غير متاحة',
      message: 'جهازك لا يدعم البوصلة. يمكنك استخدام الخريطة بدلاً من ذلك.',
      buttonText: 'فتح الخريطة',
      onButtonPressed: _openMapToKaaba,
      isDark: isDark,
    );
  }

  Widget _buildNoLocationState(bool isDark) {
    return _buildErrorContent(
      icon: Icons.location_off_rounded,
      title: 'الموقع غير متاح',
      message: _errorMessage,
      buttonText: 'تفعيل الموقع',
      onButtonPressed: () async {
        await _locationService.openLocationSettings();
        _initQibla();
      },
      isDark: isDark,
    );
  }

  Widget _buildErrorState(bool isDark) {
    return _buildErrorContent(
      icon: Icons.error_outline_rounded,
      title: 'حدث خطأ',
      message: _errorMessage,
      buttonText: 'إعادة المحاولة',
      onButtonPressed: _initQibla,
      isDark: isDark,
    );
  }

  Widget _buildErrorContent({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64.w, color: AppColors.warning),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTypography.h5Arabic.copyWith(
                color: isDark
                    ? AppColors.textOnSurfaceDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(buttonText),
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

  void _openMapToKaaba() {
    // Open maps app with Kaaba location
    // This would require url_launcher
  }
}

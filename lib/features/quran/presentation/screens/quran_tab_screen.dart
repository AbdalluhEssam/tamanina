import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_sharif/quran_sharif.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import 'simple_mushaf_page_screen.dart';

/// شاشة القرآن الكريم بتصميم المصحف الشريف الكلاسيكي
class QuranTabScreen extends StatefulWidget {
  const QuranTabScreen({super.key});

  @override
  State<QuranTabScreen> createState() => _QuranTabScreenState();
}

class _QuranTabScreenState extends State<QuranTabScreen>
    with TickerProviderStateMixin {
  List<Surahs> allSurahs = [];
  bool isLoading = true;
  String? error;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuran();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _loadQuran() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      allSurahs = Quran.getAllSurah();

      setState(() {
        isLoading = false;
      });

      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _scaleController.forward();

      print('✅ تم تحميل ${allSurahs.length} سورة بنجاح');
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      print('❌ خطأ في تحميل القرآن: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 2.0,
            colors: [
              AppColors.backgroundLight,
              AppColors.creamAccent,
              AppColors.lightBeige.withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: AppSizing.appBarHeight,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            bottom: 0.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIslamicHeader(),
              SizedBox(height: 24.h),
              isLoading
                  ? _buildLoadingState()
                  : error != null
                      ? _buildErrorState()
                      : _buildMushafContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIslamicHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.15),
                  AppColors.goldAccent.withOpacity(0.1),
                  Colors.white.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.goldAccent.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDecorativeElement(),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.goldAccent,
                      size: 24.w,
                    ),
                    SizedBox(width: 16.w),
                    _buildDecorativeElement(),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'المصحف الشريف',
                  style: AppTypography.h3Arabic.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'اقرأ وتدبر كلام الله عز وجل',
                  style: AppTypography.bodyMediumArabic.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: AppTypography.bismillahText.copyWith(
                      fontSize: 20.sp,
                      color: AppColors.primaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeElement() {
    return Container(
      width: 40.w,
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.goldAccent,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.goldAccent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundLight,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'جاري تحميل المصحف الشريف...',
            style: AppTypography.bodyLargeArabic.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يرجى الانتظار قليلاً',
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withOpacity(0.1),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'عذراً، حدث خطأ',
            style: AppTypography.h6Arabic.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            error ?? 'حدث خطأ في تحميل القرآن الكريم',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMediumArabic.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _loadQuran,
            icon: Icon(Icons.refresh, size: 20.w),
            label: Text(
              'إعادة المحاولة',
              style: AppTypography.buttonTextMedium,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafContent() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              _buildQuickAccessButtons(),
              SizedBox(height: 20.h),
              _buildSurahsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            'فتح المصحف',
            Icons.menu_book,
            AppColors.primaryGreen,
            () => _openMushaf(1),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickButton(
            'آخر قراءة',
            Icons.bookmark,
            AppColors.goldAccent,
            () => _openLastRead(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickButton(
            'البحث',
            Icons.search,
            AppColors.primaryBlue,
            () => _openSearch(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28.w,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: AppTypography.labelMediumArabic.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.goldAccent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: AppColors.primaryGreen,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  'فهرس السور الكريمة',
                  style: AppTypography.h6Arabic.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${allSurahs.length} سورة',
                  style: AppTypography.captionArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allSurahs.length,
            itemBuilder: (context, index) {
              final surah = allSurahs[index];
              return _buildEnhancedSurahCard(surah, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSurahCard(Surahs surah, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => _navigateToSurah(surah),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  AppColors.backgroundLight.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                _buildSurahNumber(surah.number),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: AppTypography.bodyLargeArabic.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              surah.englishName,
                              style: AppTypography.captionEnglish.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            ' • ',
                            style: AppTypography.captionArabic.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${surah.ayahs.length} آية',
                            style: AppTypography.captionArabic.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            ' • ',
                            style: AppTypography.captionArabic.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: surah.revelationType == 'Meccan'
                                  ? AppColors.goldAccent.withOpacity(0.2)
                                  : AppColors.primaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              surah.revelationType == 'Meccan'
                                  ? 'مكية'
                                  : 'مدنية',
                              style: AppTypography.captionArabic.copyWith(
                                color: surah.revelationType == 'Meccan'
                                    ? AppColors.goldDark
                                    : AppColors.primaryBlueDark,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryGreen,
                    size: 16.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahNumber(int number) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CirclePatternPainter(),
            ),
          ),
          Center(
            child: Text(
              '$number',
              style: AppTypography.labelLargeArabic.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMushaf(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleMushafPageScreen(initialPage: page),
      ),
    );
  }

  void _openLastRead() {
    _openMushaf(50);
  }

  void _openSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'قريباً: البحث في القرآن الكريم',
          style: AppTypography.bodyMediumArabic.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _navigateToSurah(Surahs surah) {
    // فتح المصحف مباشرة مع السورة المحددة
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SimpleMushafPageScreen(
          initialPage: 1, // سنحسب الصفحة الصحيحة لاحقاً
          initialSurah: surah.number,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, paint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * 3.14159) / 8;
      final startX = center.dx + (radius * 0.3) * cos(angle);
      final startY = center.dy + (radius * 0.3) * sin(angle);
      final endX = center.dx + (radius * 0.9) * cos(angle);
      final endY = center.dy + (radius * 0.9) * sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

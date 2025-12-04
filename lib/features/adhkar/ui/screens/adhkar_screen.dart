import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/service_locator.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/adhkar_cubit.dart';
import 'adhkar_detail_screen.dart';

/// شاشة الأذكار الرئيسية - عرض جميع أقسام الأذكار (تصميم مُحسّن)
class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => AdhkarCubit(di.sl()),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: _buildAppBar(context, isDark),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // For UX: allow refreshing if needed (e.g., update counts or tips)
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان الترحيبي المحسّن
                  _buildWelcomeHeader(isDark, context),
                  SizedBox(height: 22.h),

                  // شبكة الأذكار المتجاوبة مع تأثير staggered entry
                  _buildAdhkarGrid(context, isDark),

                  SizedBox(height: 22.h),

                  // نصيحة يومية بتصميم أنيق
                  _buildDailyTip(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: Text(
        'الأذكار',
        style: AppTypography.appBarTitle.copyWith(
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryGreen.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.surfaceDark.withOpacity(0.12),
                  AppColors.surfaceDark.withOpacity(0.06)
                ]
              : [
                  AppColors.primaryGreen.withOpacity(0.08),
                  AppColors.goldAccent.withOpacity(0.02)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? AppColors.surfaceDark.withOpacity(0.06)
              : AppColors.goldAccent.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        children: [
          // بطاقة أيقونة مميزة مع ظل ونهاية منحنية
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withOpacity(0.85)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // نص الترحيب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
                  style: AppTypography.appBarTitle.copyWith(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'سورة الرعد • آية 28',
                  style: AppTypography.bodyLargeArabic?.copyWith(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // زر سريع لبدء أول ذكر
                    ElevatedButton.icon(
                      onPressed: () {
                        // quick action — نافذة اختيار الفئة أو البدء مباشرة
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdhkarDetailScreen(
                                category: AdhkarCategory.morning),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('ابدأ الآن'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        textStyle: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton.icon(
                      onPressed: () {
                        // show tip dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('نصيحة اليوم'),
                            content: const Text(
                                'احرص على قراءة أذكار الصباح والمساء يومياً، حتى لو لم تكتمل كل الأذكار.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('حسناً'))
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('المزيد'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: BorderSide(
                            color: AppColors.primaryGreen.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhkarGrid(BuildContext context, bool isDark) {
    final categories = [
      _AdhkarCategoryData(
        title: 'أذكار الصباح',
        subtitle: 'ابدأ يومك بذكر الله',
        icon: Icons.wb_sunny_rounded,
        category: AdhkarCategory.morning,
        gradientColors: const [Color(0xFFFFB74D), Color(0xFFFFA726)],
        iconColor: const Color(0xFFFF8F00),
        badgeCount: 12,
      ),
      _AdhkarCategoryData(
        title: 'أذكار المساء',
        subtitle: 'اختم يومك بطمأنينة',
        icon: Icons.nightlight_round,
        category: AdhkarCategory.evening,
        gradientColors: const [Color(0xFF7986CB), Color(0xFF5C6BC0)],
        iconColor: const Color(0xFF3F51B5),
        badgeCount: 10,
      ),
      _AdhkarCategoryData(
        title: 'أذكار النوم',
        subtitle: 'نم على ذكر ربك',
        icon: Icons.bedtime_rounded,
        category: AdhkarCategory.sleep,
        gradientColors: const [Color(0xFF9575CD), Color(0xFF7E57C2)],
        iconColor: const Color(0xFF673AB7),
        badgeCount: 8,
      ),
      _AdhkarCategoryData(
        title: 'أذكار بعد الصلاة',
        subtitle: 'أكمل صلاتك بالذكر',
        icon: Icons.mosque_rounded,
        category: AdhkarCategory.postPrayer,
        gradientColors: const [Color(0xFF4DB6AC), Color(0xFF26A69A)],
        iconColor: const Color(0xFF00897B),
        badgeCount: 6,
      ),
      _AdhkarCategoryData(
        title: 'أذكار متنوعة',
        subtitle: 'أدعية وأذكار مختارة',
        icon: Icons.star_rounded,
        category: AdhkarCategory.misc,
        gradientColors: const [Color(0xFFFFD54F), Color(0xFFFFCA28)],
        iconColor: const Color(0xFFFFB300),
        badgeCount: 14,
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    final crossAxis = width > 900
        ? 3
        : width > 600
            ? 2
            : 1;

    // staggered animation: use AnimatedList-like effect with delays using TweenAnimationBuilder
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 3.4,
      ),
      itemBuilder: (context, index) {
        final data = categories[index];
        return _AdhkarCategoryCard(
          data: data,
          isDark: isDark,
          index: index,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AdhkarDetailScreen(category: data.category),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic);
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0.04, 0), end: Offset.zero)
                          .animate(curved),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 360),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDailyTip(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryGreen,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نصيحة اليوم',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen),
                ),
                SizedBox(height: 6.h),
                Text(
                  'داوم على أذكار الصباح والمساء، حتى لو قليلاً يومياً — القليل الدائم أحبّ إلى الله من كثيرٍ منقطع.',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () {
              // share tip or copy
            },
            icon: Icon(Icons.share, color: AppColors.primaryGreen),
          )
        ],
      ),
    );
  }
}

/// بطاقة فئة الأذكار المحسّنة مع حركة دخول وHero
class _AdhkarCategoryCard extends StatefulWidget {
  final _AdhkarCategoryData data;
  final bool isDark;
  final int index;
  final VoidCallback? onTap;

  const _AdhkarCategoryCard({
    required this.data,
    required this.isDark,
    required this.index,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_AdhkarCategoryCard> createState() => _AdhkarCategoryCardState();
}

class _AdhkarCategoryCardState extends State<_AdhkarCategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _scaleAnim = Tween<double>(begin: 0.98, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    // staggered start
    Future.delayed(Duration(milliseconds: 90 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isDark = widget.isDark;
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14.r),
            splashFactory: InkRipple.splashFactory,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // decorative gradient top-right circle
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Transform.rotate(
                      angle: pi / 7,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: data.gradientColors
                                .map((c) => c.withOpacity(0.12))
                                .toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // content
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
                    child: Row(
                      children: [
                        // icon with hero for smooth transition
                        Hero(
                          tag: 'adhkar_icon_${data.category}',
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: data.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 6)),
                              ],
                            ),
                            child: Center(
                              child: Icon(data.icon,
                                  color: Colors.white, size: 28.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 28.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                data.subtitle,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : data.gradientColors[0]
                                              .withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.menu_book_outlined,
                                            size: 14.sp, color: data.iconColor),
                                        SizedBox(width: 6.w),
                                        Text(
                                          '${data.badgeCount} ذكر',
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: data.iconColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  TextButton(
                                    onPressed: widget.onTap,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 6.h),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Row(
                                      children: [
                                        Text('قراءة',
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: AppColors.primaryGreen,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(width: 6.w),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 12.sp,
                                            color: AppColors.primaryGreen),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بيانات فئة الأذكار محسّنة
class _AdhkarCategoryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final AdhkarCategory category;
  final List<Color> gradientColors;
  final Color iconColor;
  final int badgeCount;

  const _AdhkarCategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.gradientColors,
    required this.iconColor,
    this.badgeCount = 0,
  });
}

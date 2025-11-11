import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'simple_mushaf_page_screen.dart';

/// شاشة تشغيل المصحف الشريف
class MushafLauncherScreen extends StatelessWidget {
  const MushafLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0a0a0a),
              const Color(0xFF1a1a1a),
              const Color(0xFF2d2d2d),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة المصحف
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldAccent,
                        AppColors.primaryGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 60.w,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 40.h),

                // العنوان
                Text(
                  'المصحف الشريف',
                  style: AppTypography.h3Arabic.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'تجربة قراءة رقمية تحاكي المصحف التقليدي',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLargeArabic.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 60.h),

                // زر بدء القراءة
                Container(
                  width: 250.w,
                  height: 55.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldAccent,
                        AppColors.goldAccent.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30.r),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SimpleMushafPageScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(30.r),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28.w,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'بدء القراءة',
                              style: AppTypography.h6Arabic.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // خيارات سريعة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickOption(
                      context,
                      icon: Icons.bookmark,
                      title: 'العلامات المرجعية',
                      color: AppColors.primaryGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(title: Text('العلامات المرجعية')),
                              body: Center(child: Text('قريباً')),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickOption(
                      context,
                      icon: Icons.search,
                      title: 'البحث',
                      color: Colors.blue.shade600,
                      onTap: () {
                        // فتح البحث
                      },
                    ),
                    _buildQuickOption(
                      context,
                      icon: Icons.settings,
                      title: 'الإعدادات',
                      color: Colors.grey.shade600,
                      onTap: () {
                        // فتح الإعدادات
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.captionArabic.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

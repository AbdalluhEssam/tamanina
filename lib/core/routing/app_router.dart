import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../../features/splash/presentation/view/splash_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_screen.dart';
import '../../features/home/presentation/view/home_screen.dart';

/// موجه المسارات الرئيسي للتطبيق
/// Main App Router
class AppRouter {
  final SharedPreferences sharedPreferences;

  AppRouter(this.sharedPreferences);

  /// إنشاء المسارات حسب اسم المسار
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _createRoute(const SplashScreen());

      case AppRoutes.onboarding:
        return _createRoute(const OnboardingScreen());

      case AppRoutes.home:
        return _createRoute(const HomeScreen());

      case AppRoutes.settings:
        return _createRoute(_buildComingSoonScreen('الإعدادات'));

      case AppRoutes.prayer:
        return _createRoute(_buildComingSoonScreen('أوقات الصلاة'));

      case AppRoutes.azkar:
        return _createRoute(_buildComingSoonScreen('الأذكار'));

      case AppRoutes.quran:
        return _createRoute(_buildComingSoonScreen('القرآن الكريم'));

      case AppRoutes.sebha:
        return _createRoute(_buildComingSoonScreen('التسبيح'));

      case AppRoutes.qibla:
        return _createRoute(_buildComingSoonScreen('القبلة'));

      case AppRoutes.statistics:
        return _createRoute(_buildComingSoonScreen('الإحصائيات'));

      default:
        return _createRoute(_buildNotFoundScreen());
    }
  }

  /// إنشاء مسار بانتقال ناعم
  PageRouteBuilder _createRoute(Widget page,
      {RouteTransitionType? transition}) {
    return PageRouteBuilder(
      transitionDuration: AppAnimations.normal,
      reverseTransitionDuration: AppAnimations.fast,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          animation,
          secondaryAnimation,
          child,
          transition ?? RouteTransitionType.fade,
        );
      },
    );
  }

  /// بناء انتقالات مختلفة للمسارات
  Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    RouteTransitionType type,
  ) {
    switch (type) {
      case RouteTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case RouteTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );

      case RouteTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }

  /// شاشة "قريباً" للمميزات التي لم تُطور بعد
  Widget _buildComingSoonScreen(String featureName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.backgroundLight,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              featureName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'قريباً...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'نعمل بجد لتوفير هذه الميزة لك قريباً\nترقب التحديثات القادمة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// شاشة خطأ 404 - الصفحة غير موجودة
  Widget _buildNotFoundScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.backgroundLight,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            Text(
              'الصفحة غير موجودة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'عذراً، الصفحة التي تبحث عنها غير موجودة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// أنواع انتقالات المسارات
enum RouteTransitionType {
  fade,
  slide,
  scale,
}

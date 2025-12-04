import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/features/tasbeeh/ui/screens/tasbeeh_screen.dart';
import '../../features/chatbot/ui/screens/chatbot_provider.dart';
import '../../features/prayer_times/data/services/prayer_times_service.dart';
import '../../features/prayer_times/data/repo/prayer_times_repository.dart';
import '../../features/prayer_times/ui/cubit/prayer_times_cubit.dart';
import '../../features/prayer_times/ui/screens/prayer_times_screen.dart';
import '../../features/legal/ui/screens/privacy_policy_screen.dart';
import '../../features/legal/ui/screens/terms_of_service_screen.dart';
import '../../features/settings/ui/screens/notification_settings_screen.dart';
import '../../features/qibla/ui/screens/qibla_screen.dart';
import '../../features/settings/ui/screens/enhanced_settings_screen.dart';
import '../../features/adhkar/ui/screens/adhkar_screen.dart';
import '../../features/quran/ui/screens/quran_tab_screen.dart';
import '../../features/statistics/ui/screens/statistics_screen.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../../features/splash/ui/screens/splash_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/home/ui/screens/home_layout.dart';

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
        return _createRoute(const HomeLayout());

      case AppRoutes.settings:
        return _createRoute(const EnhancedSettingsScreen());

      case AppRoutes.prayer:
        return _createRoute(_buildPrayerTimesScreen());

      case AppRoutes.prayerTimes:
        return _createRoute(_buildPrayerTimesScreen());

      case AppRoutes.azkar:
        return _createRoute(const AdhkarScreen());

      case AppRoutes.quran:
        return _createRoute(const QuranTabScreen());

      case AppRoutes.sebha:
        return _createRoute(Scaffold(
          appBar: AppBar(
            title: const Text('التسبيح'),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.backgroundLight,
          ),
          body: const TasbeehScreen(),
        ));

      case AppRoutes.qibla:
        return _createRoute(const QiblaScreen());

      case AppRoutes.statistics:
        return _createRoute(const StatisticsScreen());

      case AppRoutes.chatbot:
        return _createRoute(const ChatbotProvider());

      case AppRoutes.privacyPolicy:
        return _createRoute(const PrivacyPolicyScreen());

      case AppRoutes.termsOfService:
        return _createRoute(const TermsOfServiceScreen());

      case AppRoutes.notificationSettings:
        return _createRoute(const NotificationSettingsScreen());

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

  /// بناء شاشة مواقيت الصلاة
  Widget _buildPrayerTimesScreen() {
    return BlocProvider(
      create: (context) => PrayerTimesCubit(
        repository: PrayerTimesRepository(
          service: PrayerTimesService(),
          prefs: sharedPreferences,
        ),
        notifications: FlutterLocalNotificationsPlugin(),
      ),
      child: const PrayerTimesScreen(),
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

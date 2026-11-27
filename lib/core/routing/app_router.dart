import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/adhkar/ui/cubit/adhkar_cubit.dart';
import '../../features/adhkar/ui/screens/adhkar_detail_screen.dart';
import '../../features/adhkar/ui/screens/adhkar_screen.dart';
import '../../features/chatbot/ui/screens/chatbot_provider.dart';
import '../../features/home/ui/screens/home_layout.dart';
import '../../features/legal/ui/screens/privacy_policy_screen.dart';
import '../../features/legal/ui/screens/terms_of_service_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/prayer_times/ui/screens/adhan_screen.dart';
import '../../features/prayer_times/ui/screens/prayer_times_screen.dart';
import '../../features/qibla/ui/screens/qibla_screen.dart';
import '../../features/quran/ui/screens/quran_tab_screen.dart';
import '../../features/quran/ui/screens/simple_mushaf_page_screen.dart';
import '../../features/settings/ui/screens/notification_settings_screen.dart';
import '../../features/settings/ui/screens/production_settings_screen.dart';
import '../../features/splash/ui/screens/splash_screen.dart';
import '../../features/statistics/ui/screens/statistics_screen.dart';
import '../../features/tasbeeh/ui/screens/tasbeeh_screen.dart';
import '../constants/app_constants.dart';
import '../widgets/tamanina_ui.dart';

class AppRouter {
  AppRouter(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    if (routeName == AppRoutes.adhan ||
        routeName.startsWith('${AppRoutes.adhan}?')) {
      AdhanScreenArgs args;
      if (settings.arguments is AdhanScreenArgs) {
        args = settings.arguments as AdhanScreenArgs;
      } else {
        final uri = Uri.tryParse(routeName);
        final prayer = uri?.queryParameters['prayer'] ?? 'Prayer';
        final arabic = uri?.queryParameters['arabic'] ?? 'الصلاة';
        final fajr = uri?.queryParameters['fajr'] == 'true';
        args = AdhanScreenArgs(
          prayerName: prayer,
          prayerNameArabic: arabic,
          isFajr: fajr,
          followNative: uri?.queryParameters['follow'] == '1',
        );
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AdhanScreen(args: args),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => switch (settings.name) {
        AppRoutes.splash => const SplashScreen(),
        AppRoutes.onboarding => const OnboardingScreen(),
        AppRoutes.home => const HomeLayout(),
        AppRoutes.settings => const ProductionSettingsScreen(),
        AppRoutes.prayer || AppRoutes.prayerTimes => const PrayerTimesScreen(),
        AppRoutes.azkar => const AdhkarScreen(),
        AppRoutes.morningAdhkar => const AdhkarDetailScreen(
          category: AdhkarCategory.morning,
        ),
        AppRoutes.eveningAdhkar => const AdhkarDetailScreen(
          category: AdhkarCategory.evening,
        ),
        AppRoutes.quran => Scaffold(
          appBar: AppBar(title: Text(appText(context, 'القرآن', 'Quran'))),
          body: const SafeArea(top: false, child: QuranTabScreen()),
        ),
        AppRoutes.mushafReader => const SimpleMushafPageScreen(),
        AppRoutes.alKahfReader => const SimpleMushafPageScreen(
          initialSurah: 18,
        ),
        AppRoutes.sebha => Scaffold(
          appBar: AppBar(title: Text(appText(context, 'السبحة', 'Tasbeeh'))),
          body: const SafeArea(top: false, child: TasbeehScreen()),
        ),
        AppRoutes.qibla => const QiblaScreen(),
        AppRoutes.statistics => const StatisticsScreen(),
        AppRoutes.chatbot => const ChatbotProvider(),
        AppRoutes.privacyPolicy => const PrivacyPolicyScreen(),
        AppRoutes.termsOfService => const TermsOfServiceScreen(),
        AppRoutes.notificationSettings => const NotificationSettingsScreen(),
        _ => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text(
              appText(context, 'الصفحة غير موجودة', 'Page unavailable'),
            ),
          ),
        ),
      },
    );
  }
}

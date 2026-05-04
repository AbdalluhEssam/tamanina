import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/constants/app_constants.dart';
import 'core/cubit/locale/locale_cubit.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/utils/app_shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/services/service_locator.dart' as di;
import 'core/services/notification_service.dart';
import 'core/services/app_update_service.dart';
import 'core/services/prayer_service.dart';
import 'core/services/location_service.dart';
import 'core/services/prayer_notification_service.dart';
import 'core/settings/settings_repository.dart';
import 'core/settings/settings_cubit.dart';
import 'core/services/prayer_service_enhanced.dart' as enhanced_prayer;
import 'core/services/notification_service_enhanced.dart'
    as enhanced_notification;
import 'features/splash/ui/cubit/splash_cubit.dart';
import 'features/onboarding/ui/cubit/onboarding_cubit.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

/// Global settings repository instance
late final SettingsRepository settingsRepository;

/// Global enhanced services
late final enhanced_prayer.PrayerServiceEnhanced prayerServiceEnhanced;
late final enhanced_notification.NotificationServiceEnhanced
    notificationServiceEnhanced;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('prayer_settings');
  await Hive.openBox('bookmarks');
  await Hive.openBox('app_settings'); // Settings box

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timezone database for scheduled notifications
  tz.initializeTimeZones();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Settings Repository (MUST be initialized before services)
  settingsRepository = SettingsRepository();
  await settingsRepository.initialize();

  // Initialize Notifications
  await NotificationService().initialize();

  // Initialize Enhanced Notification Service
  notificationServiceEnhanced =
      enhanced_notification.NotificationServiceEnhanced();
  await notificationServiceEnhanced.initialize();

  // Initialize Prayer Services
  await PrayerService().initialize();
  await LocationService().initialize();
  await PrayerNotificationService().initialize();

  // Initialize Enhanced Prayer Service with settings
  prayerServiceEnhanced = enhanced_prayer.PrayerServiceEnhanced();
  await prayerServiceEnhanced.initialize();
  prayerServiceEnhanced.attachSettingsRepository(settingsRepository);

  // Initialize App Update Service
  await AppUpdateService().initialize();

  // Schedule daily notification (9:00 AM)
  await NotificationService().scheduleDailyNotification(
    hour: 9,
    minute: 0,
    title: '🌞 صباح الخير!',
    body: 'لا تنسَ مراجعة تحديثاتك اليوم! 📱',
  );

  // Schedule periodic dhikr reminders (every 30 minutes)
  await NotificationService().schedulePeriodicDhikrReminders();

  // Initialize Dependency Injection
  await di.init();

  // Register global services in GetIt for dependency injection
  if (!di.sl.isRegistered<SettingsRepository>()) {
    di.sl.registerSingleton<SettingsRepository>(settingsRepository);
  }
  if (!di.sl.isRegistered<enhanced_prayer.PrayerServiceEnhanced>()) {
    di.sl.registerSingleton<enhanced_prayer.PrayerServiceEnhanced>(
        prayerServiceEnhanced);
  }
  if (!di.sl
      .isRegistered<enhanced_notification.NotificationServiceEnhanced>()) {
    di.sl.registerSingleton<enhanced_notification.NotificationServiceEnhanced>(
        notificationServiceEnhanced);
  }

  Bloc.observer = AppBlocObserver();
  await AppPreferences().init();

  // Get SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(EasyLocalization(
    supportedLocales: AppConstants.supportedLocales,
    path: 'assets/lang',
    fallbackLocale: const Locale('ar'),
    saveLocale: true,
    startLocale: const Locale('ar'),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(
            create: (_) => ThemeCubit(settingsRepository: settingsRepository)),
        BlocProvider(
            create: (_) => SettingsCubit(repository: settingsRepository)),
        BlocProvider(create: (_) => di.sl<SplashCubit>()),
        BlocProvider(create: (_) => di.sl<OnboardingCubit>()),
      ],
      child: MyApp(appRouter: AppRouter(sharedPreferences)),
    ),
  ));
}

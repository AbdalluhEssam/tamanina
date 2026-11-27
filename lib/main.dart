import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import 'app.dart';
import 'features/quran/data/services/mushaf_pages.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/locale/locale_cubit.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/services/home_widgets_service.dart';
import 'core/services/worship_shortcuts.dart';
import 'core/services/notification_service.dart'
    show firebaseMessagingBackgroundHandler;
import 'core/services/notification_service_enhanced.dart';
import 'core/services/prayer_service_enhanced.dart';
import 'core/services/service_locator.dart' as di;
import 'core/settings/settings_cubit.dart';
import 'core/settings/settings_repository.dart';
import 'core/utils/app_shared_preferences.dart';
import 'features/onboarding/ui/cubit/onboarding_cubit.dart';
import 'features/splash/ui/cubit/splash_cubit.dart';
import 'firebase_options.dart';

late final SettingsRepository settingsRepository;
late final PrayerServiceEnhanced prayerServiceEnhanced;
late final NotificationServiceEnhanced notificationServiceEnhanced;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    initializeDateFormatting('ar'),
    _openLocalStorage(),
    AppPreferences().init(),
    di.init(),
  ]);

  final preferences = di.sl<SharedPreferences>();
  final hadSettings = Hive.box('app_settings').isNotEmpty;
  settingsRepository = SettingsRepository();
  await settingsRepository.initialize();
  // Keep a manually selected city from builds that wrote to preferences.
  if (!hadSettings &&
      preferences.getBool('prayer_use_manual_location') == true) {
    final lat = preferences.getDouble('prayer_manual_lat');
    final lng = preferences.getDouble('prayer_manual_lng');
    if (lat != null && lng != null) {
      await settingsRepository.updateLocationSettings(
        LocationSettings(
          useAutoLocation: false,
          manualLatitude: lat,
          manualLongitude: lng,
          cityName: preferences.getString('prayer_manual_city'),
          countryName: preferences.getString('prayer_manual_country'),
        ),
      );
    }
  }
  tz_data.initializeTimeZones();
  prayerServiceEnhanced = PrayerServiceEnhanced();
  await Future.wait([
    prayerServiceEnhanced.refreshDeviceTimeZone(),
    prayerServiceEnhanced.initialize(settingsRepository: settingsRepository),
  ]);
  notificationServiceEnhanced = NotificationServiceEnhanced();
  di.sl.registerSingleton(settingsRepository);
  di.sl.registerSingleton(prayerServiceEnhanced);
  di.sl.registerSingleton(notificationServiceEnhanced);
  final widgetsService = HomeWidgetsService(prayerServiceEnhanced);
  di.sl.registerSingleton(widgetsService);
  final tasbeehProgress = preferences.getStringList(
    AppConstants.prefKeyTasbeehProgress,
  );
  widgetsService.publishTasbeeh(
    tasbeehProgress?.length == 3 ? int.tryParse(tasbeehProgress![1]) ?? 0 : 0,
  );
  WorshipShortcuts.instance.start();

  runApp(
    EasyLocalization(
      supportedLocales: AppConstants.supportedLocales,
      path: 'assets/lang',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      startLocale: const Locale('ar'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocaleCubit()),
          BlocProvider(
            create: (_) => ThemeCubit(settingsRepository: settingsRepository),
          ),
          BlocProvider(
            create: (_) => SettingsCubit(repository: settingsRepository),
          ),
          BlocProvider(create: (_) => di.sl<SplashCubit>()),
          BlocProvider(create: (_) => di.sl<OnboardingCubit>()),
        ],
        child: MyApp(appRouter: AppRouter(preferences)),
      ),
    ),
  );

  unawaited(
    notificationServiceEnhanced
        .initialize(settingsRepository: settingsRepository)
        .catchError(
          (Object error) => debugPrint(
            'Local notifications unavailable: ${error.runtimeType}',
          ),
        ),
  );
  unawaited(MushafPages.instance.init().catchError((Object _) {}));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeOnlineServices());
  });
}

Future<void> _openLocalStorage() async {
  await Hive.initFlutter();
  await Future.wait([Hive.openBox('app_settings'), Hive.openBox('statistics')]);
}

Future<void> _initializeOnlineServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await notificationServiceEnhanced.connectPushNotifications();
  } catch (error) {
    debugPrint('Optional online services unavailable: ${error.runtimeType}');
  }
}

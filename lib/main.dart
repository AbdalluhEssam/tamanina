import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/locale/locale_cubit.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/utils/app_shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/services/service_locator.dart' as di;
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize Notifications
  // await NotificationService.initialize();

  // Initialize Dependency Injection
  await di.init();

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
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => di.sl<SplashCubit>()),
        BlocProvider(create: (_) => di.sl<OnboardingCubit>()),
      ],
      child: MyApp(appRouter: AppRouter(sharedPreferences)),
    ),
  ));
}

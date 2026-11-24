import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_constants.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/services/navigation_service.dart';
import 'core/settings/settings_cubit.dart';
import 'core/theme/app_theme.dart';

class TamaninaApp extends StatelessWidget {
  const TamaninaApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    enableScaleWH: () {
      final view = View.of(context);
      final size = view.physicalSize / view.devicePixelRatio;
      return size.width < 440 && size.height > 600;
    },
    enableScaleText: () => false,
    builder: (context, _) => BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, theme) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final arabic = context.locale.languageCode == 'ar';
          final font = arabic && settings is SettingsLoaded
              ? settings.settings.arabicFont.fontFamily
              : arabic
              ? 'Cairo'
              : 'System';
          return MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: arabic ? AppConstants.appName : AppConstants.appNameEnglish,
            theme: AppTheme.lightThemeWithFont(font),
            darkTheme: AppTheme.darkThemeWithFont(font),
            themeMode: theme.themeMode,
            locale: context.locale,
            supportedLocales: AppConstants.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            onGenerateRoute: appRouter.generateRoute,
            initialRoute: AppRoutes.splash,
          );
        },
      ),
    ),
  );
}

class MyApp extends TamaninaApp {
  const MyApp({super.key, required super.appRouter});
}

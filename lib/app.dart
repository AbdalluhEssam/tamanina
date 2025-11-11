import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/services/navigation_service.dart';
import 'core/services/app_update_service.dart';

/// تطبيق طمأنينة الرئيسي
/// Main Tamanina App Widget
class TamaninaApp extends StatefulWidget {
  final AppRouter appRouter;

  const TamaninaApp({super.key, required this.appRouter});

  @override
  State<TamaninaApp> createState() => _TamaninaAppState();
}

class _TamaninaAppState extends State<TamaninaApp> {
  @override
  void initState() {
    super.initState();
    // Check for app updates after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    // Wait a bit for the app to fully load
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && NavigationService.navigatorKey.currentContext != null) {
      await AppUpdateService()
          .checkForUpdates(NavigationService.navigatorKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) => MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,

            // استخدام الألوان والسمات الجديدة
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _getThemeMode(themeState),

            // الترجمة والتعريب
            locale: context.locale,
            supportedLocales: AppConstants.supportedLocales,
            localizationsDelegates: context.localizationDelegates,

            // التوجيه والمسارات
            onGenerateRoute: widget.appRouter.generateRoute,
            initialRoute: AppRoutes.splash,

            // إعدادات إضافية للتطبيق
            builder: (context, widget) {
              // ضمان التدرج المناسب للنص على جميع الأجهزة
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                  ),
                ),
                child: Directionality(
                  // دعم الكتابة من اليمين لليسار للعربية
                  textDirection: _getTextDirection(context),
                  child: widget!,
                ),
              );
            },

            // إعدادات الأداء
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
          ),
        );
      },
    );
  }

  /// تحديد وضع السمة بناءً على حالة ThemeCubit
  ThemeMode _getThemeMode(ThemeState themeState) {
    // يمكن تخصيص هذا لاحقاً بناءً على حالة الـ Cubit الفعلية
    return AppTheme.getSystemThemeMode();
  }

  /// تحديد اتجاه النص بناءً على اللغة
  ui.TextDirection _getTextDirection(BuildContext context) {
    final locale = context.locale;
    return locale.languageCode == 'ar'
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
  }
}

// الاحتفاظ بـ MyApp للتوافق مع الكود الموجود
class MyApp extends TamaninaApp {
  const MyApp({super.key, required super.appRouter});
}

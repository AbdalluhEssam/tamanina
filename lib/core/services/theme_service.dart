import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class AppThemeService {
  // 🌓 الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme(
        primary: AppColors.primaryGreen,
        secondary: AppColors.goldAccent,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textOnSurface,
        onError: AppColors.textOnPrimary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      textTheme: TextTheme(
        displayLarge: textStyle(24.sp, FontWeight.bold, AppColors.textPrimary),
        displayMedium: textStyle(20.sp, FontWeight.bold, AppColors.textPrimary),
        displaySmall: textStyle(18.sp, FontWeight.w600, AppColors.textPrimary),
        headlineMedium:
            textStyle(16.sp, FontWeight.bold, AppColors.textPrimary),
        bodyLarge: textStyle(14.sp, FontWeight.normal, AppColors.textPrimary),
        bodyMedium: textStyle(12.sp, FontWeight.normal, AppColors.textPrimary),
      ),
      cardColor: AppColors.surfaceLight,
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textOnPrimary,
          backgroundColor: AppColors.primaryGreen,
          textStyle: textStyle(16, FontWeight.bold, AppColors.textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }

  // 🌙 الوضع الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        iconTheme: IconThemeData(color: AppColors.textOnSurfaceDark),
        titleTextStyle: TextStyle(
          color: AppColors.textOnSurfaceDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      textTheme: TextTheme(
        displayLarge:
            textStyle(24.sp, FontWeight.bold, AppColors.textOnSurfaceDark),
        displayMedium:
            textStyle(20.sp, FontWeight.bold, AppColors.textOnSurfaceDark),
        displaySmall:
            textStyle(18.sp, FontWeight.w600, AppColors.textOnSurfaceDark),
        headlineMedium:
            textStyle(16.sp, FontWeight.bold, AppColors.textOnSurfaceDark),
        bodyLarge:
            textStyle(14.sp, FontWeight.normal, AppColors.textOnSurfaceDark),
        bodyMedium:
            textStyle(12.sp, FontWeight.normal, AppColors.textOnSurfaceDark),
      ),
      cardColor: AppColors.surfaceDark,
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textOnPrimary,
          backgroundColor: AppColors.primaryGreen,
          textStyle: textStyle(16, FontWeight.bold, AppColors.textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textOnSurfaceDark),
    );
  }

  // 🎨 دالة لإنشاء TextStyle بسهولة
  static TextStyle textStyle(double size, FontWeight weight, Color color) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';
import 'light_theme.dart';

/// Builds the dark counterpart while preserving typography and spacing.
ThemeData buildDarkTheme() {
  final base = buildLightTheme();
  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryGreenLight,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.goldLight,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textOnSurfaceDark,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      outline: AppColors.dividerDark,
      surfaceContainerHighest: AppColors.surfaceDark,
      onSurfaceVariant: AppColors.textOnSurfaceDark.withOpacity(0.7),
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textOnSurfaceDark,
      titleTextStyle: AppTypography.appBarTitle.copyWith(
        color: AppColors.textOnSurfaceDark,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textOnSurfaceDark,
        size: AppSizing.iconMD,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: base.cardTheme.copyWith(
      color: AppColors.surfaceDark,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: AppColors.surfaceDark.withOpacity(0.8),
      hintStyle: AppTypography.bodyMediumArabic.copyWith(
        color: AppColors.textOnSurfaceDark.withOpacity(0.7),
      ),
      labelStyle: AppTypography.bodyMediumArabic.copyWith(
        color: AppColors.textOnSurfaceDark.withOpacity(0.7),
      ),
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryGreenLight,
      unselectedItemColor: AppColors.textOnSurfaceDark.withOpacity(0.6),
    ),
    iconTheme: IconThemeData(
      color: AppColors.textOnSurfaceDark,
      size: AppSizing.iconMD,
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: AppColors.dividerDark,
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: AppTypography.h4Arabic.copyWith(
        color: AppColors.textOnSurfaceDark,
      ),
      contentTextStyle: AppTypography.bodyLargeArabic.copyWith(
        color: AppColors.textOnSurfaceDark,
      ),
    ),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: AppColors.surfaceDark,
    ),
    listTileTheme: base.listTileTheme.copyWith(
      iconColor: AppColors.textOnSurfaceDark,
      textColor: AppColors.textOnSurfaceDark,
      selectedTileColor: AppColors.primaryGreenWithOpacity(0.2),
    ),
  );
}

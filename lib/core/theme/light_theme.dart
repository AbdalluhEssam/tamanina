import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// Builds the light color scheme used across the application.
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.primaryBlue,
      onSecondary: AppColors.textOnPrimary,
      tertiary: AppColors.goldAccent,
      onTertiary: AppColors.textPrimary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textOnSurface,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      outline: AppColors.divider,
      surfaceContainerHighest: AppColors.creamAccent,
      onSurfaceVariant: AppColors.textSecondary,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: AppBarTheme(
      elevation: AppElevation.level0,
      centerTitle: true,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.textOnPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.appBarTitle,
      toolbarHeight: AppSizing.appBarHeight,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textOnPrimary,
        size: AppSizing.iconMD,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: AppSizing.cardElevation,
      color: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      margin: AppSpacing.paddingMD,
      clipBehavior: Clip.hardEdge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppElevation.level2,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        padding: AppSpacing.paddingVerticalMD.copyWith(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
        ),
        minimumSize:
            Size(AppSizing.buttonMinWidth, AppSizing.buttonHeightMedium),
        textStyle: AppTypography.buttonTextMedium,
        animationDuration: AppDuration.buttonAnimation,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        padding: AppSpacing.paddingVerticalMD.copyWith(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
        ),
        minimumSize:
            Size(AppSizing.buttonMinWidth, AppSizing.buttonHeightMedium),
        textStyle: AppTypography.buttonTextMedium
            .copyWith(color: AppColors.primaryGreen),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: AppTypography.buttonTextMedium
            .copyWith(color: AppColors.primaryGreen),
        padding: AppSpacing.paddingMD,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: AppElevation.level2,
      focusElevation: AppElevation.level5,
      hoverElevation: AppElevation.level5,
      highlightElevation: AppElevation.level5,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.textOnPrimary,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      sizeConstraints: BoxConstraints.tightFor(
        width: AppSizing.fabSize,
        height: AppSizing.fabSize,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.creamAccent.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: AppSpacing.paddingMD,
      hintStyle: AppTypography.bodyMediumArabic.copyWith(
        color: AppColors.textSecondary,
      ),
      labelStyle: AppTypography.bodyMediumArabic.copyWith(
        color: AppColors.textSecondary,
      ),
      helperStyle: AppTypography.captionArabic,
      errorStyle: AppTypography.captionArabic.copyWith(color: AppColors.error),
    ),
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: AppSizing.iconMD,
    ),
    primaryIconTheme: IconThemeData(
      color: AppColors.textOnPrimary,
      size: AppSizing.iconMD,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: AppSizing.dividerThickness,
      indent: AppSizing.dividerIndent,
      endIndent: AppSizing.dividerIndent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: AppElevation.level3,
      selectedLabelStyle: AppTypography.navigationText.copyWith(
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.navigationText.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: AppElevation.level7,
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      titleTextStyle: AppTypography.h4Arabic,
      contentTextStyle: AppTypography.bodyLargeArabic,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: AppElevation.level9,
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      constraints: BoxConstraints(
        maxWidth: AppSizing.screenWidth(),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.creamAccent,
      selectedColor: AppColors.primaryGreen,
      disabledColor: AppColors.textSecondary.withValues(alpha: 0.1),
      labelStyle: AppTypography.bodyMediumArabic,
      secondaryLabelStyle: AppTypography.bodyMediumArabic.onPrimary,
      padding: AppSpacing.paddingMD,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      elevation: AppElevation.level1,
      pressElevation: AppElevation.level2,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: AppSpacing.paddingMD,
      iconColor: AppColors.textPrimary,
      textColor: AppColors.textPrimary,
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.creamAccent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryGreen,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.tabBarText.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.tabBarText,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 3),
        insets: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGreen,
      linearTrackColor: AppColors.divider,
      circularTrackColor: AppColors.divider,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryGreen,
      inactiveTrackColor: AppColors.divider,
      thumbColor: AppColors.primaryGreen,
      overlayColor: AppColors.primaryGreenWithOpacity(0.2),
      valueIndicatorColor: AppColors.primaryGreen,
      valueIndicatorTextStyle: AppTypography.captionArabic.onPrimary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreenWithOpacity(0.5);
        }
        return AppColors.divider;
      }),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.h1Arabic,
      displayMedium: AppTypography.h2Arabic,
      displaySmall: AppTypography.h3Arabic,
      headlineLarge: AppTypography.h3Arabic,
      headlineMedium: AppTypography.h4Arabic,
      headlineSmall: AppTypography.h5Arabic,
      titleLarge: AppTypography.h5Arabic,
      titleMedium: AppTypography.h6Arabic,
      titleSmall:
          AppTypography.bodyLargeArabic.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: AppTypography.bodyLargeArabic,
      bodyMedium: AppTypography.bodyMediumArabic,
      bodySmall: AppTypography.bodySmallArabic,
      labelLarge: AppTypography.labelLargeArabic,
      labelMedium: AppTypography.labelMediumArabic,
      labelSmall: AppTypography.labelSmallArabic,
    ),
  );
}

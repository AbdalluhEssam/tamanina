import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

class AppTheme {
  // Primary app theme (Light Mode)
  static ThemeData get lightTheme => ThemeData(
        // Basic theme configuration
        useMaterial3: false,
        brightness: Brightness.light,

        // Color scheme - تحديث نظام الألوان الإسلامية الهادئة
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGreen, // الأخضر الإسلامي الأساسي
          onPrimary: AppColors.textOnPrimary,
          secondary: AppColors.primaryBlue, // الأزرق السماوي كلون ثانوي
          onSecondary: AppColors.textOnPrimary,
          tertiary: AppColors.goldAccent, // الذهبي كلون مساعد
          onTertiary: AppColors.textPrimary,
          surface: AppColors.surfaceLight, // الأبيض النقي
          onSurface: AppColors.textOnSurface,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          outline: AppColors.divider,
          surfaceContainerHighest: AppColors.creamAccent,
          onSurfaceVariant: AppColors.textSecondary,
        ),

        // Scaffold
        scaffoldBackgroundColor: AppColors.backgroundLight,

        // App Bar Theme
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

        // Card Theme
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

        // Elevated Button Theme
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

        // Outlined Button Theme
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

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            textStyle: AppTypography.buttonTextMedium
                .copyWith(color: AppColors.primaryGreen),
            padding: AppSpacing.paddingMD,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
        ),

        // Floating Action Button Theme
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

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.creamAccent.withOpacity(0.5),
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
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 2),
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
          errorStyle:
              AppTypography.captionArabic.copyWith(color: AppColors.error),
        ),

        // Icon Theme
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: AppSizing.iconMD,
        ),

        // Primary Icon Theme
        primaryIconTheme: IconThemeData(
          color: AppColors.textOnPrimary,
          size: AppSizing.iconMD,
        ),

        // Divider Theme
        dividerTheme: DividerThemeData(
          color: AppColors.divider,
          thickness: AppSizing.dividerThickness,
          indent: AppSizing.dividerIndent,
          endIndent: AppSizing.dividerIndent,
        ),

        // Bottom Navigation Bar Theme
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

        // Dialog Theme
        dialogTheme: DialogThemeData(
          elevation: AppElevation.level7,
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
          titleTextStyle: AppTypography.h4Arabic,
          contentTextStyle: AppTypography.bodyLargeArabic,
        ),

        // Bottom Sheet Theme
        bottomSheetTheme: BottomSheetThemeData(
          elevation: AppElevation.level9,
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
          constraints: BoxConstraints(
            maxWidth: AppSizing.screenWidth(),
          ),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.creamAccent,
          selectedColor: AppColors.primaryGreen,
          disabledColor: AppColors.textSecondary.withOpacity(0.1),
          labelStyle: AppTypography.bodyMediumArabic,
          secondaryLabelStyle: AppTypography.bodyMediumArabic.onPrimary,
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          elevation: AppElevation.level1,
          pressElevation: AppElevation.level2,
        ),

        // List Tile Theme
        listTileTheme: ListTileThemeData(
          contentPadding: AppSpacing.paddingMD,
          iconColor: AppColors.textPrimary,
          textColor: AppColors.textPrimary,
          tileColor: Colors.transparent,
          selectedTileColor: AppColors.creamAccent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),

        // Tab Bar Theme
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

        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryGreen,
          linearTrackColor: AppColors.divider,
          circularTrackColor: AppColors.divider,
        ),

        // Slider Theme
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primaryGreen,
          inactiveTrackColor: AppColors.divider,
          thumbColor: AppColors.primaryGreen,
          overlayColor: AppColors.primaryGreenWithOpacity(0.2),
          valueIndicatorColor: AppColors.primaryGreen,
          valueIndicatorTextStyle: AppTypography.captionArabic.onPrimary,
        ),

        // Switch Theme
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

        // Material 3 Typography (fallback)
        textTheme: TextTheme(
          displayLarge: AppTypography.h1Arabic,
          displayMedium: AppTypography.h2Arabic,
          displaySmall: AppTypography.h3Arabic,
          headlineLarge: AppTypography.h3Arabic,
          headlineMedium: AppTypography.h4Arabic,
          headlineSmall: AppTypography.h5Arabic,
          titleLarge: AppTypography.h5Arabic,
          titleMedium: AppTypography.h6Arabic,
          titleSmall: AppTypography.bodyLargeArabic
              .copyWith(fontWeight: FontWeight.w600),
          bodyLarge: AppTypography.bodyLargeArabic,
          bodyMedium: AppTypography.bodyMediumArabic,
          bodySmall: AppTypography.bodySmallArabic,
          labelLarge: AppTypography.labelLargeArabic,
          labelMedium: AppTypography.labelMediumArabic,
          labelSmall: AppTypography.labelSmallArabic,
        ),
      );

  // Dark theme
  static ThemeData get darkTheme => lightTheme.copyWith(
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

        // Dark App Bar
        appBarTheme: lightTheme.appBarTheme.copyWith(
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

        // Dark Cards
        cardTheme: lightTheme.cardTheme.copyWith(
          color: AppColors.surfaceDark,
        ),

        // Dark Input
        inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
          fillColor: AppColors.surfaceDark.withOpacity(0.8),
          hintStyle: AppTypography.bodyMediumArabic.copyWith(
            color: AppColors.textOnSurfaceDark.withOpacity(0.7),
          ),
          labelStyle: AppTypography.bodyMediumArabic.copyWith(
            color: AppColors.textOnSurfaceDark.withOpacity(0.7),
          ),
        ),

        // Dark Bottom Nav
        bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme.copyWith(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryGreenLight,
          unselectedItemColor: AppColors.textOnSurfaceDark.withOpacity(0.6),
        ),

        // Dark Icons
        iconTheme: IconThemeData(
          color: AppColors.textOnSurfaceDark,
          size: AppSizing.iconMD,
        ),

        // Dark Dividers
        dividerTheme: lightTheme.dividerTheme.copyWith(
          color: AppColors.dividerDark,
        ),

        // Dark Dialog
        dialogTheme: lightTheme.dialogTheme.copyWith(
          backgroundColor: AppColors.surfaceDark,
          titleTextStyle: AppTypography.h4Arabic.copyWith(
            color: AppColors.textOnSurfaceDark,
          ),
          contentTextStyle: AppTypography.bodyLargeArabic.copyWith(
            color: AppColors.textOnSurfaceDark,
          ),
        ),

        // Dark Bottom Sheet
        bottomSheetTheme: lightTheme.bottomSheetTheme.copyWith(
          backgroundColor: AppColors.surfaceDark,
        ),

        // Dark List Tiles
        listTileTheme: lightTheme.listTileTheme.copyWith(
          iconColor: AppColors.textOnSurfaceDark,
          textColor: AppColors.textOnSurfaceDark,
          selectedTileColor: AppColors.primaryGreenWithOpacity(0.2),
        ),
      );

  // System theme mode detection
  static ThemeMode getSystemThemeMode() {
    return ThemeMode.system;
  }

  /// إنشاء السمة الفاتحة مع خط مخصص
  /// Create light theme with custom font
  static ThemeData lightThemeWithFont(String? fontFamily) {
    if (fontFamily == null || fontFamily.isEmpty) {
      return lightTheme;
    }

    final baseTheme = lightTheme;
    return baseTheme.copyWith(
      textTheme: _applyFontToTextTheme(baseTheme.textTheme, fontFamily),
    );
  }

  /// إنشاء السمة الداكنة مع خط مخصص
  /// Create dark theme with custom font
  static ThemeData darkThemeWithFont(String? fontFamily) {
    if (fontFamily == null || fontFamily.isEmpty) {
      return darkTheme;
    }

    final baseTheme = darkTheme;
    return baseTheme.copyWith(
      textTheme: _applyFontToTextTheme(baseTheme.textTheme, fontFamily),
    );
  }

  /// تطبيق الخط على جميع أنماط النص
  /// Apply font to all text styles
  static TextTheme _applyFontToTextTheme(
      TextTheme textTheme, String fontFamily) {
    return TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(fontFamily: fontFamily),
      displayMedium: textTheme.displayMedium?.copyWith(fontFamily: fontFamily),
      displaySmall: textTheme.displaySmall?.copyWith(fontFamily: fontFamily),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontFamily: fontFamily),
      headlineMedium:
          textTheme.headlineMedium?.copyWith(fontFamily: fontFamily),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontFamily: fontFamily),
      titleLarge: textTheme.titleLarge?.copyWith(fontFamily: fontFamily),
      titleMedium: textTheme.titleMedium?.copyWith(fontFamily: fontFamily),
      titleSmall: textTheme.titleSmall?.copyWith(fontFamily: fontFamily),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontFamily: fontFamily),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
      bodySmall: textTheme.bodySmall?.copyWith(fontFamily: fontFamily),
      labelLarge: textTheme.labelLarge?.copyWith(fontFamily: fontFamily),
      labelMedium: textTheme.labelMedium?.copyWith(fontFamily: fontFamily),
      labelSmall: textTheme.labelSmall?.copyWith(fontFamily: fontFamily),
    );
  }
}

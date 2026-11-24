// Hallmark v2 · custom Flutter app · an open book under a mihrab
// The current reading position and prayer time carry the home screen.
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'app_colors.dart';

class AppTheme {
  static const _lightPrimary = Color(0xFF19283D);
  static const night = AppColors.backgroundDark;
  static const gold = AppColors.darkAccent;
  static const paper = Color(0xFFF6F4EF);
  static const ink = Color(0xFF20293A);
  static const lightBorder = Color(0xFFDAD8D0);

  // سمة المصحف الورقي الدافئ (ورق المصحف العثماني الكلاسيكي)
  static const creamPaper = Color(0xFFFAF6ED);
  static const creamSurface = Color(0xFFF3EDE0);
  static const creamInk = Color(0xFF22262E);
  static const creamGold = Color(0xFF8C642B);
  static const creamBorder = Color(0xFFDECFA8);

  static ThemeData lightThemeWithFont(String? font) =>
      _build(Brightness.light, font);
  static ThemeData darkThemeWithFont(String? font) =>
      _build(Brightness.dark, font);

  static ThemeData readingTheme(ThemeData appTheme, String preference) {
    if (appTheme.brightness == Brightness.dark) return appTheme;
    final font = appTheme.textTheme.bodyMedium?.fontFamily ?? 'System';
    return switch (preference) {
      'cream' => creamThemeWithFont(font),
      'dark' => darkThemeWithFont(font),
      _ => appTheme,
    };
  }

  static final _darkScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.surfaceDarkRaised,
        brightness: Brightness.dark,
      ).copyWith(
        primary: gold,
        onPrimary: AppColors.onDarkAccent,
        primaryContainer: AppColors.surfaceDarkRaised,
        onPrimaryContainer: AppColors.textOnSurfaceDark,
        secondary: gold,
        onSecondary: AppColors.onDarkAccent,
        secondaryContainer: const Color(0xFF473925),
        onSecondaryContainer: AppColors.textOnSurfaceDark,
        tertiary: AppColors.darkMuted,
        onTertiary: night,
        tertiaryContainer: AppColors.surfaceDarkRaised,
        onTertiaryContainer: AppColors.textOnSurfaceDark,
        surface: AppColors.surfaceDark,
        surfaceDim: night,
        surfaceBright: AppColors.surfaceDarkRaised,
        surfaceContainerLowest: night,
        surfaceContainerLow: AppColors.surfaceDark,
        surfaceContainer: AppColors.surfaceDark,
        surfaceContainerHigh: AppColors.surfaceDarkRaised,
        surfaceContainerHighest: AppColors.surfaceDarkRaised,
        onSurface: AppColors.textOnSurfaceDark,
        onSurfaceVariant: AppColors.darkMuted,
        outline: const Color(0xFF729084),
        outlineVariant: AppColors.dividerDark,
        inverseSurface: AppColors.textOnSurfaceDark,
        onInverseSurface: night,
        inversePrimary: AppColors.surfaceDarkRaised,
        surfaceTint: gold,
      );

  static ThemeData creamThemeWithFont(String? font) {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: creamGold,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEADBBE),
      onPrimaryContainer: creamInk,
      secondary: creamGold,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF2E7CD),
      onSecondaryContainer: Color(0xFF52390F),
      surface: creamSurface,
      onSurface: creamInk,
      onSurfaceVariant: Color(0xFF6B583E),
      outlineVariant: creamBorder,
      surfaceContainerHighest: Color(0xFFE8DFCC),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: creamBorder,
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: creamPaper,
      fontFamily: font == 'System' ? null : font ?? 'Cairo',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    return theme;
  }

  static ThemeData _build(Brightness brightness, String? font) {
    final dark = brightness == Brightness.dark;
    final scheme = dark
        ? _darkScheme
        : ColorScheme.fromSeed(seedColor: _lightPrimary).copyWith(
            primary: _lightPrimary,
            onPrimary: Colors.white,
            primaryContainer: const Color(0xFFE4EAF3),
            onPrimaryContainer: _lightPrimary,
            secondary: const Color(0xFF765523),
            secondaryContainer: const Color(0xFFF4E6CC),
            onSecondaryContainer: const Color(0xFF52390F),
            surface: Colors.white,
            onSurface: ink,
            onSurfaceVariant: const Color(0xFF586274),
            outlineVariant: lightBorder,
            surfaceContainerHighest: const Color(0xFFECECE7),
          );
    final background = dark ? night : paper;
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: font == 'System' ? null : font ?? 'Cairo',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headlineMedium: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        useIndicator: true,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

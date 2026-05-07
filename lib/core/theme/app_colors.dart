import 'package:flutter/material.dart';

/// تعريف الألوان الأساسية للتطبيق "طمأنينة" بالتصميم الإسلامي الهادئ
/// Islamic Soft Color Palette: Green + Sky Blue + White + Gold
class AppColors {
  // الألوان الأساسية - Primary Colors (Soft Islamic Style)

  // الأخضر الإسلامي الهادئ - Peaceful Islamic Green
  static const Color primaryGreen =
      Color(0xFF2E8B57); // Sea Green - لون هادئ ومريح
  static const Color primaryGreenLight = Color(0xFF90EE90); // Light Green
  static const Color primaryGreenDark = Color(0xFF006400); // Dark Green
  static const Color greenAccent = Color(0xFF98FB98); // Pale Green

  // الأزرق السماوي - Sky Blue (representing peace & tranquility)
  static const Color primaryBlue =
      Color(0xFF87CEEB); // Sky Blue - لون السماء الهادئ
  static const Color primaryBlueLight = Color(0xFFADD8E6); // Light Blue
  static const Color primaryBlueDark = Color(0xFF4682B4); // Steel Blue
  static const Color blueAccent = Color(0xFFB0E0E6); // Powder Blue

  // الذهبي الإسلامي - Islamic Gold (representing light & guidance)
  static const Color goldAccent = Color(0xFFDAA520); // Golden Rod - ذهبي دافئ
  static const Color goldLight = Color(0xFFFFFACD); // Lemon Chiffon
  static const Color goldDark = Color(0xFFB8860B); // Dark Golden Rod

  // الخلفيات البيضاء الدافئة - Warm White Backgrounds
  static const Color backgroundLight =
      Color(0xFFFFFFF8); // Warm White - أبيض دافئ
  static const Color backgroundDark =
      Color(0xFF1A1A1A); // Dark background for dark mode
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceDark = Color(0xFF2C3135); // Dark surface

  // الألوان المحايدة والكريمية - Neutral & Cream Colors
  static const Color creamAccent = Color(0xFFF5F5DC); // Beige - كريمي هادئ
  static const Color beigeAccent = Color(0xFFE6D7C3); // Soft beige
  static const Color lightBeige = Color(0xFFF8F8FF); // Ghost White - أبيض شبحي

  // Text Colors
  static const Color textPrimary =
      Color(0xFF2D2D2D); // Updated text primary per spec
  static const Color textSecondary =
      Color(0xFF707070); // Updated text secondary per spec
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray
  static const Color textOnPrimary =
      Color(0xFFFFFFFF); // White text on primary colors
  static const Color textOnSurface = Color(0xFF2C2C2C); // Dark text on surfaces
  static const Color textOnSurfaceDark =
      Color(0xFFE8E8E8); // Light text on dark surfaces

  // Status & Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color warning = Color(0xFFFF9800); // Orange for warnings
  static const Color error = Color(0xFFE57373); // Soft red for errors
  static const Color info = Color(0xFF42A5F5); // Blue for information

  // Prayer Time Colors (soft, calming variations)
  static const Color fajrColor = Color(0xFF7986CB); // Soft indigo (dawn)
  static const Color dhuhrColor = Color(0xFFFFB74D); // Warm yellow (noon sun)
  static const Color asrColor = Color(0xFFFFAB91); // Soft orange (afternoon)
  static const Color maghribColor =
      Color(0xFFFF8A65); // Warm orange-red (sunset)
  static const Color ishaColor = Color(0xFF9C27B0); // Deep purple (night)

  // Utility Colors
  static const Color divider = Color(0xFFE0E0E0); // Light divider
  static const Color dividerDark = Color(0xFF424242); // Dark divider
  static const Color shadow = Color(0x1A000000); // Soft shadow
  static const Color overlay = Color(0x33000000); // Modal overlay

  // Transparent variants for subtle effects
  static Color primaryGreenWithOpacity(double opacity) =>
      primaryGreen.withOpacity(opacity);
  static Color goldAccentWithOpacity(double opacity) =>
      goldAccent.withOpacity(opacity);
  static Color textPrimaryWithOpacity(double opacity) =>
      textPrimary.withOpacity(opacity);

  // الألوان التدرجية الجميلة - Beautiful Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryBlue], // أخضر إلى أزرق سماوي
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldAccent], // تدرج ذهبي
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [backgroundLight, creamAccent], // تدرج هادئ
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient islamicGradient = LinearGradient(
    colors: [primaryGreen, goldAccent, primaryBlue], // التدرج الإسلامي الكامل
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Splash Screen Gradients - Light Mode
  static const LinearGradient splashLightGradient = LinearGradient(
    colors: [
      Color(0xFF6B8E23), // أخضر زيتوني
      Color(0xFFDAA520), // ذهبي
      Color(0xFFFFFFF8), // أبيض دافئ
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  // Splash Screen Gradients - Dark Mode
  static const LinearGradient splashDarkGradient = LinearGradient(
    colors: [
      Color(0xFF000000), // أسود
      Color(0xFF4B0082), // بنفسجي غامق
      Color(0xFFDAA520), // ذهبي
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  // Legacy color support (for backward compatibility - will be phased out)
  @deprecated
  static const Color primaryColor = primaryGreen;
  @deprecated
  static const Color secondaryColor = primaryGreenDark;
  @deprecated
  static const Color accentColor = creamAccent;
  @deprecated
  static const Color backgroundColor = backgroundLight;
  @deprecated
  static const Color grayColor = textSecondary;
  @deprecated
  static const Color white = Colors.white;
  @deprecated
  static const Color black = Colors.black;
}

// Helper class for getting colors based on current brightness
class AdaptiveColors {
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textOnSurfaceDark
        : AppColors.textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textOnSurfaceDark.withOpacity(0.7)
        : AppColors.textSecondary;
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.dividerDark
        : AppColors.divider;
  }
}

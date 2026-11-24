import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Font families
  // Updated font families per redesign
  static const String arabicTitleFontFamily = 'Reem Kufi';
  static const String arabicBodyFontFamily =
      'Amiri'; // fallback to Scheherazade New if needed
  static const String englishTitleFontFamily = 'Poppins';
  static const String englishBodyFontFamily = 'Merriweather';

  // Base text styles with Google Fonts

  // Arabic Titles (Reem Kufi)
  static TextStyle get reemKufiBold => TextStyle(
    fontFamily: 'Reem Kufi',
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle get reemKufiSemiBold => TextStyle(
    fontFamily: 'Reem Kufi',
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle get reemKufiMedium => TextStyle(
    fontFamily: 'Reem Kufi',
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static TextStyle get reemKufiRegular => TextStyle(
    fontFamily: 'Reem Kufi',
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  // Arabic Body (Amiri)
  static TextStyle get amiriRegular => TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static TextStyle get amiriBold => TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle get amiriSemiBold => TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle get amiriLight => TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  // English Typography (Poppins)
  static TextStyle get poppinsBold => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get poppinsSemiBold => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get poppinsMedium => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get poppinsRegular => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get poppinsLight => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  // Headline styles (mixed usage based on content language)
  static TextStyle get h1Arabic =>
      reemKufiBold.copyWith(fontSize: 34, height: 1.2, letterSpacing: 0.5);
  static TextStyle get h2Arabic =>
      reemKufiBold.copyWith(fontSize: 30, height: 1.25, letterSpacing: 0.4);
  static TextStyle get h3Arabic =>
      reemKufiSemiBold.copyWith(fontSize: 24, height: 1.3);
  static TextStyle get h4Arabic =>
      reemKufiMedium.copyWith(fontSize: 20, height: 1.35);
  static TextStyle get h5Arabic =>
      reemKufiMedium.copyWith(fontSize: 18, height: 1.35);
  static TextStyle get h6Arabic =>
      reemKufiMedium.copyWith(fontSize: 16, height: 1.3);

  static TextStyle get h1English =>
      poppinsBold.copyWith(fontSize: 32, height: 1.2);
  static TextStyle get h2English =>
      poppinsBold.copyWith(fontSize: 28, height: 1.3);
  static TextStyle get h3English =>
      poppinsSemiBold.copyWith(fontSize: 24, height: 1.3);
  static TextStyle get h4English =>
      poppinsSemiBold.copyWith(fontSize: 20, height: 1.4);
  static TextStyle get h5English =>
      poppinsMedium.copyWith(fontSize: 18, height: 1.4);
  static TextStyle get h6English =>
      poppinsMedium.copyWith(fontSize: 16, height: 1.4);

  // Body text styles
  static TextStyle get bodyLargeArabic =>
      amiriRegular.copyWith(fontSize: 18, height: 1.7);
  static TextStyle get bodyMediumArabic =>
      amiriRegular.copyWith(fontSize: 16, height: 1.65);
  static TextStyle get bodySmallArabic =>
      amiriRegular.copyWith(fontSize: 14, height: 1.6);

  static TextStyle get bodyLargeEnglish =>
      poppinsRegular.copyWith(fontSize: 16, height: 1.6);
  static TextStyle get bodyMediumEnglish =>
      poppinsRegular.copyWith(fontSize: 14, height: 1.5);
  static TextStyle get bodySmallEnglish =>
      poppinsRegular.copyWith(fontSize: 12, height: 1.5);

  // Caption and label styles
  static TextStyle get captionArabic => amiriLight.copyWith(
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get captionEnglish => poppinsLight.copyWith(
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLargeArabic =>
      reemKufiMedium.copyWith(fontSize: 14, height: 1.4);
  static TextStyle get labelMediumArabic =>
      reemKufiMedium.copyWith(fontSize: 12, height: 1.4);
  static TextStyle get labelSmallArabic =>
      reemKufiMedium.copyWith(fontSize: 10, height: 1.4);

  static TextStyle get labelLargeEnglish =>
      poppinsMedium.copyWith(fontSize: 14, height: 1.4);
  static TextStyle get labelMediumEnglish =>
      poppinsMedium.copyWith(fontSize: 12, height: 1.4);
  static TextStyle get labelSmallEnglish =>
      poppinsMedium.copyWith(fontSize: 10, height: 1.4);

  // Special Islamic text styles
  static TextStyle get quranText => amiriBold.copyWith(
    fontSize: 18,
    height: 2.0,
    color: AppColors.primaryGreen,
    letterSpacing: 0.5,
  );

  static TextStyle get azkarText => amiriRegular.copyWith(
    fontSize: 16,
    height: 1.8,
    color: AppColors.textPrimary,
  );

  static TextStyle get prayerTimeText => reemKufiBold.copyWith(
    fontSize: 20,
    height: 1.2,
    color: AppColors.primaryGreen,
  );

  static TextStyle get bismillahText => amiriBold.copyWith(
    fontSize: 22,
    height: 1.5,
    color: AppColors.goldAccent,
  );

  // Button text styles
  static TextStyle get buttonTextLarge => poppinsSemiBold.copyWith(
    fontSize: 16,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonTextMedium => poppinsMedium.copyWith(
    fontSize: 14,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonTextSmall => poppinsMedium.copyWith(
    fontSize: 12,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );

  // App bar and navigation styles
  static TextStyle get appBarTitle => reemKufiSemiBold.copyWith(
    fontSize: 20,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get tabBarText =>
      poppinsMedium.copyWith(fontSize: 14, height: 1.2);

  static TextStyle get navigationText =>
      poppinsRegular.copyWith(fontSize: 12, height: 1.2);

  // Adaptive styles that choose font based on locale
  static TextStyle adaptiveHeadline1(Locale locale) {
    return locale.languageCode == 'ar' ? h1Arabic : h1English;
  }

  static TextStyle adaptiveHeadline2(Locale locale) {
    return locale.languageCode == 'ar' ? h2Arabic : h2English;
  }

  static TextStyle adaptiveHeadline3(Locale locale) {
    return locale.languageCode == 'ar' ? h3Arabic : h3English;
  }

  static TextStyle adaptiveBodyLarge(Locale locale) {
    return locale.languageCode == 'ar' ? bodyLargeArabic : bodyLargeEnglish;
  }

  static TextStyle adaptiveBodyMedium(Locale locale) {
    return locale.languageCode == 'ar' ? bodyMediumArabic : bodyMediumEnglish;
  }

  static TextStyle adaptiveCaption(Locale locale) {
    return locale.languageCode == 'ar' ? captionArabic : captionEnglish;
  }

  // Dark theme variants
  static TextStyle onDarkSurface(TextStyle style) {
    return style.copyWith(color: AppColors.textOnSurfaceDark);
  }

  static TextStyle onDarkSurfaceSecondary(TextStyle style) {
    return style.copyWith(
      color: AppColors.textOnSurfaceDark.withValues(alpha: 0.7),
    );
  }
}

// Extension to make it easier to apply typography
extension TextStyleExtensions on TextStyle {
  TextStyle get onPrimary => copyWith(color: AppColors.textOnPrimary);
  TextStyle get onSurface => copyWith(color: AppColors.textOnSurface);
  TextStyle get primary => copyWith(color: AppColors.primaryGreen);
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);
  TextStyle get accent => copyWith(color: AppColors.goldAccent);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get success => copyWith(color: AppColors.success);

  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withValues(alpha: opacity));
}

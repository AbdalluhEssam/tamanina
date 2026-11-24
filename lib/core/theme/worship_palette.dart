import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colors for the illustrated prayer and qibla surfaces.
abstract final class WorshipPalette {
  static const pine = AppColors.surfaceDarkRaised;
  static const deepPine = AppColors.surfaceDark;
  static const mist = Color(0xFFEDF5EF);
  static const paleSky = AppColors.darkMuted;
  static const warmGold = AppColors.darkAccent;
  static const ivory = AppColors.textOnSurfaceDark;

  static Color tint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? pine : mist;

  static Color onTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? ivory : pine;
}

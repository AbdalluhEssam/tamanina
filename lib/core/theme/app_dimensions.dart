import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App Design System - Spacing, Sizing, and Layout Constants
class AppSpacing {
  // Base spacing unit (8dp Material Design system)
  static const double baseUnit = 8.0;

  // Responsive spacing using ScreenUtil
  static double get xs => 4.h; // Extra small: 4dp
  static double get sm => 8.h; // Small: 8dp
  static double get md => 16.h; // Medium: 16dp
  static double get lg => 16.h; // Large: 24dp
  static double get xl => 32.h; // Extra large: 32dp
  static double get xxl => 40.h; // Extra extra large: 40dp
  static double get xxxl => 48.h; // Largest: 48dp

  // Specific spacing values
  static double get padding => md;
  static double get margin => md;
  static double get cardPadding => lg;
  static double get screenPadding => lg;
  static double get sectionPadding => xl;

  // Vertical spacing
  static SizedBox get verticalSpaceXS => SizedBox(height: xs);
  static SizedBox get verticalSpaceSM => SizedBox(height: sm);
  static SizedBox get verticalSpaceMD => SizedBox(height: md);
  static SizedBox get verticalSpaceLG => SizedBox(height: lg);
  static SizedBox get verticalSpaceXL => SizedBox(height: xl);
  static SizedBox get verticalSpaceXXL => SizedBox(height: xxl);

  // Horizontal spacing
  static SizedBox get horizontalSpaceXS => SizedBox(width: xs);
  static SizedBox get horizontalSpaceSM => SizedBox(width: sm);
  static SizedBox get horizontalSpaceMD => SizedBox(width: md);
  static SizedBox get horizontalSpaceLG => SizedBox(width: lg);
  static SizedBox get horizontalSpaceXL => SizedBox(width: xl);
  static SizedBox get horizontalSpaceXXL => SizedBox(width: xxl);

  // Edge insets
  static EdgeInsets get paddingXS => EdgeInsets.all(xs);
  static EdgeInsets get paddingSM => EdgeInsets.all(sm);
  static EdgeInsets get paddingMD => EdgeInsets.all(md);
  static EdgeInsets get paddingLG => EdgeInsets.all(lg);
  static EdgeInsets get paddingXL => EdgeInsets.all(xl);

  static EdgeInsets get paddingHorizontalSM =>
      EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get paddingHorizontalMD =>
      EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get paddingHorizontalLG =>
      EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get paddingHorizontalXL =>
      EdgeInsets.symmetric(horizontal: xl);

  static EdgeInsets get paddingVerticalSM => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get paddingVerticalMD => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get paddingVerticalLG => EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get paddingVerticalXL => EdgeInsets.symmetric(vertical: xl);

  // Screen-level padding
  static EdgeInsets get screenPaddingAll => EdgeInsets.all(screenPadding);
  static EdgeInsets get screenPaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: screenPadding);
  static EdgeInsets get screenPaddingVertical =>
      EdgeInsets.symmetric(vertical: screenPadding);

  // Card and container padding
  static EdgeInsets get cardPaddingAll => EdgeInsets.all(cardPadding);
  static EdgeInsets get cardPaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: cardPadding);
  static EdgeInsets get cardPaddingVertical =>
      EdgeInsets.symmetric(vertical: cardPadding);
}

/// App sizing system
class AppSizing {
  // Icon sizes
  static double get iconXS => 16.w;
  static double get iconSM => 20.w;
  static double get iconMD => 24.w;
  static double get iconLG => 32.w;
  static double get iconXL => 40.w;
  static double get iconXXL => 48.w;

  // Button dimensions
  static double get buttonHeightSmall => 36.h;
  static double get buttonHeightMedium => 48.h;
  static double get buttonHeightLarge => 56.h;

  static double get buttonMinWidth => 88.w;

  // Card dimensions
  static double get cardMinHeight => 120.h;
  static double get cardElevation => 2.0;
  static double get cardBorderRadius => 16.r;

  // Input field dimensions
  static double get inputHeight => 56.h;
  static double get inputBorderRadius => 12.r;

  // Avatar sizes
  static double get avatarSmall => 32.w;
  static double get avatarMedium => 48.w;
  static double get avatarLarge => 64.w;
  static double get avatarXLarge => 96.w;

  // App Bar
  static double get appBarHeight => 40.h;
  static double get appBarElevation => 0.0;

  // Bottom Navigation
  static double get bottomNavHeight => 60.h;
  static double get bottomNavIconSize => iconMD;

  // Floating Action Button
  static double get fabSize => 56.w;
  static double get fabMiniSize => 40.w;

  // Divider
  static double get dividerThickness => 1.0;
  static double get dividerIndent => 16.w;

  // Responsive breakpoints
  static bool get isMobile => 1.sw < 600;
  static bool get isTablet => 1.sw >= 600 && 1.sw < 1024;
  static bool get isDesktop => 1.sw >= 1024;

  // Screen-relative sizing
  static double screenWidth([double fraction = 1.0]) => fraction.sw;
  static double screenHeight([double fraction = 1.0]) => fraction.sh;

  // Prayer time card specific dimensions
  static double get prayerCardHeight => 80.h;
  static double get prayerCardWidth => 1.sw - (AppSpacing.screenPadding * 2);

  // Azkar card dimensions
  static double get azkarCardMinHeight => 100.h;
  static double get azkarCardPadding => AppSpacing.lg;

  // Islamic content specific
  static double get quranVerseSpacing => 20.h;
  static double get azkarItemSpacing => 16.h;
}

/// Border radius constants
class AppRadius {
  static BorderRadius get xs => BorderRadius.circular(4.r);
  static BorderRadius get sm => BorderRadius.circular(8.r);
  static BorderRadius get md => BorderRadius.circular(12.r);
  static BorderRadius get lg => BorderRadius.circular(16.r);
  static BorderRadius get xl => BorderRadius.circular(24.r);
  static BorderRadius get xxl => BorderRadius.circular(32.r);

  // Specific component radii
  static BorderRadius get button => md;
  static BorderRadius get card => lg;
  static BorderRadius get input => md;
  static BorderRadius get dialog => lg;
  static BorderRadius get bottomSheet =>
      BorderRadius.vertical(top: Radius.circular(24.r));

  // Circular radius
  static BorderRadius get circular => BorderRadius.circular(999.r);
}

/// Elevation levels for Material Design
class AppElevation {
  static const double level0 = 0.0; // No elevation
  static const double level1 = 1.0; // App bars, cards at rest
  static const double level2 = 2.0; // Cards when touched, FAB at rest
  static const double level3 = 3.0; // Navigation drawer
  static const double level4 = 4.0; // App bars when scrolling
  static const double level5 = 6.0; // FAB when touched
  static const double level6 = 8.0; // Navigation drawer when scrolling
  static const double level7 = 12.0; // Dialog, picker
  static const double level8 = 16.0; // Navigation drawer (modal)
  static const double level9 = 24.0; // Modal bottom sheet
}

/// Duration constants for animations
class AppDuration {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 1000);

  // Specific animation durations
  static const Duration pageTransition = normal;
  static const Duration modalAnimation = normal;
  static const Duration buttonAnimation = fast;
  static const Duration loadingAnimation = normal;
  static const Duration splashAnimation = slow;
}

/// Animation curves
class AppCurves {
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;

  // Custom curves for Islamic app feel
  static const Curve gentle = Curves.easeOutCubic;
  static const Curve calming = Curves.easeInOutCubic;
}

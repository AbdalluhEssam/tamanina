import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return navigator!.pop<T>(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    return navigator!.popUntil(predicate);
  }

  static bool canPop() {
    return navigator!.canPop();
  }

  // Feature-specific navigation helpers

  /// Navigate to Prayer Times screen
  /// التنقل إلى شاشة مواقيت الصلاة
  static Future<void> goToPrayerTimes() {
    return pushNamed(AppRoutes.prayerTimes);
  }

  /// Navigate to Home screen
  static Future<void> goToHome() {
    return pushNamed(AppRoutes.home);
  }

  /// Navigate to Settings screen
  static Future<void> goToSettings() {
    return pushNamed(AppRoutes.settings);
  }
}

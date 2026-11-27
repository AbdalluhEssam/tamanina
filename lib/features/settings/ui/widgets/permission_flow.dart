import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import '../../../../core/services/adhan_native_bridge.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/widgets/tamanina_ui.dart';

enum _Step { notifications, locationServices, location, fullScreen, battery }

/// Asks for every permission Tamanina needs, one at a time, explaining each.
///
/// It runs once per cold start and only for what is still missing, so a user
/// who skipped or refused something is asked again the next time the app opens.
/// A permission the system will no longer prompt for sends the user to Settings,
/// and the flow continues when they come back.
class PermissionFlow {
  PermissionFlow._();

  /// Tests switch the flow off so dialogs do not interrupt them.
  @visibleForTesting
  static bool enabled = true;

  static bool _ranThisLaunch = false;

  static bool get _android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> run(BuildContext context) async {
    if (!enabled || _ranThisLaunch) return;
    _ranThisLaunch = true;
    final native = const AdhanNativeBridge();
    // Never cover the adhan screen.
    if ((await native.status()).playing) return;
    for (final step in _Step.values) {
      if (!context.mounted) return;
      if (await _missing(step)) {
        if (!context.mounted) return;
        await _handle(context, step);
      }
    }
    if (sl.isRegistered<PrayerServiceEnhanced>()) {
      unawaited(
        sl<PrayerServiceEnhanced>().requestAutoLocation(
          promptForPermission: false,
        ),
      );
    }
  }

  // ── Status ───────────────────────────────────────────────────────────────

  static Future<bool> _missing(_Step step) async {
    try {
      switch (step) {
        case _Step.notifications:
          if (!sl.isRegistered<NotificationServiceEnhanced>()) return false;
          if (!sl<SettingsRepository>().currentSettings.notificationsEnabled) {
            return false;
          }
          return !await sl<NotificationServiceEnhanced>()
              .notificationsAllowed();
        case _Step.locationServices:
          if (_usesManualLocation) return false;
          return !await Geolocator.isLocationServiceEnabled();
        case _Step.location:
          if (_usesManualLocation) return false;
          final permission = await Geolocator.checkPermission();
          return permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever;
        case _Step.fullScreen:
          return _android &&
              !await const AdhanNativeBridge().canUseFullScreenIntent();
        case _Step.battery:
          if (!_android) return false;
          final data = await const AdhanNativeBridge().diagnostics();
          return data != null && data['batteryUnrestricted'] == false;
      }
    } catch (_) {
      return false;
    }
  }

  static bool get _usesManualLocation =>
      sl.isRegistered<SettingsRepository>() &&
      !sl<SettingsRepository>()
          .currentSettings
          .locationSettings
          .useAutoLocation;

  // ── Prompts ──────────────────────────────────────────────────────────────

  static Future<void> _handle(BuildContext context, _Step step) async {
    final text = _text(step);
    final go = await _ask(
      context,
      icon: text.icon,
      title: appText(context, text.titleAr, text.titleEn),
      body: appText(context, text.bodyAr, text.bodyEn),
      allow: appText(context, text.allowAr, text.allowEn),
    );
    if (go != true || !context.mounted) return;
    switch (step) {
      case _Step.notifications:
        final granted = await sl<NotificationServiceEnhanced>()
            .requestPermissions();
        if (!granted && context.mounted) await _settingsFallback(context, step);
      case _Step.locationServices:
        await Geolocator.openLocationSettings();
        await _waitForResume();
      case _Step.location:
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if ((permission == LocationPermission.denied ||
                permission == LocationPermission.deniedForever) &&
            context.mounted) {
          await _settingsFallback(context, step);
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          // Pick up the real position straight away so prayer times follow
          // where the user actually is.
          await LocationService().getCurrentLocation(forceRefresh: true);
          if (sl.isRegistered<PrayerServiceEnhanced>()) {
            sl<PrayerServiceEnhanced>().refreshLocation();
          }
        }
      case _Step.fullScreen:
        await const AdhanNativeBridge().openFullScreenIntentSettings();
        await _waitForResume();
      case _Step.battery:
        await const AdhanNativeBridge().openBatterySettings();
        await _waitForResume();
    }
  }

  /// The system will not show its own prompt again, so explain and open Settings.
  static Future<void> _settingsFallback(
    BuildContext context,
    _Step step,
  ) async {
    final text = _text(step);
    final open = await _ask(
      context,
      icon: text.icon,
      title: appText(context, text.titleAr, text.titleEn),
      body: appText(
        context,
        'تم رفض الإذن من النظام، فلا يمكنني طلبه مرة أخرى. افتح الإعدادات وفعّله من هناك.',
        'The system blocked the request, so it cannot be shown again. Open Settings and turn it on there.',
      ),
      allow: appText(context, 'فتح الإعدادات', 'Open Settings'),
    );
    if (open == true) {
      await openAppSettings();
      await _waitForResume();
    }
  }

  static Future<bool?> _ask(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    required String allow,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: Icon(icon, size: 32),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(body, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(appText(context, 'لاحقًا', 'Later')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(allow),
        ),
      ],
    ),
  );

  /// Waits for the app to come back to the foreground (for example after the
  /// user visits Settings), but never longer than a few minutes.
  static Future<void> _waitForResume() {
    final done = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onResume: () {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future
        .timeout(const Duration(minutes: 3), onTimeout: () {})
        .whenComplete(listener.dispose);
  }

  static _Text _text(_Step step) => switch (step) {
    _Step.notifications => const _Text(
      Icons.notifications_active_outlined,
      'الإشعارات والأذان',
      'Notifications and adhan',
      'لتنبيهك بوقت كل صلاة وتشغيل الأذان، وتذكيرك بالأذكار وصلاة الجمعة. بدونها لن يصلك أي تنبيه.',
      'To alert you at each prayer, play the adhan, and remind you of adhkar and Friday. Without it you will get no alerts.',
      'السماح بالإشعارات',
      'Allow notifications',
    ),
    _Step.locationServices => const _Text(
      Icons.location_off_outlined,
      'تشغيل خدمة الموقع',
      'Turn on location',
      'خدمة الموقع (GPS) مغلقة على جهازك. فعّلها ليحسب التطبيق مواقيت الصلاة والقبلة لمكانك الفعلي.',
      'Location (GPS) is off on your phone. Turn it on so Tamanina can work out prayer times and Qibla for where you really are.',
      'فتح إعدادات الموقع',
      'Open location settings',
    ),
    _Step.location => const _Text(
      Icons.location_on_outlined,
      'الموقع',
      'Location',
      'لحساب مواقيت الصلاة واتجاه القبلة بدقة لمدينتك وحيّك. يبقى موقعك على جهازك.',
      'To calculate accurate prayer times and Qibla for your city and area. Your location stays on your device.',
      'السماح بالموقع',
      'Allow location',
    ),
    _Step.fullScreen => const _Text(
      Icons.screen_lock_portrait_outlined,
      'الأذان على الشاشة المقفلة',
      'Adhan on the lock screen',
      'لتظهر شاشة الأذان كاملة عند دخول الوقت والهاتف مقفل.',
      'So the full adhan screen appears at prayer time while the phone is locked.',
      'فتح الإعداد',
      'Open setting',
    ),
    _Step.battery => const _Text(
      Icons.battery_charging_full_outlined,
      'عدم تقييد البطارية',
      'Do not restrict battery',
      'بعض الأجهزة توقف التطبيقات في الخلفية فيتأخر الأذان أو يتوقف. اسمح لطمأنينة بالعمل بلا قيود.',
      'Some phones stop apps in the background, which can delay or cut the adhan. Let Tamanina run without limits.',
      'فتح إعدادات البطارية',
      'Open battery settings',
    ),
  };
}

class _Text {
  const _Text(
    this.icon,
    this.titleAr,
    this.titleEn,
    this.bodyAr,
    this.bodyEn,
    this.allowAr,
    this.allowEn,
  );

  final IconData icon;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String allowAr;
  final String allowEn;
}

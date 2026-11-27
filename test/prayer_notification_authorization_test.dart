import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/core/services/notification_service_enhanced.dart';
import 'package:tamanina/core/services/prayer_service_enhanced.dart';
import 'package:tamanina/core/settings/settings_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'prayer alerts respect iOS authorization and resume when allowed',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tz.initializeTimeZones();
      await initializeDateFormatting('ar');
      // This test is about prayer alerts, so keep the reminders (on by default)
      // out of the 64 pending-notification slots.
      SharedPreferences.setMockInitialValues({
        'morning_adhkar_reminder': false,
        'evening_adhkar_reminder': false,
        'sleep_adhkar_reminder': false,
        'friday_reminder': false,
      });
      final directory = await Directory.systemTemp.createTemp(
        'prayer_permissions',
      );
      Hive.init(directory.path);
      await Hive.openBox('app_settings');
      addTearDown(() async {
        await Hive.close();
        await directory.delete(recursive: true);
      });
      final settings = SettingsRepository();
      await settings.initialize();
      await settings.updateLocationSettings(
        const LocationSettings(
          useAutoLocation: false,
          cityName: 'Cairo',
          countryName: 'EG',
          manualLatitude: 30.0444,
          manualLongitude: 31.2357,
        ),
      );
      await PrayerServiceEnhanced().initialize(settingsRepository: settings);

      var authorized = false;
      var allowPrompt = false;
      var revokeOnSchedule = false;
      final attempts = <int>[];
      var savedQueue = <Map<String, dynamic>>[];
      const prayerQueue = MethodChannel('com.abdalluh.tamanina/prayer_queue');
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        switch (call.method) {
          case 'initialize':
            return true;
          case 'checkPermissions':
            return {'isEnabled': authorized};
          case 'requestPermissions':
            if (allowPrompt) authorized = true;
            return authorized;
          case 'getNotificationAppLaunchDetails':
            return null;
          case 'pendingNotificationRequests':
            return <Object>[];
          case 'cancel':
            return null;
          case 'zonedSchedule':
            attempts.add((call.arguments as Map)['id'] as int);
            if (revokeOnSchedule) {
              authorized = false;
              throw PlatformException(
                code: 'Error 2003',
                details: 'UNErrorDomain',
              );
            }
            return null;
          default:
            throw StateError('Unexpected notification call: ${call.method}');
        }
      });
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );

      final notifications = NotificationServiceEnhanced();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(prayerQueue, (
        call,
      ) async {
        expect(call.method, 'replace');
        savedQueue = (jsonDecode(call.arguments as String) as List)
            .cast<Map<String, dynamic>>();
        return null;
      });
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          prayerQueue,
          null,
        ),
      );
      await notifications.initialize(settingsRepository: settings);
      await notifications.refresh();
      expect(attempts, isEmpty);
      expect(await notifications.requestPermissions(), isFalse);
      expect(attempts, isEmpty);

      allowPrompt = true;
      expect(await notifications.requestPermissions(), isTrue);
      await notifications.refresh();
      expect(attempts, isNotEmpty);
      expect(attempts.length, lessThanOrEqualTo(64));
      expect(attempts.every((id) => id >= 20000 && id < 20360), isTrue);
      expect(attempts.toSet(), hasLength(attempts.length));
      expect(savedQueue.length, greaterThan(64));
      expect(
        savedQueue.take(64).map((alert) => alert['id']),
        orderedEquals(attempts),
      );

      attempts.clear();
      revokeOnSchedule = true;
      await notifications.refresh();
      expect(attempts, hasLength(1));

      attempts.clear();
      await notifications.refreshOnResume();
      expect(attempts, isEmpty);
      revokeOnSchedule = false;
      authorized = true;
      await notifications.refreshOnResume();
      expect(attempts, isNotEmpty);

      await settings.updateNotificationsEnabled(false);
      await notifications.refresh();
      expect(savedQueue, isEmpty);
    },
  );
}

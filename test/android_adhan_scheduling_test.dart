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
    'Android keeps full adhan and notification fallback mutually exclusive',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tz.initializeTimeZones();
      await initializeDateFormatting('ar');
      SharedPreferences.setMockInitialValues({'morning_adhkar_reminder': true});
      final directory = await Directory.systemTemp.createTemp('android_adhan');
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

      final messenger = binding.defaultBinaryMessenger;
      const notificationsChannel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      const alarmsChannel = MethodChannel('com.abdalluh.tamanina/adhan_alarms');
      var exact = true;
      var native = <Map<String, dynamic>>[];
      final local = <int, Map<Object?, Object?>>{};
      var writes = 0;
      messenger.setMockMethodCallHandler(alarmsChannel, (call) async {
        expect(call.method, 'replace');
        native = (jsonDecode(call.arguments as String) as List)
            .cast<Map<String, dynamic>>();
        return native.map((alert) => alert['id'] as int).toList();
      });
      messenger.setMockMethodCallHandler(notificationsChannel, (call) async {
        switch (call.method) {
          case 'initialize':
          case 'areNotificationsEnabled':
            return true;
          case 'canScheduleExactNotifications':
            return exact;
          case 'getNotificationAppLaunchDetails':
            return null;
          case 'pendingNotificationRequests':
            return local.values
                .map(
                  (alert) => {
                    'id': alert['id'],
                    'title': alert['title'],
                    'body': alert['body'],
                    'payload': alert['payload'],
                  },
                )
                .toList();
          case 'zonedSchedule':
            final alert = call.arguments as Map<Object?, Object?>;
            local[alert['id'] as int] = alert;
            writes++;
            return null;
          case 'cancel':
            local.remove((call.arguments as Map)['id']);
            return null;
          default:
            throw StateError('Unexpected notification method ${call.method}');
        }
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(notificationsChannel, null);
        messenger.setMockMethodCallHandler(alarmsChannel, null);
      });

      final notifications = NotificationServiceEnhanced();
      await notifications.initialize(settingsRepository: settings);
      await notifications.refresh();
      final adhanIds = native.map((alert) => alert['id'] as int).toSet();
      expect(adhanIds.length, greaterThan(100));
      expect(adhanIds.intersection(local.keys.toSet()), isEmpty);
      expect(local[21000]?['payload'], '/azkar/morning');
      final initialWrites = writes;
      await notifications.refresh();
      expect(writes, initialWrites);

      exact = false;
      await notifications.refreshOnResume();
      expect(native, isEmpty);
      expect(local.keys, containsAll(adhanIds));
      expect(local[adhanIds.first]?['payload'], startsWith('/adhan?'));

      await settings.updateNotificationsEnabled(false);
      await notifications.refresh();
      expect(native, isEmpty);
      expect(local, isEmpty);
    },
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/core/audio/audio_catalog.dart';
import 'package:tamanina/core/audio/audio_library.dart';
import 'package:tamanina/core/services/notification_service_enhanced.dart';
import 'package:tamanina/core/services/prayer_service_enhanced.dart';
import 'package:tamanina/core/settings/settings_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Android alarms carry the chosen voice file and fall back without it',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tz.initializeTimeZones();
      await initializeDateFormatting('ar');
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp('adhan_voice');
      Hive.init(directory.path);
      await Hive.openBox('app_settings');

      // A downloaded voice with separate Fajr and regular recordings.
      final main = utf8.encode('regular adhan');
      final fajr = utf8.encode('fajr adhan!');
      AdhanFile file(List<int> bytes, String path) => AdhanFile(
        url: Uri.parse('https://example.com$path'),
        sha256: sha256.convert(bytes).toString(),
        bytes: bytes.length,
        durationMs: 1000,
      );
      final voice = AdhanVoice(
        id: 'testvoice',
        nameAr: 'تجربة',
        nameEn: 'Test',
        main: file(main, '/main.mp3'),
        fajr: file(fajr, '/fajr.mp3'),
      );
      debugCatalog = AudioCatalog(
        reciters: builtInReciters,
        adhanVoices: [AdhanVoice.bundled, voice],
      );
      AudioLibrary.debugInstance = AudioLibrary(
        support: Directory('${directory.path}/support'),
      );
      addTearDown(() async {
        debugCatalog = null;
        AudioLibrary.debugInstance = null;
        await Hive.close();
        await directory.delete(recursive: true);
      });
      final mainFile = File(
        '${directory.path}/support/audio_packs/adhan/testvoice/'
        '${sha256.convert(main).toString().substring(0, 12)}.mp3',
      )..createSync(recursive: true);
      mainFile.writeAsBytesSync(main);
      final fajrFile = File(
        '${directory.path}/support/audio_packs/adhan/testvoice/'
        '${sha256.convert(fajr).toString().substring(0, 12)}.mp3',
      )..writeAsBytesSync(fajr);

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

      var native = <Map<String, dynamic>>[];
      const alarms = MethodChannel('com.abdalluh.tamanina/adhan_alarms');
      const notifications = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      binding.defaultBinaryMessenger.setMockMethodCallHandler(alarms, (
        call,
      ) async {
        native = (jsonDecode(call.arguments as String) as List)
            .cast<Map<String, dynamic>>();
        return native.map((alert) => alert['id'] as int).toList();
      });
      binding.defaultBinaryMessenger.setMockMethodCallHandler(notifications, (
        call,
      ) async {
        return switch (call.method) {
          'initialize' ||
          'areNotificationsEnabled' ||
          'canScheduleExactNotifications' => true,
          'pendingNotificationRequests' => <Object?>[],
          _ => null,
        };
      });
      addTearDown(() {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(alarms, null);
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          notifications,
          null,
        );
      });

      final service = NotificationServiceEnhanced();
      await service.initialize(settingsRepository: settings);
      await service.refresh();
      expect(native, isNotEmpty);
      expect(native.every((alert) => !alert.containsKey('soundPath')), isTrue);

      await settings.updateAdhanVoice('testvoice');
      await service.refresh();
      final fajrAlerts = native.where(
        (a) => (a['route'] as String).contains('fajr=true'),
      );
      final others = native.where(
        (a) => !(a['route'] as String).contains('fajr=true'),
      );
      expect(fajrAlerts, isNotEmpty);
      expect(others, isNotEmpty);
      expect(fajrAlerts.every((a) => a['soundPath'] == fajrFile.path), isTrue);
      expect(others.every((a) => a['soundPath'] == mainFile.path), isTrue);

      // Deleting the download falls back to the bundled adhan.
      mainFile.deleteSync();
      fajrFile.deleteSync();
      await service.refresh();
      expect(native.every((alert) => !alert.containsKey('soundPath')), isTrue);
    },
  );
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;

import 'location_service.dart';
import 'prayer_service_enhanced.dart';

enum HomeWidgetKind { prayer, dhikr, tasbeeh, morning, evening, quran }

class HomeWidgetsService {
  HomeWidgetsService(this._prayers);

  static const _channel = MethodChannel('com.abdalluh.tamanina/home_widgets');
  final PrayerServiceEnhanced _prayers;
  int _revision = 0;
  String? _previous;
  Timer? _tasbeehUpdate;

  void publishTasbeeh(int count) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    _tasbeehUpdate?.cancel();
    _tasbeehUpdate = Timer(const Duration(milliseconds: 300), () async {
      try {
        await _channel.invokeMethod<void>('publishTasbeeh', count);
      } catch (error) {
        debugPrint('Tasbeeh widget unavailable: ${error.runtimeType}');
      }
    });
  }

  Future<bool> requestAndroidPin(HomeWidgetKind kind) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>('pin', kind.name) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh(String languageCode) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    final revision = ++_revision;
    final arabic = languageCode == 'ar';
    final zone = _prayers.locationTimeZone;
    final now = tz.TZDateTime.now(zone);
    final entries = <Map<String, Object>>[];
    var city = '';
    try {
      for (var day = 0; day < 35; day++) {
        final date = tz.TZDateTime(zone, now.year, now.month, now.day + day);
        final times = await _prayers.getPrayerTimes(date);
        if (revision != _revision) return;
        if (times == null) break;
        city = localizedCityName(times.cityName, arabic: arabic);
        for (final prayer in times.obligatoryPrayers) {
          entries.add({
            'name': arabic ? prayer.nameArabic : prayer.name,
            'at': prayer.time.millisecondsSinceEpoch,
          });
        }
      }
    } catch (_) {
      // Keep the last published schedule if calculation fails.
      return;
    }
    if (revision != _revision) return;
    final payload = jsonEncode({
      'language': arabic ? 'ar' : 'en',
      'zone': zone.name,
      'city': city,
      'prayers': entries,
    });
    if (_previous == payload) return;
    try {
      await _channel.invokeMethod<void>('publish', payload);
      if (revision == _revision) _previous = payload;
    } catch (error) {
      debugPrint('Home-screen widgets unavailable: ${error.runtimeType}');
    }
  }
}

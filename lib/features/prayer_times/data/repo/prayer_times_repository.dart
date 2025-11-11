import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/prayer_time_model.dart';
import '../services/prayer_times_service.dart';

/// مخزن أوقات الصلاة
/// Prayer Times Repository
class PrayerTimesRepository {
  final PrayerTimesService _service;
  final SharedPreferences _prefs;

  static const String _cacheKey = 'cached_prayer_times';
  static const String _cacheDateKey = 'cached_prayer_times_date';
  static const String _cachedCityKey = 'cached_city';
  static const String _cachedCountryKey = 'cached_country';

  PrayerTimesRepository({
    required PrayerTimesService service,
    required SharedPreferences prefs,
  })  : _service = service,
        _prefs = prefs;

  /// Get prayer times with caching
  /// جلب أوقات الصلاة مع التخزين المؤقت
  Future<PrayerTimeModel> getPrayerTimes({
    required String city,
    required String country,
    int method = 4,
    bool forceRefresh = false,
  }) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedData = await _getCachedPrayerTimes();
      if (cachedData != null && _isCacheValid()) {
        final cachedCity = _prefs.getString(_cachedCityKey);
        final cachedCountry = _prefs.getString(_cachedCountryKey);

        // Check if location matches
        if (cachedCity == city && cachedCountry == country) {
          return cachedData;
        }
      }
    }

    // Fetch fresh data from API
    try {
      final prayerTimes = await _service.getPrayerTimesByCity(
        city: city,
        country: country,
        method: method,
      );

      // Cache the data
      await _cachePrayerTimes(prayerTimes, city, country);

      return prayerTimes;
    } catch (e) {
      // If API fails, try to return cached data even if old
      final cachedData = await _getCachedPrayerTimes();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// Get prayer times by coordinates
  /// جلب أوقات الصلاة بالإحداثيات
  Future<PrayerTimeModel> getPrayerTimesByLocation({
    required double latitude,
    required double longitude,
    int method = 4,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await _getCachedPrayerTimes();
      if (cachedData != null && _isCacheValid()) {
        return cachedData;
      }
    }

    // Fetch from API
    try {
      final prayerTimes = await _service.getPrayerTimesByCoordinates(
        latitude: latitude,
        longitude: longitude,
        method: method,
      );

      // Cache the data
      await _cachePrayerTimes(prayerTimes, '', '');

      return prayerTimes;
    } catch (e) {
      // Try cached data on error
      final cachedData = await _getCachedPrayerTimes();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// Cache prayer times data
  /// تخزين بيانات أوقات الصلاة مؤقتاً
  Future<void> _cachePrayerTimes(
    PrayerTimeModel prayerTimes,
    String city,
    String country,
  ) async {
    final jsonString = jsonEncode(prayerTimes.toJson());
    await _prefs.setString(_cacheKey, jsonString);
    await _prefs.setString(_cacheDateKey, DateTime.now().toIso8601String());
    await _prefs.setString(_cachedCityKey, city);
    await _prefs.setString(_cachedCountryKey, country);
  }

  /// Get cached prayer times
  /// جلب أوقات الصلاة المخزنة مؤقتاً
  Future<PrayerTimeModel?> _getCachedPrayerTimes() async {
    final jsonString = _prefs.getString(_cacheKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PrayerTimeModel.fromCachedJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is still valid (same day)
  /// التحقق من صلاحية التخزين المؤقت (نفس اليوم)
  bool _isCacheValid() {
    final cacheDateString = _prefs.getString(_cacheDateKey);
    if (cacheDateString == null) return false;

    try {
      final cacheDate = DateTime.parse(cacheDateString);
      final now = DateTime.now();

      // Cache is valid if it's the same day
      return cacheDate.year == now.year &&
          cacheDate.month == now.month &&
          cacheDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  /// Clear cached prayer times
  /// مسح أوقات الصلاة المخزنة
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_cacheDateKey);
    await _prefs.remove(_cachedCityKey);
    await _prefs.remove(_cachedCountryKey);
  }

  /// Get cached city and country
  /// الحصول على المدينة والدولة المخزنة
  Map<String, String> getCachedLocation() {
    return {
      'city': _prefs.getString(_cachedCityKey) ?? 'Makkah',
      'country': _prefs.getString(_cachedCountryKey) ?? 'Saudi Arabia',
    };
  }

  /// Save location preference
  /// حفظ تفضيلات الموقع
  Future<void> saveLocation(String city, String country) async {
    await _prefs.setString(_cachedCityKey, city);
    await _prefs.setString(_cachedCountryKey, country);
  }
}

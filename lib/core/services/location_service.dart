import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نتيجة الحصول على الموقع
/// Location Result
class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String? countryName;
  final String? errorMessage;
  final LocationErrorType? errorType;

  const LocationResult({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.cityName,
    this.countryName,
    this.errorMessage,
    this.errorType,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    String? cityName,
    String? countryName,
  }) {
    return LocationResult(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
      countryName: countryName,
    );
  }

  factory LocationResult.failure({
    required String errorMessage,
    required LocationErrorType errorType,
  }) {
    return LocationResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }
}

/// أنواع أخطاء الموقع
/// Location Error Types
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// خدمة الموقع
/// The most specific useful name for a place: the town or district, not the
/// governorate ("الشروق", not "محافظة القاهرة").
String? _placeName(Placemark placemark) {
  String? clean(String? value) {
    final text = value
        ?.replaceAll(
          RegExp(r'\b(Governorate|Province|Region)\b', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'^(محافظة|منطقة|إقليم)\s+'), '')
        .trim();
    return text == null || text.isEmpty ? null : text;
  }

  return clean(placemark.locality) ??
      clean(placemark.subLocality) ??
      clean(placemark.subAdministrativeArea) ??
      clean(placemark.administrativeArea);
}

/// Location Service - Handles GPS and geocoding
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  SharedPreferences? _prefs;

  // Cache keys
  static const String _keyCachedLat = 'location_cached_lat';
  static const String _keyCachedLng = 'location_cached_lng';
  static const String _keyCachedCity = 'location_cached_city';
  static const String _keyCachedCountry = 'location_cached_country';
  static const String _keyCachedTimestamp = 'location_cached_timestamp';
  static const String _keyLastPlacemark = 'location_last_placemark';

  /// What the address lookup returned last time, for the diagnostics screen.
  String? get lastPlacemark => _prefs?.getString(_keyLastPlacemark);

  // Cache validity duration (1 hour)
  static const Duration _cacheValidity = Duration(hours: 1);

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission>? _activePermissionRequest;
  Future<LocationResult>? _activeLocationRequest;

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission with single-flight mutex
  Future<LocationPermission> requestPermission() async {
    if (_activePermissionRequest != null) {
      return _activePermissionRequest!;
    }
    return _activePermissionRequest = Geolocator.requestPermission()
        .whenComplete(() {
          _activePermissionRequest = null;
        });
  }

  /// Get current location with geocoding and single-flight concurrency guard
  Future<LocationResult> getCurrentLocation({
    bool forceRefresh = false,
    bool promptForPermission = true,
  }) async {
    if (_activeLocationRequest != null) {
      return _activeLocationRequest!;
    }
    return _activeLocationRequest =
        _getCurrentLocationImpl(
          forceRefresh: forceRefresh,
          promptForPermission: promptForPermission,
        ).whenComplete(() {
          _activeLocationRequest = null;
        });
  }

  Future<LocationResult> _getCurrentLocationImpl({
    bool forceRefresh = false,
    bool promptForPermission = true,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedLocation();
        if (cached != null) {
          return cached;
        }
      }

      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled().timeout(
        const Duration(seconds: 3),
      );
      if (!serviceEnabled) {
        return LocationResult.failure(
          errorMessage: 'خدمة الموقع معطلة. يرجى تفعيلها من الإعدادات.',
          errorType: LocationErrorType.serviceDisabled,
        );
      }

      // Check permission
      var permission = await checkPermission().timeout(
        const Duration(seconds: 3),
      );
      if (permission == LocationPermission.denied) {
        if (promptForPermission) permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
            errorMessage:
                'تم رفض إذن الموقع. يرجى السماح للتطبيق بالوصول للموقع.',
            errorType: LocationErrorType.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          errorMessage:
              'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
          errorType: LocationErrorType.permissionDeniedForever,
        );
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get the place name with geocoding, in the app's language
      String? cityName;
      String? countryName;
      try {
        final arabic = (_prefs?.getString('locale') ?? 'ar').startsWith('ar');
        await setLocaleIdentifier(arabic ? 'ar_EG' : 'en_US');
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 4));
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          cityName = _placeName(placemark);
          countryName = placemark.isoCountryCode ?? placemark.country;
          await _prefs?.setString(
            _keyLastPlacemark,
            'locality=${placemark.locality} | subLocality=${placemark.subLocality} | '
            'subAdmin=${placemark.subAdministrativeArea} | admin=${placemark.administrativeArea} | '
            'country=${placemark.isoCountryCode} | chosen=$cityName',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Geocoding error: $e');
        }
      }
      if (cityName == null) {
        // No address lookup (offline). If the phone has barely moved, keep the
        // last good name instead of a nearby big-city label.
        final lat = _prefs?.getDouble(_keyCachedLat);
        final lng = _prefs?.getDouble(_keyCachedLng);
        final previous = _prefs?.getString(_keyCachedCity);
        if (lat != null &&
            lng != null &&
            previous != null &&
            calculateDistance(
                  startLatitude: position.latitude,
                  startLongitude: position.longitude,
                  endLatitude: lat,
                  endLongitude: lng,
                ) <
                3) {
          cityName = previous;
          countryName ??= _prefs?.getString(_keyCachedCountry);
        }
      }
      if (cityName == null) {
        // GPS works offline. The bundled city list supplies a nearby label
        // when the platform's address lookup has no connection.
        var nearestDistance = 35.0;
        PopularCity? nearest;
        for (final city in popularCities) {
          final distance = calculateDistance(
            startLatitude: position.latitude,
            startLongitude: position.longitude,
            endLatitude: city.latitude,
            endLongitude: city.longitude,
          );
          if (distance >= nearestDistance) continue;
          nearestDistance = distance;
          nearest = city;
        }
        cityName = nearest?.nameArabic;
        countryName ??= nearest?.country;
      }

      // Cache the result
      await _cacheLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        countryName: countryName,
      );

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        countryName: countryName,
      );
    } on TimeoutException {
      return LocationResult.failure(
        errorMessage: 'انتهت مهلة الحصول على الموقع. يرجى المحاولة مرة أخرى.',
        errorType: LocationErrorType.timeout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Location error: $e');
      }
      return LocationResult.failure(
        errorMessage: 'حدث خطأ أثناء الحصول على الموقع: $e',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  /// Cache location data
  Future<void> _cacheLocation({
    required double latitude,
    required double longitude,
    String? cityName,
    String? countryName,
  }) async {
    await _prefs?.setDouble(_keyCachedLat, latitude);
    await _prefs?.setDouble(_keyCachedLng, longitude);
    if (cityName != null) {
      await _prefs?.setString(_keyCachedCity, cityName);
    } else {
      await _prefs?.remove(_keyCachedCity);
    }
    if (countryName != null) {
      await _prefs?.setString(_keyCachedCountry, countryName);
    } else {
      await _prefs?.remove(_keyCachedCountry);
    }
    await _prefs?.setInt(
      _keyCachedTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached location if still valid
  Future<LocationResult?> _getCachedLocation() async {
    final timestamp = _prefs?.getInt(_keyCachedTimestamp);
    if (timestamp == null) return null;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cachedTime) > _cacheValidity) {
      return null; // Cache expired
    }

    final lat = _prefs?.getDouble(_keyCachedLat);
    final lng = _prefs?.getDouble(_keyCachedLng);

    if (lat == null || lng == null) return null;

    return LocationResult.success(
      latitude: lat,
      longitude: lng,
      cityName: _prefs?.getString(_keyCachedCity),
      countryName: _prefs?.getString(_keyCachedCountry),
    );
  }

  /// Get last known location (even if expired)
  LocationResult? getLastKnownLocation() {
    final lat = _prefs?.getDouble(_keyCachedLat);
    final lng = _prefs?.getDouble(_keyCachedLng);

    if (lat == null || lng == null) return null;

    return LocationResult.success(
      latitude: lat,
      longitude: lng,
      cityName: _prefs?.getString(_keyCachedCity),
      countryName: _prefs?.getString(_keyCachedCountry),
    );
  }

  /// Clear cached location
  Future<void> clearCache() async {
    await _prefs?.remove(_keyCachedLat);
    await _prefs?.remove(_keyCachedLng);
    await _prefs?.remove(_keyCachedCity);
    await _prefs?.remove(_keyCachedCountry);
    await _prefs?.remove(_keyCachedTimestamp);
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permission)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Calculate distance between two points in km
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceInMeters / 1000; // Convert to km
  }

  /// Calculate distance to Kaaba
  Future<double?> getDistanceToKaaba() async {
    final location = await getCurrentLocation();
    if (!location.isSuccess) return null;

    // Kaaba coordinates
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;

    return calculateDistance(
      startLatitude: location.latitude!,
      startLongitude: location.longitude!,
      endLatitude: kaabaLat,
      endLongitude: kaabaLng,
    );
  }

  /// Calculate bearing to Kaaba (Qibla direction)
  Future<double?> getQiblaDirection() async {
    final location = await getCurrentLocation();
    if (!location.isSuccess) return null;

    // Kaaba coordinates
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;

    return Geolocator.bearingBetween(
      location.latitude!,
      location.longitude!,
      kaabaLat,
      kaabaLng,
    );
  }
}

/// Popular cities for manual selection
class PopularCity {
  final String nameArabic;
  final String nameEnglish;
  final String country;
  final double latitude;
  final double longitude;

  const PopularCity({
    required this.nameArabic,
    required this.nameEnglish,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

/// List of popular cities for manual selection
String localizedCityName(String name, {required bool arabic}) {
  final normalized = name.trim().toLowerCase();
  for (final city in popularCities) {
    if (city.nameArabic == normalized ||
        city.nameEnglish.toLowerCase() == normalized) {
      return arabic ? city.nameArabic : city.nameEnglish;
    }
  }
  return name;
}

const List<PopularCity> popularCities = [
  PopularCity(
    nameArabic: 'مكة المكرمة',
    nameEnglish: 'Makkah',
    country: 'SA',
    latitude: 21.4225,
    longitude: 39.8262,
  ),
  PopularCity(
    nameArabic: 'المدينة المنورة',
    nameEnglish: 'Madinah',
    country: 'SA',
    latitude: 24.5247,
    longitude: 39.5692,
  ),
  PopularCity(
    nameArabic: 'الرياض',
    nameEnglish: 'Riyadh',
    country: 'SA',
    latitude: 24.7136,
    longitude: 46.6753,
  ),
  PopularCity(
    nameArabic: 'جدة',
    nameEnglish: 'Jeddah',
    country: 'SA',
    latitude: 21.5433,
    longitude: 39.1728,
  ),
  PopularCity(
    nameArabic: 'القاهرة',
    nameEnglish: 'Cairo',
    country: 'EG',
    latitude: 30.0444,
    longitude: 31.2357,
  ),
  PopularCity(
    nameArabic: 'الإسكندرية',
    nameEnglish: 'Alexandria',
    country: 'EG',
    latitude: 31.2001,
    longitude: 29.9187,
  ),
  PopularCity(
    nameArabic: 'دبي',
    nameEnglish: 'Dubai',
    country: 'AE',
    latitude: 25.2048,
    longitude: 55.2708,
  ),
  PopularCity(
    nameArabic: 'أبوظبي',
    nameEnglish: 'Abu Dhabi',
    country: 'AE',
    latitude: 24.4539,
    longitude: 54.3773,
  ),
  PopularCity(
    nameArabic: 'الدوحة',
    nameEnglish: 'Doha',
    country: 'QA',
    latitude: 25.2854,
    longitude: 51.5310,
  ),
  PopularCity(
    nameArabic: 'الكويت',
    nameEnglish: 'Kuwait City',
    country: 'KW',
    latitude: 29.3759,
    longitude: 47.9774,
  ),
  PopularCity(
    nameArabic: 'عمّان',
    nameEnglish: 'Amman',
    country: 'JO',
    latitude: 31.9454,
    longitude: 35.9284,
  ),
  PopularCity(
    nameArabic: 'إربد',
    nameEnglish: 'Irbid',
    country: 'JO',
    latitude: 32.55696,
    longitude: 35.84790,
  ),
  PopularCity(
    nameArabic: 'بيروت',
    nameEnglish: 'Beirut',
    country: 'LB',
    latitude: 33.8938,
    longitude: 35.5018,
  ),
  PopularCity(
    nameArabic: 'دمشق',
    nameEnglish: 'Damascus',
    country: 'SY',
    latitude: 33.5138,
    longitude: 36.2765,
  ),
  PopularCity(
    nameArabic: 'بغداد',
    nameEnglish: 'Baghdad',
    country: 'IQ',
    latitude: 33.3152,
    longitude: 44.3661,
  ),
  PopularCity(
    nameArabic: 'إسطنبول',
    nameEnglish: 'Istanbul',
    country: 'TR',
    latitude: 41.0082,
    longitude: 28.9784,
  ),
  PopularCity(
    nameArabic: 'الرباط',
    nameEnglish: 'Rabat',
    country: 'MA',
    latitude: 34.0209,
    longitude: -6.8416,
  ),
  PopularCity(
    nameArabic: 'الجزائر',
    nameEnglish: 'Algiers',
    country: 'DZ',
    latitude: 36.7538,
    longitude: 3.0588,
  ),
  PopularCity(
    nameArabic: 'تونس',
    nameEnglish: 'Tunis',
    country: 'TN',
    latitude: 36.8065,
    longitude: 10.1815,
  ),
  PopularCity(
    nameArabic: 'طرابلس',
    nameEnglish: 'Tripoli',
    country: 'LY',
    latitude: 32.8872,
    longitude: 13.1913,
  ),
  PopularCity(
    nameArabic: 'الخرطوم',
    nameEnglish: 'Khartoum',
    country: 'SD',
    latitude: 15.5007,
    longitude: 32.5599,
  ),
  PopularCity(
    nameArabic: 'جاكرتا',
    nameEnglish: 'Jakarta',
    country: 'ID',
    latitude: -6.2088,
    longitude: 106.8456,
  ),
  PopularCity(
    nameArabic: 'كوالالمبور',
    nameEnglish: 'Kuala Lumpur',
    country: 'MY',
    latitude: 3.1390,
    longitude: 101.6869,
  ),
  PopularCity(
    nameArabic: 'لندن',
    nameEnglish: 'London',
    country: 'GB',
    latitude: 51.5074,
    longitude: -0.1278,
  ),
  PopularCity(
    nameArabic: 'باريس',
    nameEnglish: 'Paris',
    country: 'FR',
    latitude: 48.8566,
    longitude: 2.3522,
  ),
  PopularCity(
    nameArabic: 'نيويورك',
    nameEnglish: 'New York',
    country: 'US',
    latitude: 40.7128,
    longitude: -74.0060,
  ),
  PopularCity(
    nameArabic: 'تورنتو',
    nameEnglish: 'Toronto',
    country: 'CA',
    latitude: 43.6532,
    longitude: -79.3832,
  ),
];

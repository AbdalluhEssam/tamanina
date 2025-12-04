import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

/// طرق الحساب المتاحة
/// Available Calculation Methods
enum PrayerCalculationMethod {
  muslimWorldLeague,
  isna, // Islamic Society of North America
  egyptian, // Egyptian General Authority of Survey
  ummAlQura, // Umm al-Qura University, Makkah
  karachi, // University of Islamic Sciences, Karachi
  tehran, // Institute of Geophysics, University of Tehran
  kuwait, // Kuwait
  qatar, // Qatar
  singapore, // Majlis Ugama Islam Singapura
  turkey, // Diyanet İşleri Başkanlığı
  dubai, // UAE
  morocco, // Morocco
}

/// مذهب العصر
/// Asr Calculation Madhab
enum AsrMadhab {
  shafi, // Standard (Shafi, Maliki, Hanbali)
  hanafi, // Hanafi
}

/// نموذج وقت الصلاة
/// Prayer Time Model
class PrayerTimeData {
  final String name;
  final String nameArabic;
  final DateTime time;
  final bool isNext;
  final Duration? timeUntil;
  final Duration? timeSince;

  const PrayerTimeData({
    required this.name,
    required this.nameArabic,
    required this.time,
    this.isNext = false,
    this.timeUntil,
    this.timeSince,
  });

  String get formattedTime {
    return DateFormat('h:mm a', 'ar').format(time);
  }

  String get formattedTime24 {
    return DateFormat('HH:mm').format(time);
  }

  PrayerTimeData copyWith({
    String? name,
    String? nameArabic,
    DateTime? time,
    bool? isNext,
    Duration? timeUntil,
    Duration? timeSince,
  }) {
    return PrayerTimeData(
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      time: time ?? this.time,
      isNext: isNext ?? this.isNext,
      timeUntil: timeUntil ?? this.timeUntil,
      timeSince: timeSince ?? this.timeSince,
    );
  }
}

/// نموذج بيانات الصلوات اليومية
/// Daily Prayer Times Data
class DailyPrayerTimes {
  final PrayerTimeData fajr;
  final PrayerTimeData sunrise;
  final PrayerTimeData dhuhr;
  final PrayerTimeData asr;
  final PrayerTimeData maghrib;
  final PrayerTimeData isha;
  final DateTime date;
  final String hijriDate;
  final String gregorianDate;
  final String cityName;
  final String countryName;
  final double latitude;
  final double longitude;

  const DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.gregorianDate,
    required this.cityName,
    required this.countryName,
    required this.latitude,
    required this.longitude,
  });

  List<PrayerTimeData> get allPrayers =>
      [fajr, sunrise, dhuhr, asr, maghrib, isha];

  List<PrayerTimeData> get obligatoryPrayers =>
      [fajr, dhuhr, asr, maghrib, isha];

  PrayerTimeData? get nextPrayer {
    return allPrayers.where((p) => p.isNext).firstOrNull;
  }

  PrayerTimeData? get currentPrayer {
    final now = DateTime.now();
    PrayerTimeData? current;

    for (final prayer in allPrayers.reversed) {
      if (prayer.time.isBefore(now)) {
        current = prayer;
        break;
      }
    }
    return current;
  }
}

/// خدمة أوقات الصلاة
/// Prayer Times Service - Uses adhan package for accurate calculation
class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal();

  final LocationService _locationService = LocationService();

  // Settings keys
  static const String _keyCalculationMethod = 'prayer_calculation_method';
  static const String _keyMadhab = 'prayer_madhab';
  static const String _keyManualCity = 'prayer_manual_city';
  static const String _keyManualCountry = 'prayer_manual_country';
  static const String _keyManualLat = 'prayer_manual_lat';
  static const String _keyManualLng = 'prayer_manual_lng';
  static const String _keyUseManualLocation = 'prayer_use_manual_location';
  static const String _keyHighLatitudeRule = 'prayer_high_latitude_rule';

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _locationService.initialize();
  }

  /// Get current calculation method
  PrayerCalculationMethod get calculationMethod {
    final index =
        _prefs?.getInt(_keyCalculationMethod) ?? 3; // Default: Umm al-Qura
    return PrayerCalculationMethod
        .values[index.clamp(0, PrayerCalculationMethod.values.length - 1)];
  }

  /// Set calculation method
  Future<void> setCalculationMethod(PrayerCalculationMethod method) async {
    await _prefs?.setInt(_keyCalculationMethod, method.index);
  }

  /// Get current madhab for Asr
  AsrMadhab get madhab {
    final index = _prefs?.getInt(_keyMadhab) ?? 0; // Default: Shafi
    return AsrMadhab.values[index.clamp(0, AsrMadhab.values.length - 1)];
  }

  /// Set madhab for Asr calculation
  Future<void> setMadhab(AsrMadhab madhab) async {
    await _prefs?.setInt(_keyMadhab, madhab.index);
  }

  /// Check if using manual location
  bool get useManualLocation => _prefs?.getBool(_keyUseManualLocation) ?? false;

  /// Set manual location preference
  Future<void> setUseManualLocation(bool value) async {
    await _prefs?.setBool(_keyUseManualLocation, value);
  }

  /// Set manual location
  Future<void> setManualLocation({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
  }) async {
    await _prefs?.setString(_keyManualCity, city);
    await _prefs?.setString(_keyManualCountry, country);
    await _prefs?.setDouble(_keyManualLat, latitude);
    await _prefs?.setDouble(_keyManualLng, longitude);
    await _prefs?.setBool(_keyUseManualLocation, true);
  }

  /// Convert our method enum to adhan CalculationMethod
  CalculationMethod _getAdhanMethod() {
    switch (calculationMethod) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return CalculationMethod.muslim_world_league;
      case PrayerCalculationMethod.isna:
        return CalculationMethod.north_america;
      case PrayerCalculationMethod.egyptian:
        return CalculationMethod.egyptian;
      case PrayerCalculationMethod.ummAlQura:
        return CalculationMethod.umm_al_qura;
      case PrayerCalculationMethod.karachi:
        return CalculationMethod.karachi;
      case PrayerCalculationMethod.tehran:
        return CalculationMethod.tehran;
      case PrayerCalculationMethod.kuwait:
        return CalculationMethod.kuwait;
      case PrayerCalculationMethod.qatar:
        return CalculationMethod.qatar;
      case PrayerCalculationMethod.singapore:
        return CalculationMethod.singapore;
      case PrayerCalculationMethod.turkey:
        return CalculationMethod.turkey;
      case PrayerCalculationMethod.dubai:
        return CalculationMethod.dubai;
      case PrayerCalculationMethod.morocco:
        return CalculationMethod.moon_sighting_committee;
    }
  }

  /// Get adhan madhab
  Madhab _getAdhanMadhab() {
    switch (madhab) {
      case AsrMadhab.shafi:
        return Madhab.shafi;
      case AsrMadhab.hanafi:
        return Madhab.hanafi;
    }
  }

  /// Get prayer times for today
  Future<DailyPrayerTimes> getTodayPrayerTimes() async {
    return getPrayerTimes(DateTime.now());
  }

  /// Get prayer times for a specific date
  Future<DailyPrayerTimes> getPrayerTimes(DateTime date) async {
    try {
      // Get location
      double latitude;
      double longitude;
      String cityName;
      String countryName;

      if (useManualLocation) {
        latitude = _prefs?.getDouble(_keyManualLat) ?? 21.4225;
        longitude = _prefs?.getDouble(_keyManualLng) ?? 39.8262;
        cityName = _prefs?.getString(_keyManualCity) ?? 'مكة المكرمة';
        countryName =
            _prefs?.getString(_keyManualCountry) ?? 'المملكة العربية السعودية';
      } else {
        final locationResult = await _locationService.getCurrentLocation();
        if (locationResult.isSuccess) {
          latitude = locationResult.latitude!;
          longitude = locationResult.longitude!;
          cityName = locationResult.cityName ?? 'موقعك الحالي';
          countryName = locationResult.countryName ?? '';
        } else {
          // Fallback to Makkah
          latitude = 21.4225;
          longitude = 39.8262;
          cityName = 'مكة المكرمة';
          countryName = 'المملكة العربية السعودية';
        }
      }

      // Calculate prayer times using adhan
      final coordinates = Coordinates(latitude, longitude);
      final params = _getAdhanMethod().getParameters();
      params.madhab = _getAdhanMadhab();

      final dateComponents = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

      final now = DateTime.now();

      // Create prayer time data
      final fajrTime = prayerTimes.fajr;
      final sunriseTime = prayerTimes.sunrise;
      final dhuhrTime = prayerTimes.dhuhr;
      final asrTime = prayerTimes.asr;
      final maghribTime = prayerTimes.maghrib;
      final ishaTime = prayerTimes.isha;

      // Determine next prayer
      Prayer? nextPrayer;
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        nextPrayer = prayerTimes.nextPrayer();
      }

      // Calculate Hijri date
      final hijriDate = _calculateHijriDate(date);
      final gregorianDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(date);

      return DailyPrayerTimes(
        fajr: _createPrayerTimeData(
            'Fajr', 'الفجر', fajrTime, now, nextPrayer == Prayer.fajr),
        sunrise: _createPrayerTimeData('Sunrise', 'الشروق', sunriseTime, now,
            nextPrayer == Prayer.sunrise),
        dhuhr: _createPrayerTimeData(
            'Dhuhr', 'الظهر', dhuhrTime, now, nextPrayer == Prayer.dhuhr),
        asr: _createPrayerTimeData(
            'Asr', 'العصر', asrTime, now, nextPrayer == Prayer.asr),
        maghrib: _createPrayerTimeData('Maghrib', 'المغرب', maghribTime, now,
            nextPrayer == Prayer.maghrib),
        isha: _createPrayerTimeData(
            'Isha', 'العشاء', ishaTime, now, nextPrayer == Prayer.isha),
        date: date,
        hijriDate: hijriDate,
        gregorianDate: gregorianDate,
        cityName: cityName,
        countryName: countryName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating prayer times: $e');
      }
      rethrow;
    }
  }

  PrayerTimeData _createPrayerTimeData(
    String name,
    String nameArabic,
    DateTime time,
    DateTime now,
    bool isNext,
  ) {
    Duration? timeUntil;
    Duration? timeSince;

    if (time.isAfter(now)) {
      timeUntil = time.difference(now);
    } else {
      timeSince = now.difference(time);
    }

    return PrayerTimeData(
      name: name,
      nameArabic: nameArabic,
      time: time,
      isNext: isNext,
      timeUntil: timeUntil,
      timeSince: timeSince,
    );
  }

  /// Calculate Hijri date (simplified - for production use hijri package)
  String _calculateHijriDate(DateTime date) {
    // Using a simplified calculation - should use hijri package for accuracy
    try {
      // This is a placeholder - the actual app should use the hijri package
      // for accurate Hijri date calculation
      final hijriMonths = [
        'محرم',
        'صفر',
        'ربيع الأول',
        'ربيع الثاني',
        'جمادى الأولى',
        'جمادى الآخرة',
        'رجب',
        'شعبان',
        'رمضان',
        'شوال',
        'ذو القعدة',
        'ذو الحجة'
      ];

      // Simplified conversion - this is NOT accurate
      // Production should use the hijri package
      final jd = _gregorianToJulian(date.year, date.month, date.day);
      final hijri = _julianToHijri(jd);

      return '${hijri['day']} ${hijriMonths[hijri['month']! - 1]} ${hijri['year']}';
    } catch (e) {
      return '';
    }
  }

  int _gregorianToJulian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = year ~/ 100;
    final b = 2 - a + a ~/ 4;
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;
  }

  Map<String, int> _julianToHijri(int jd) {
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final l3 = l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final month = ((24 * l3) / 709).floor();
    final day = l3 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    return {'year': year, 'month': month, 'day': day};
  }

  /// Get next prayer time
  Future<PrayerTimeData?> getNextPrayer() async {
    final times = await getTodayPrayerTimes();
    return times.nextPrayer;
  }

  /// Get time until next prayer
  Future<Duration?> getTimeUntilNextPrayer() async {
    final nextPrayer = await getNextPrayer();
    return nextPrayer?.timeUntil;
  }

  /// Format duration for display
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (minutes > 0) {
      return '$minutes دقيقة و $seconds ثانية';
    } else {
      return '$seconds ثانية';
    }
  }

  /// Get calculation method display name
  String getCalculationMethodName(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case PrayerCalculationMethod.isna:
        return 'الجمعية الإسلامية لأمريكا الشمالية';
      case PrayerCalculationMethod.egyptian:
        return 'الهيئة المصرية العامة للمساحة';
      case PrayerCalculationMethod.ummAlQura:
        return 'جامعة أم القرى';
      case PrayerCalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية، كراتشي';
      case PrayerCalculationMethod.tehran:
        return 'معهد الجيوفيزياء، طهران';
      case PrayerCalculationMethod.kuwait:
        return 'الكويت';
      case PrayerCalculationMethod.qatar:
        return 'قطر';
      case PrayerCalculationMethod.singapore:
        return 'سنغافورة';
      case PrayerCalculationMethod.turkey:
        return 'رئاسة الشؤون الدينية التركية';
      case PrayerCalculationMethod.dubai:
        return 'الإمارات';
      case PrayerCalculationMethod.morocco:
        return 'المغرب';
    }
  }

  /// Get madhab display name
  String getMadhabName(AsrMadhab madhab) {
    switch (madhab) {
      case AsrMadhab.shafi:
        return 'الشافعي والمالكي والحنبلي';
      case AsrMadhab.hanafi:
        return 'الحنفي';
    }
  }

  /// Get all available calculation methods
  List<PrayerCalculationMethod> get availableMethods =>
      PrayerCalculationMethod.values;

  /// Get all available madhabs
  List<AsrMadhab> get availableMadhabs => AsrMadhab.values;

  /// Stream of prayer times that updates every minute
  Stream<DailyPrayerTimes> get prayerTimesStream async* {
    while (true) {
      yield await getTodayPrayerTimes();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  /// Stream of countdown to next prayer
  Stream<Duration?> get countdownStream async* {
    while (true) {
      final times = await getTodayPrayerTimes();
      final nextPrayer = times.nextPrayer;
      if (nextPrayer != null && nextPrayer.timeUntil != null) {
        yield nextPrayer.timeUntil;
      } else {
        yield null;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

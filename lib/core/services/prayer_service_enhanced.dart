import 'dart:async';
import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../settings/settings_repository.dart' as settings_repo;
import 'location_service.dart';

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

  /// الحصول على وقت صلاة بالاسم
  /// Get prayer time by name
  PrayerTimeData? getPrayerByName(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }
}

/// خدمة أوقات الصلاة المحسّنة
/// Enhanced Prayer Times Service - Integrates with Settings
class PrayerServiceEnhanced {
  static final PrayerServiceEnhanced _instance =
      PrayerServiceEnhanced._internal();
  factory PrayerServiceEnhanced() => _instance;
  PrayerServiceEnhanced._internal();

  final LocationService _locationService = LocationService();

  settings_repo.SettingsRepository? _settingsRepository;
  StreamSubscription<settings_repo.AppSettings>? _settingsSubscription;

  // Cached values
  DailyPrayerTimes? _cachedTimes;
  DateTime? _cacheDate;

  // Stream controllers
  final _prayerTimesController = StreamController<DailyPrayerTimes>.broadcast();
  final _nextPrayerController = StreamController<PrayerTimeData?>.broadcast();

  /// تيار أوقات الصلاة
  /// Prayer times stream
  Stream<DailyPrayerTimes> get prayerTimesStream =>
      _prayerTimesController.stream;

  /// تيار الصلاة التالية
  /// Next prayer stream
  Stream<PrayerTimeData?> get nextPrayerStream => _nextPrayerController.stream;

  /// تهيئة الخدمة
  /// Initialize the service
  Future<void> initialize(
      {settings_repo.SettingsRepository? settingsRepository}) async {
    _settingsRepository = settingsRepository;
    await _locationService.initialize();

    // Listen to settings changes
    if (_settingsRepository != null) {
      _settingsSubscription =
          _settingsRepository!.settingsStream.listen((settings) {
        // Recompute prayer times when settings change
        _invalidateCache();
        _notifyPrayerTimesChanged();
      });
    }

    // Start periodic updates
    _startPeriodicUpdates();
  }

  /// ربط مستودع الإعدادات
  /// Attach settings repository
  void attachSettingsRepository(settings_repo.SettingsRepository repository) {
    _settingsRepository = repository;
    _settingsSubscription?.cancel();
    _settingsSubscription = repository.settingsStream.listen((settings) {
      _invalidateCache();
      _notifyPrayerTimesChanged();
    });
  }

  /// إبطال الذاكرة المؤقتة
  /// Invalidate cache
  void _invalidateCache() {
    _cachedTimes = null;
    _cacheDate = null;
  }

  /// إشعار المستمعين بتغير أوقات الصلاة
  /// Notify listeners of prayer times change
  Future<void> _notifyPrayerTimesChanged() async {
    try {
      final times = await getTodayPrayerTimes();
      _prayerTimesController.add(times);
      _nextPrayerController.add(times.nextPrayer);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error notifying prayer times: $e');
      }
    }
  }

  /// بدء التحديثات الدورية
  /// Start periodic updates
  void _startPeriodicUpdates() {
    // Update every minute
    Timer.periodic(const Duration(minutes: 1), (_) async {
      await _notifyPrayerTimesChanged();
    });
  }

  /// الحصول على طريقة الحساب الحالية
  /// Get current calculation method
  settings_repo.PrayerCalculationMethod get calculationMethod {
    if (_settingsRepository != null) {
      return _settingsRepository!.currentSettings.calculationMethod;
    }
    return settings_repo.PrayerCalculationMethod.ummAlQura;
  }

  /// الحصول على المذهب الحالي
  /// Get current madhab
  settings_repo.Madhab get madhab {
    if (_settingsRepository != null) {
      return _settingsRepository!.currentSettings.madhab;
    }
    return settings_repo.Madhab.shafi;
  }

  /// هل يستخدم الموقع اليدوي
  /// Is using manual location
  bool get useManualLocation {
    if (_settingsRepository != null) {
      return !_settingsRepository!
          .currentSettings.locationSettings.useAutoLocation;
    }
    return false;
  }

  /// تحويل طريقة الحساب إلى معلمات adhan
  /// Convert calculation method to adhan parameters
  adhan.CalculationMethod _getAdhanMethod() {
    switch (calculationMethod) {
      case settings_repo.PrayerCalculationMethod.muslimWorldLeague:
        return adhan.CalculationMethod.muslim_world_league;
      case settings_repo.PrayerCalculationMethod.isna:
        return adhan.CalculationMethod.north_america;
      case settings_repo.PrayerCalculationMethod.egyptian:
        return adhan.CalculationMethod.egyptian;
      case settings_repo.PrayerCalculationMethod.ummAlQura:
        return adhan.CalculationMethod.umm_al_qura;
      case settings_repo.PrayerCalculationMethod.karachi:
        return adhan.CalculationMethod.karachi;
      case settings_repo.PrayerCalculationMethod.dubai:
        return adhan.CalculationMethod.dubai;
      case settings_repo.PrayerCalculationMethod.kuwait:
        return adhan.CalculationMethod.kuwait;
      case settings_repo.PrayerCalculationMethod.qatar:
        return adhan.CalculationMethod.qatar;
      case settings_repo.PrayerCalculationMethod.singapore:
        return adhan.CalculationMethod.singapore;
      case settings_repo.PrayerCalculationMethod.turkey:
        return adhan.CalculationMethod.turkey;
    }
  }

  /// الحصول على مذهب adhan
  /// Get adhan madhab
  adhan.Madhab _getAdhanMadhab() {
    switch (madhab) {
      case settings_repo.Madhab.shafi:
        return adhan.Madhab.shafi;
      case settings_repo.Madhab.hanafi:
        return adhan.Madhab.hanafi;
    }
  }

  /// الحصول على أوقات الصلاة لليوم
  /// Get prayer times for today
  Future<DailyPrayerTimes> getTodayPrayerTimes() async {
    return getPrayerTimes(DateTime.now());
  }

  /// الحصول على أوقات الصلاة لتاريخ معين
  /// Get prayer times for a specific date
  Future<DailyPrayerTimes> getPrayerTimes(DateTime date) async {
    // Check cache
    final today = DateTime(date.year, date.month, date.day);
    final cacheToday = _cacheDate != null
        ? DateTime(_cacheDate!.year, _cacheDate!.month, _cacheDate!.day)
        : null;

    if (_cachedTimes != null && cacheToday == today) {
      return _updateNextPrayer(_cachedTimes!);
    }

    try {
      // Get location
      double latitude;
      double longitude;
      String cityName;
      String countryName;

      if (useManualLocation && _settingsRepository != null) {
        final locSettings =
            _settingsRepository!.currentSettings.locationSettings;
        latitude = locSettings.manualLatitude ?? 21.4225;
        longitude = locSettings.manualLongitude ?? 39.8262;
        cityName = locSettings.cityName ?? 'مكة المكرمة';
        countryName = locSettings.countryName ?? 'المملكة العربية السعودية';
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
      final coordinates = adhan.Coordinates(latitude, longitude);
      final params = _getAdhanMethod().getParameters();
      params.madhab = _getAdhanMadhab();

      final dateComponents =
          adhan.DateComponents(date.year, date.month, date.day);
      final prayerTimes =
          adhan.PrayerTimes(coordinates, dateComponents, params);

      final now = DateTime.now();

      // Determine next prayer
      adhan.Prayer? nextPrayerEnum;
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        nextPrayerEnum = prayerTimes.nextPrayer();
      }

      // Calculate Hijri date
      final hijriDate = _calculateHijriDate(date);
      final gregorianDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(date);

      final result = DailyPrayerTimes(
        fajr: _createPrayerTimeData('Fajr', 'الفجر', prayerTimes.fajr, now,
            nextPrayerEnum == adhan.Prayer.fajr),
        sunrise: _createPrayerTimeData('Sunrise', 'الشروق', prayerTimes.sunrise,
            now, nextPrayerEnum == adhan.Prayer.sunrise),
        dhuhr: _createPrayerTimeData('Dhuhr', 'الظهر', prayerTimes.dhuhr, now,
            nextPrayerEnum == adhan.Prayer.dhuhr),
        asr: _createPrayerTimeData('Asr', 'العصر', prayerTimes.asr, now,
            nextPrayerEnum == adhan.Prayer.asr),
        maghrib: _createPrayerTimeData('Maghrib', 'المغرب', prayerTimes.maghrib,
            now, nextPrayerEnum == adhan.Prayer.maghrib),
        isha: _createPrayerTimeData('Isha', 'العشاء', prayerTimes.isha, now,
            nextPrayerEnum == adhan.Prayer.isha),
        date: date,
        hijriDate: hijriDate,
        gregorianDate: gregorianDate,
        cityName: cityName,
        countryName: countryName,
        latitude: latitude,
        longitude: longitude,
      );

      // Cache result
      _cachedTimes = result;
      _cacheDate = date;

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating prayer times: $e');
      }
      rethrow;
    }
  }

  /// حساب أوقات الصلاة لتاريخ معين
  /// Compute prayer times for a specific date
  Future<DailyPrayerTimes> computeForDate(DateTime date) async {
    return getPrayerTimes(date);
  }

  /// الحصول على وقت الصلاة التالية
  /// Get next prayer time
  Future<DateTime?> nextPrayerTime() async {
    final times = await getTodayPrayerTimes();
    return times.nextPrayer?.time;
  }

  /// الحصول على الصلاة التالية
  /// Get next prayer
  Future<PrayerTimeData?> nextPrayer() async {
    final times = await getTodayPrayerTimes();
    return times.nextPrayer;
  }

  /// تحديث الصلاة التالية في البيانات المؤقتة
  /// Update next prayer in cached data
  DailyPrayerTimes _updateNextPrayer(DailyPrayerTimes times) {
    final now = DateTime.now();

    // Find next prayer
    PrayerTimeData? nextPrayerData;
    for (final prayer in times.allPrayers) {
      if (prayer.time.isAfter(now)) {
        nextPrayerData = prayer;
        break;
      }
    }

    if (nextPrayerData == null) {
      // All prayers passed, next is tomorrow's Fajr
      return times;
    }

    // Update isNext flag
    return DailyPrayerTimes(
      fajr: times.fajr.copyWith(
          isNext: nextPrayerData.name == 'Fajr',
          timeUntil: times.fajr.time.isAfter(now)
              ? times.fajr.time.difference(now)
              : null),
      sunrise: times.sunrise.copyWith(
          isNext: nextPrayerData.name == 'Sunrise',
          timeUntil: times.sunrise.time.isAfter(now)
              ? times.sunrise.time.difference(now)
              : null),
      dhuhr: times.dhuhr.copyWith(
          isNext: nextPrayerData.name == 'Dhuhr',
          timeUntil: times.dhuhr.time.isAfter(now)
              ? times.dhuhr.time.difference(now)
              : null),
      asr: times.asr.copyWith(
          isNext: nextPrayerData.name == 'Asr',
          timeUntil: times.asr.time.isAfter(now)
              ? times.asr.time.difference(now)
              : null),
      maghrib: times.maghrib.copyWith(
          isNext: nextPrayerData.name == 'Maghrib',
          timeUntil: times.maghrib.time.isAfter(now)
              ? times.maghrib.time.difference(now)
              : null),
      isha: times.isha.copyWith(
          isNext: nextPrayerData.name == 'Isha',
          timeUntil: times.isha.time.isAfter(now)
              ? times.isha.time.difference(now)
              : null),
      date: times.date,
      hijriDate: times.hijriDate,
      gregorianDate: times.gregorianDate,
      cityName: times.cityName,
      countryName: times.countryName,
      latitude: times.latitude,
      longitude: times.longitude,
    );
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

  /// حساب التاريخ الهجري
  /// Calculate Hijri date
  String _calculateHijriDate(DateTime date) {
    try {
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

  /// الحصول على الوقت المتبقي للصلاة التالية
  /// Get time until next prayer
  Future<Duration?> getTimeUntilNextPrayer() async {
    final next = await nextPrayer();
    return next?.timeUntil;
  }

  /// تنسيق المدة للعرض
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

  /// تيار العد التنازلي للصلاة التالية
  /// Countdown stream to next prayer
  Stream<Duration?> get countdownStream async* {
    while (true) {
      final times = await getTodayPrayerTimes();
      final next = times.nextPrayer;
      if (next != null && next.timeUntil != null) {
        yield next.timeUntil;
      } else {
        yield null;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// تنظيف الموارد
  /// Dispose resources
  void dispose() {
    _settingsSubscription?.cancel();
    _prayerTimesController.close();
    _nextPrayerController.close();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// طرق حساب أوقات الصلاة
/// Prayer Calculation Methods
enum PrayerCalculationMethod {
  muslimWorldLeague('رابطة العالم الإسلامي', 'Muslim World League'),
  isna('أمريكا الشمالية - ISNA', 'ISNA'),
  ummAlQura('أم القرى - مكة', 'Umm al-Qura'),
  egyptian('الهيئة المصرية', 'Egyptian'),
  karachi('جامعة كراتشي', 'Karachi'),
  dubai('الإمارات', 'Dubai'),
  kuwait('الكويت', 'Kuwait'),
  qatar('قطر', 'Qatar'),
  singapore('سنغافورة', 'Singapore'),
  turkey('تركيا', 'Turkey'),
  automatic('حسب الموقع', 'Based on location');

  const PrayerCalculationMethod(this.arabicName, this.englishName);
  final String arabicName;
  final String englishName;
}

/// المذاهب الفقهية لحساب العصر
/// Madhab for Asr calculation
enum Madhab {
  shafi('الشافعي/المالكي/الحنبلي', 'Shafi'),
  hanafi('الحنفي', 'Hanafi');

  const Madhab(this.arabicName, this.englishName);
  final String arabicName;
  final String englishName;
}

/// أصوات الأذان المتاحة
/// Available Adhan Sounds
enum AdhanSound {
  makkah('مكة المكرمة', 'assets/audio/adhan/adhan_makkah.mp3'),
  madinah('المدينة المنورة', 'assets/audio/adhan/adhan_madinah.mp3'),
  alAqsa('الأقصى', 'assets/audio/adhan/adhan_aqsa.mp3'),
  egypt('مصر', 'assets/audio/adhan/adhan_egypt.mp3'),
  mishary('مشاري العفاسي', 'assets/audio/adhan/adhan_mishary.mp3'),
  system('صوت النظام', 'system'),
  local('أذان طمأنينة', 'assets/audio/adhan/adhan_local.mp3');

  const AdhanSound(this.displayName, this.assetPath);
  final String displayName;
  final String assetPath;
}

/// الخطوط العربية المتاحة
/// Available Arabic Fonts
enum ArabicFont {
  cairo('Cairo', 'القاهرة'),
  amiri('Amiri', 'أميري'),
  tajawal('Tajawal', 'تجوال'),
  scheherazade('Scheherazade New', 'شهرزاد'),
  notoNaskh('Noto Naskh Arabic', 'نوتو نسخ'),
  system('System', 'الافتراضي');

  const ArabicFont(this.fontFamily, this.arabicName);
  final String fontFamily;
  final String arabicName;
}

/// إعدادات الإشعار لكل صلاة
/// Per-Prayer Notification Settings
class PerPrayerSettings {
  final bool fajr;
  final bool sunrise;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;

  const PerPrayerSettings({
    this.fajr = true,
    this.sunrise = false,
    this.dhuhr = true,
    this.asr = true,
    this.maghrib = true,
    this.isha = true,
  });

  PerPrayerSettings copyWith({
    bool? fajr,
    bool? sunrise,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
  }) {
    return PerPrayerSettings(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  Map<String, bool> toMap() => {
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };

  factory PerPrayerSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PerPrayerSettings();
    return PerPrayerSettings(
      fajr: map['fajr'] ?? true,
      sunrise: map['sunrise'] ?? false,
      dhuhr: map['dhuhr'] ?? true,
      asr: map['asr'] ?? true,
      maghrib: map['maghrib'] ?? true,
      isha: map['isha'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PerPrayerSettings &&
      (fajr, sunrise, dhuhr, asr, maghrib, isha) ==
          (
            other.fajr,
            other.sunrise,
            other.dhuhr,
            other.asr,
            other.maghrib,
            other.isha,
          );

  @override
  int get hashCode => Object.hash(fajr, sunrise, dhuhr, asr, maghrib, isha);

  bool isEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
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
        return false;
    }
  }
}

/// إعدادات الموقع
/// Location Settings
class LocationSettings {
  final bool useAutoLocation;
  final double? manualLatitude;
  final double? manualLongitude;
  final String? cityName;
  final String? countryName;

  const LocationSettings({
    this.useAutoLocation = true,
    this.manualLatitude,
    this.manualLongitude,
    this.cityName,
    this.countryName,
  });

  @override
  bool operator ==(Object other) =>
      other is LocationSettings &&
      (
            useAutoLocation,
            manualLatitude,
            manualLongitude,
            cityName,
            countryName,
          ) ==
          (
            other.useAutoLocation,
            other.manualLatitude,
            other.manualLongitude,
            other.cityName,
            other.countryName,
          );

  @override
  int get hashCode => Object.hash(
    useAutoLocation,
    manualLatitude,
    manualLongitude,
    cityName,
    countryName,
  );

  LocationSettings copyWith({
    bool? useAutoLocation,
    double? manualLatitude,
    double? manualLongitude,
    String? cityName,
    String? countryName,
  }) {
    return LocationSettings(
      useAutoLocation: useAutoLocation ?? this.useAutoLocation,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
    );
  }

  Map<String, dynamic> toMap() => {
    'useAutoLocation': useAutoLocation,
    'manualLatitude': manualLatitude,
    'manualLongitude': manualLongitude,
    'cityName': cityName,
    'countryName': countryName,
  };

  factory LocationSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const LocationSettings();
    return LocationSettings(
      useAutoLocation: map['useAutoLocation'] ?? true,
      manualLatitude: map['manualLatitude']?.toDouble(),
      manualLongitude: map['manualLongitude']?.toDouble(),
      cityName: map['cityName'],
      countryName: map['countryName'],
    );
  }
}

/// نموذج إعدادات التطبيق الكاملة
/// Complete App Settings Model
class AppSettings {
  // Theme
  final ThemeMode themeMode;

  // Font
  final ArabicFont arabicFont;

  // Prayer Calculation
  final PrayerCalculationMethod calculationMethod;
  final Madhab madhab;

  // Location
  final LocationSettings locationSettings;

  // Notifications
  final bool notificationsEnabled;
  final PerPrayerSettings perPrayerEnabled;
  final int prePrayerOffsetMinutes;

  // Adhan
  final bool muadhinMode;
  final AdhanSound selectedAdhan;

  /// The adhan voice from the audio catalog. `local` is the bundled adhan.
  final String adhanVoiceId;
  final double adhanVolume;
  final bool vibrationEnabled;

  // Quiet Hours
  final bool quietHoursEnabled;
  final int quietHoursStart;
  final int quietHoursEnd;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.arabicFont = ArabicFont.cairo,
    this.calculationMethod = PrayerCalculationMethod.automatic,
    this.madhab = Madhab.shafi,
    this.locationSettings = const LocationSettings(),
    this.notificationsEnabled = true,
    this.perPrayerEnabled = const PerPrayerSettings(),
    this.prePrayerOffsetMinutes = 0,
    this.muadhinMode = true,
    this.selectedAdhan = AdhanSound.local,
    this.adhanVoiceId = 'local',
    this.adhanVolume = 1.0,
    this.vibrationEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    ArabicFont? arabicFont,
    PrayerCalculationMethod? calculationMethod,
    Madhab? madhab,
    LocationSettings? locationSettings,
    bool? notificationsEnabled,
    PerPrayerSettings? perPrayerEnabled,
    int? prePrayerOffsetMinutes,
    bool? muadhinMode,
    AdhanSound? selectedAdhan,
    String? adhanVoiceId,
    double? adhanVolume,
    bool? vibrationEnabled,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      arabicFont: arabicFont ?? this.arabicFont,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      locationSettings: locationSettings ?? this.locationSettings,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      perPrayerEnabled: perPrayerEnabled ?? this.perPrayerEnabled,
      prePrayerOffsetMinutes:
          prePrayerOffsetMinutes ?? this.prePrayerOffsetMinutes,
      muadhinMode: muadhinMode ?? this.muadhinMode,
      selectedAdhan: selectedAdhan ?? this.selectedAdhan,
      adhanVoiceId: adhanVoiceId ?? this.adhanVoiceId,
      adhanVolume: adhanVolume ?? this.adhanVolume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'arabicFont': arabicFont.index,
      'calculationMethod': calculationMethod.index,
      'madhab': madhab.index,
      'locationSettings': locationSettings.toMap(),
      'notificationsEnabled': notificationsEnabled,
      'perPrayerEnabled': perPrayerEnabled.toMap(),
      'prePrayerOffsetMinutes': prePrayerOffsetMinutes,
      'muadhinMode': muadhinMode,
      'selectedAdhan': selectedAdhan.index,
      'adhanVoiceId': adhanVoiceId,
      'adhanVolume': adhanVolume,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      arabicFont: ArabicFont.values[map['arabicFont'] ?? 0],
      calculationMethod:
          PrayerCalculationMethod.values[map['calculationMethod'] ??
              PrayerCalculationMethod.automatic.index],
      madhab: Madhab.values[map['madhab'] ?? 0],
      locationSettings: LocationSettings.fromMap(
        map['locationSettings'] as Map<String, dynamic>?,
      ),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      perPrayerEnabled: PerPrayerSettings.fromMap(
        map['perPrayerEnabled'] as Map<String, dynamic>?,
      ),
      prePrayerOffsetMinutes: map['prePrayerOffsetMinutes'] ?? 0,
      muadhinMode: map['muadhinMode'] ?? true,
      selectedAdhan:
          AdhanSound.values[map['selectedAdhan'] ?? AdhanSound.local.index],
      adhanVoiceId: map['adhanVoiceId'] is String
          ? map['adhanVoiceId'] as String
          : 'local',
      adhanVolume: (map['adhanVolume'] ?? 1.0).toDouble(),
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
      quietHoursStart: map['quietHoursStart'] ?? 22,
      quietHoursEnd: map['quietHoursEnd'] ?? 7,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.arabicFont == arabicFont &&
        other.calculationMethod == calculationMethod &&
        other.madhab == madhab &&
        other.locationSettings == locationSettings &&
        other.perPrayerEnabled == perPrayerEnabled &&
        other.notificationsEnabled == notificationsEnabled &&
        other.prePrayerOffsetMinutes == prePrayerOffsetMinutes &&
        other.muadhinMode == muadhinMode &&
        other.selectedAdhan == selectedAdhan &&
        other.adhanVoiceId == adhanVoiceId &&
        other.adhanVolume == adhanVolume &&
        other.vibrationEnabled == vibrationEnabled &&
        other.quietHoursEnabled == quietHoursEnabled &&
        other.quietHoursStart == quietHoursStart &&
        other.quietHoursEnd == quietHoursEnd;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      arabicFont,
      calculationMethod,
      madhab,
      locationSettings,
      perPrayerEnabled,
      notificationsEnabled,
      prePrayerOffsetMinutes,
      muadhinMode,
      selectedAdhan,
      adhanVoiceId,
      adhanVolume,
      vibrationEnabled,
      quietHoursEnabled,
      quietHoursStart,
      quietHoursEnd,
    );
  }
}

/// مستودع الإعدادات باستخدام Hive
/// Settings Repository using Hive for persistence
class SettingsRepository {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  Box? _box;
  final _settingsController = StreamController<AppSettings>.broadcast();

  AppSettings _currentSettings = const AppSettings();

  /// تيار للاستماع لتغييرات الإعدادات
  /// Stream to listen for settings changes
  Stream<AppSettings> get settingsStream => _settingsController.stream;

  /// الإعدادات الحالية
  /// Current settings
  AppSettings get currentSettings => _currentSettings;

  /// تهيئة المستودع
  /// Initialize repository
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    await _loadSettings();
  }

  /// تحميل الإعدادات من التخزين
  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final storedData = _box?.get(_settingsKey);
      if (storedData != null) {
        final Map<String, dynamic> map;
        if (storedData is String) {
          map = jsonDecode(storedData) as Map<String, dynamic>;
        } else if (storedData is Map) {
          map = Map<String, dynamic>.from(storedData);
        } else {
          map = {};
        }
        _currentSettings = AppSettings.fromMap(map);
      }
      _settingsController.add(_currentSettings);
    } catch (e) {
      // Use defaults on error
      _currentSettings = const AppSettings();
      _settingsController.add(_currentSettings);
    }
  }

  /// حفظ الإعدادات
  /// Save settings
  Future<void> saveSettings(AppSettings settings) async {
    _currentSettings = settings;
    await _box?.put(_settingsKey, jsonEncode(settings.toMap()));
    _settingsController.add(_currentSettings);
  }

  /// تحديث إعداد معين
  /// Update a specific setting
  Future<void> updateThemeMode(ThemeMode mode) async {
    await saveSettings(_currentSettings.copyWith(themeMode: mode));
  }

  Future<void> updateArabicFont(ArabicFont font) async {
    await saveSettings(_currentSettings.copyWith(arabicFont: font));
  }

  Future<void> updateCalculationMethod(PrayerCalculationMethod method) async {
    await saveSettings(_currentSettings.copyWith(calculationMethod: method));
  }

  Future<void> updateMadhab(Madhab madhab) async {
    await saveSettings(_currentSettings.copyWith(madhab: madhab));
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await saveSettings(
      _currentSettings.copyWith(notificationsEnabled: enabled),
    );
  }

  Future<void> updatePerPrayerSettings(PerPrayerSettings settings) async {
    await saveSettings(_currentSettings.copyWith(perPrayerEnabled: settings));
  }

  Future<void> updatePrePrayerOffset(int minutes) async {
    await saveSettings(
      _currentSettings.copyWith(prePrayerOffsetMinutes: minutes),
    );
  }

  Future<void> updateMuadhinMode(bool enabled) async {
    await saveSettings(_currentSettings.copyWith(muadhinMode: enabled));
  }

  Future<void> updateSelectedAdhan(AdhanSound adhan) async {
    await saveSettings(_currentSettings.copyWith(selectedAdhan: adhan));
  }

  Future<void> updateAdhanVoice(String id) async {
    await saveSettings(_currentSettings.copyWith(adhanVoiceId: id));
  }

  Future<void> updateAdhanVolume(double volume) async {
    await saveSettings(_currentSettings.copyWith(adhanVolume: volume));
  }

  Future<void> updateVibrationEnabled(bool enabled) async {
    await saveSettings(_currentSettings.copyWith(vibrationEnabled: enabled));
  }

  Future<void> updateLocationSettings(LocationSettings location) async {
    await saveSettings(_currentSettings.copyWith(locationSettings: location));
  }

  Future<void> updateQuietHours({bool? enabled, int? start, int? end}) async {
    await saveSettings(
      _currentSettings.copyWith(
        quietHoursEnabled: enabled,
        quietHoursStart: start,
        quietHoursEnd: end,
      ),
    );
  }

  /// إعادة تعيين الإعدادات إلى القيم الافتراضية
  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    await saveSettings(const AppSettings());
  }

  /// تنظيف الموارد
  /// Dispose resources
  void dispose() {
    _settingsController.close();
  }
}

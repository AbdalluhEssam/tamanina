import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_repository.dart';

/// حالات SettingsCubit
/// SettingsCubit States
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsLoaded && other.settings == settings;

  @override
  int get hashCode => settings.hashCode;
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);
}

/// كيوبت الإعدادات - يدير حالة الإعدادات ويتصل بالمستودع
/// Settings Cubit - Manages settings state and connects to repository
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;
  StreamSubscription<AppSettings>? _settingsSubscription;

  SettingsCubit({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsInitial()) {
    _init();
  }

  /// الإعدادات الحالية
  /// Current settings
  AppSettings get currentSettings {
    final state = this.state;
    if (state is SettingsLoaded) {
      return state.settings;
    }
    return _repository.currentSettings;
  }

  /// تهيئة الكيوبت
  /// Initialize cubit
  Future<void> _init() async {
    emit(const SettingsLoading());

    try {
      // Listen to repository changes
      _settingsSubscription = _repository.settingsStream.listen((settings) {
        emit(SettingsLoaded(settings));
      });

      // Initial load
      emit(SettingsLoaded(_repository.currentSettings));
    } catch (e) {
      emit(SettingsError('فشل في تحميل الإعدادات: $e'));
    }
  }

  /// تحديث وضع السمة
  /// Update theme mode
  Future<void> updateThemeMode(ThemeMode mode) async {
    await _repository.updateThemeMode(mode);
  }

  /// تحديث الخط العربي
  /// Update Arabic font
  Future<void> updateArabicFont(ArabicFont font) async {
    await _repository.updateArabicFont(font);
  }

  /// تحديث طريقة حساب الصلاة
  /// Update prayer calculation method
  Future<void> updateCalculationMethod(PrayerCalculationMethod method) async {
    await _repository.updateCalculationMethod(method);
  }

  /// تحديث المذهب
  /// Update madhab
  Future<void> updateMadhab(Madhab madhab) async {
    await _repository.updateMadhab(madhab);
  }

  /// تفعيل/تعطيل الإشعارات
  /// Enable/disable notifications
  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _repository.updateNotificationsEnabled(enabled);
  }

  /// تحديث إعدادات الإشعارات لكل صلاة
  /// Update per-prayer notification settings
  Future<void> updatePerPrayerSettings(PerPrayerSettings settings) async {
    await _repository.updatePerPrayerSettings(settings);
  }

  /// تحديث إشعار صلاة معينة
  /// Update notification for specific prayer
  Future<void> updatePrayerNotification(String prayer, bool enabled) async {
    final current = currentSettings.perPrayerEnabled;
    PerPrayerSettings updated;

    switch (prayer.toLowerCase()) {
      case 'fajr':
        updated = current.copyWith(fajr: enabled);
        break;
      case 'sunrise':
        updated = current.copyWith(sunrise: enabled);
        break;
      case 'dhuhr':
        updated = current.copyWith(dhuhr: enabled);
        break;
      case 'asr':
        updated = current.copyWith(asr: enabled);
        break;
      case 'maghrib':
        updated = current.copyWith(maghrib: enabled);
        break;
      case 'isha':
        updated = current.copyWith(isha: enabled);
        break;
      default:
        return;
    }

    await _repository.updatePerPrayerSettings(updated);
  }

  /// تحديث وقت التذكير قبل الصلاة
  /// Update pre-prayer reminder offset
  Future<void> updatePrePrayerOffset(int minutes) async {
    await _repository.updatePrePrayerOffset(minutes);
  }

  /// تفعيل/تعطيل وضع المؤذن
  /// Enable/disable muadhin mode
  Future<void> updateMuadhinMode(bool enabled) async {
    await _repository.updateMuadhinMode(enabled);
  }

  /// تحديث صوت الأذان المختار
  /// Update selected adhan sound
  Future<void> updateSelectedAdhan(AdhanSound adhan) async {
    await _repository.updateSelectedAdhan(adhan);
  }

  /// Choose the adhan voice from the audio catalog.
  Future<void> updateAdhanVoice(String id) async {
    await _repository.updateAdhanVoice(id);
  }

  /// تحديث مستوى صوت الأذان
  /// Update adhan volume
  Future<void> updateAdhanVolume(double volume) async {
    await _repository.updateAdhanVolume(volume);
  }

  /// تفعيل/تعطيل الاهتزاز
  /// Enable/disable vibration
  Future<void> updateVibrationEnabled(bool enabled) async {
    await _repository.updateVibrationEnabled(enabled);
  }

  /// تحديث إعدادات الموقع
  /// Update location settings
  Future<void> updateLocationSettings(LocationSettings location) async {
    await _repository.updateLocationSettings(location);
  }

  /// تعيين موقع يدوي
  /// Set manual location
  Future<void> setManualLocation({
    required double latitude,
    required double longitude,
    String? cityName,
    String? countryName,
  }) async {
    await _repository.updateLocationSettings(LocationSettings(
      useAutoLocation: false,
      manualLatitude: latitude,
      manualLongitude: longitude,
      cityName: cityName,
      countryName: countryName,
    ));
  }

  /// استخدام الموقع التلقائي
  /// Use automatic location
  Future<void> useAutoLocation() async {
    final current = currentSettings.locationSettings;
    await _repository.updateLocationSettings(
      current.copyWith(useAutoLocation: true),
    );
  }

  /// تحديث ساعات الهدوء
  /// Update quiet hours
  Future<void> updateQuietHours({
    bool? enabled,
    int? start,
    int? end,
  }) async {
    await _repository.updateQuietHours(
      enabled: enabled,
      start: start,
      end: end,
    );
  }

  /// حفظ جميع الإعدادات مرة واحدة
  /// Save all settings at once
  Future<void> saveAllSettings(AppSettings settings) async {
    await _repository.saveSettings(settings);
  }

  /// إعادة تعيين الإعدادات إلى القيم الافتراضية
  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}

/// Extension لتسهيل الوصول للإعدادات من BuildContext
/// Extension for easy access to settings from BuildContext
extension SettingsCubitExtension on BuildContext {
  SettingsCubit get settingsCubit => read<SettingsCubit>();

  AppSettings get appSettings {
    final state = read<SettingsCubit>().state;
    if (state is SettingsLoaded) {
      return state.settings;
    }
    return const AppSettings();
  }

  /// وضع السمة الحالي
  ThemeMode get currentThemeMode => appSettings.themeMode;

  /// هل الإشعارات مفعلة
  bool get areNotificationsEnabled => appSettings.notificationsEnabled;
}

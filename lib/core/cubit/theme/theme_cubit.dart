import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/settings_repository.dart';

part 'theme_state.dart';

/// كيوبت السمة - يدير وضع السمة (فاتح/داكن/نظام)
/// Theme Cubit - Manages theme mode (light/dark/system)
class ThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository? _settingsRepository;
  StreamSubscription<AppSettings>? _settingsSubscription;

  ThemeCubit({SettingsRepository? settingsRepository})
      : _settingsRepository = settingsRepository,
        super(ThemeState(_getInitialTheme(settingsRepository))) {
    _init();
  }

  /// الحصول على السمة الأولية من المستودع
  /// Get initial theme from repository
  static ThemeMode _getInitialTheme(SettingsRepository? repository) {
    if (repository != null) {
      return repository.currentSettings.themeMode;
    }
    return ThemeMode.system;
  }

  /// تهيئة الاستماع للتغييرات
  /// Initialize listening for changes
  void _init() {
    if (_settingsRepository != null) {
      _settingsSubscription =
          _settingsRepository.settingsStream.listen((settings) {
        if (state.themeMode != settings.themeMode) {
          emit(ThemeState(settings.themeMode));
        }
      });
    }
  }

  /// تغيير وضع السمة
  /// Change theme mode
  Future<void> changeTheme(ThemeMode newTheme) async {
    if (_settingsRepository != null) {
      await _settingsRepository.updateThemeMode(newTheme);
    }
    emit(ThemeState(newTheme));
  }

  /// التبديل بين الوضع الفاتح والداكن
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await changeTheme(newTheme);
  }

  /// تعيين وضع النظام
  /// Set system mode
  Future<void> useSystemTheme() async {
    await changeTheme(ThemeMode.system);
  }

  /// تعيين الوضع الفاتح
  /// Set light mode
  Future<void> useLightTheme() async {
    await changeTheme(ThemeMode.light);
  }

  /// تعيين الوضع الداكن
  /// Set dark mode
  Future<void> useDarkTheme() async {
    await changeTheme(ThemeMode.dark);
  }

  /// هل الوضع الحالي داكن
  /// Is current mode dark
  bool get isDarkMode {
    if (state.themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return state.themeMode == ThemeMode.dark;
  }

  /// هل الوضع الحالي فاتح
  /// Is current mode light
  bool get isLightMode {
    if (state.themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.light;
    }
    return state.themeMode == ThemeMode.light;
  }

  /// هل يستخدم وضع النظام
  /// Is using system mode
  bool get isSystemMode => state.themeMode == ThemeMode.system;

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}

/// Extension لتسهيل الوصول للسمة من BuildContext
/// Extension for easy access to theme from BuildContext
extension ThemeCubitExtension on BuildContext {
  ThemeCubit get themeCubit => read<ThemeCubit>();

  ThemeMode get currentThemeMode => read<ThemeCubit>().state.themeMode;

  bool get isDarkMode => read<ThemeCubit>().isDarkMode;

  bool get isLightMode => read<ThemeCubit>().isLightMode;

  /// تغيير السمة
  Future<void> changeTheme(ThemeMode mode) async {
    await read<ThemeCubit>().changeTheme(mode);
  }

  /// التبديل بين الأوضاع
  Future<void> toggleTheme() async {
    await read<ThemeCubit>().toggleTheme();
  }
}

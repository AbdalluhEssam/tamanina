import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

part 'theme_state.dart';

/// Controls the global light/dark theme for the application.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required SharedPreferences sharedPreferences})
      : _preferences = sharedPreferences,
        super(ThemeState(_loadInitial(sharedPreferences)));

  final SharedPreferences _preferences;

  static ThemeMode _loadInitial(SharedPreferences preferences) {
    final saved = preferences.getString(AppConstants.prefKeyTheme);
    switch (saved) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// Toggles between light and dark themes and persists the choice.
  Future<void> toggleTheme() async {
    final nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _persist(nextMode);
    emit(state.copyWith(themeMode: nextMode));
  }

  /// Explicitly sets the theme mode.
  Future<void> setTheme(ThemeMode mode) async {
    await _persist(mode);
    emit(state.copyWith(themeMode: mode));
  }

  /// Returns true when dark mode is active.
  bool isDarkModeEnabled() => state.themeMode == ThemeMode.dark;

  Future<void> _persist(ThemeMode mode) async {
    await _preferences.setString(AppConstants.prefKeyTheme, mode.name);
  }
}

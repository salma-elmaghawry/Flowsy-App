import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowsy/core/theme/controller/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences sharedPreferences;
  static const String themeModeKey = 'app_theme_mode';

  ThemeCubit(this.sharedPreferences)
    : super(ThemeState(themeMode: _getInitialThemeMode(sharedPreferences)));

  static ThemeMode _getInitialThemeMode(SharedPreferences prefs) {
    final modeString = prefs.getString(themeModeKey);
    if (modeString != null) {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await sharedPreferences.setString(themeModeKey, mode.toString());
  }

  ThemeMode getThemeMode() {
    final modeString = sharedPreferences.getString(themeModeKey);
    if (modeString != null) {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }

  Future<void> toggleThemeMode() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

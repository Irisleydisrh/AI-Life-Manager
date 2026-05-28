import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Cubit - Maneja el cambio entre modo oscuro y claro
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.dark);

  /// Cargar tema guardado
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    if (themeString == 'light') {
      emit(ThemeMode.light);
    } else if (themeString == 'dark') {
      emit(ThemeMode.dark);
    } else {
      // Por defecto, usar modo oscuro
      emit(ThemeMode.dark);
    }
  }

  /// Cambiar tema
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, newMode == ThemeMode.light ? 'light' : 'dark');

    emit(newMode);
  }

  /// Establecer tema específico
  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, mode == ThemeMode.light ? 'light' : 'dark');

    emit(mode);
  }

  /// Obtener si está en modo oscuro
  bool get isDark => state == ThemeMode.dark;
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final bool isDark = _prefs?.getBool('is_dark_mode') ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await _prefs?.setBool('is_dark_mode', isDark);
  }
  
  static Future<void> reset() async {
    themeMode.value = ThemeMode.light;
    await _prefs?.setBool('is_dark_mode', false);
  }
  
  static bool get isDarkMode => themeMode.value == ThemeMode.dark;
}

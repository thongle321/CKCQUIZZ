import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themePreferenceKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? theme = prefs.getString(_themePreferenceKey);
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> _saveThemePreference(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeString = 'light';
    if (themeMode == ThemeMode.dark) {
      themeString = 'dark';
    } else if (themeMode == ThemeMode.system) {
      themeString = 'system';
    }
    await prefs.setString(_themePreferenceKey, themeString);
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }
} 
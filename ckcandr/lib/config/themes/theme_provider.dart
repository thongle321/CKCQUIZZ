import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themePreferenceKey = 'themeMode';

  @override
  Future<ThemeMode> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? theme = prefs.getString(_themePreferenceKey);
    return switch (theme) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
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

  Future<void> toggleTheme() async {
    state = await AsyncValue.guard(() async {
      final currentMode = await future;
      final newMode = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      await _saveThemePreference(newMode);
      return newMode;
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = await AsyncValue.guard(() async {
      await _saveThemePreference(mode);
      return mode;
    });
  }
}
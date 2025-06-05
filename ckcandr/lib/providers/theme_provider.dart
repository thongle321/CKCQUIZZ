import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider để quản lý theme
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadThemePreference();
  }

  // Khởi tạo theme từ SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      // Nếu có lỗi, mặc định là theme sáng
      state = ThemeMode.light;
    }
  }

  // Thay đổi theme và lưu vào SharedPreferences
  Future<void> toggleTheme() async {
    final isDarkMode = state == ThemeMode.dark;
    state = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', !isDarkMode);
    } catch (e) {
      // Xử lý lỗi khi lưu preference
      print('Không thể lưu cài đặt theme: $e');
    }
  }
} 
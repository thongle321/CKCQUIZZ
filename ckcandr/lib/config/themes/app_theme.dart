import 'package:flutter/material.dart';

class AppTheme {
  // Định nghĩa các màu cơ bản cho app theo Figma
  static const Color primaryColor = Color(0xFF2196F3); // Màu xanh chính
  static const Color primaryLightColor = Color(0xFFE3F2FD); // Màu xanh nhạt
  static const Color backgroundColor = Color(0xFFF5F7FA); // Màu nền
  static const Color cardColor = Colors.white; // Màu card
  static const Color textPrimaryColor = Color(0xFF212121); // Màu chữ chính
  static const Color textSecondaryColor = Color(0xFF757575); // Màu chữ phụ

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryColor,
      onSecondary: Colors.white,
      surface: cardColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: primaryColor, width: 1.5),
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: const TextStyle(color: textSecondaryColor),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    ),
    dividerColor: Colors.grey.shade200,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineSmall: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: textSecondaryColor,
        fontSize: 12,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryColor,
      onSecondary: Colors.white,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.blue[300]!, width: 1.5),
        foregroundColor: Colors.blue[300],
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blue[300]!, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),
    textTheme: Typography.whiteMountainView.apply(bodyColor: Colors.white, displayColor: Colors.white).copyWith(
      bodyLarge: TextStyle(color: Colors.grey[300]),
      bodyMedium: TextStyle(color: Colors.grey[300]),
    ),
    iconTheme: IconThemeData(color: Colors.grey[300]),
    dividerColor: Colors.grey[700],
  );
} 
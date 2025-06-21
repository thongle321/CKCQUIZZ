import 'package:flutter/material.dart';
import 'package:ckcandr/models/user_model.dart';

/// Theme colors cho từng role
class RoleTheme {
  // Màu trắng đồng bộ cho tất cả role
  static const Color adminPrimary = Color(0xFF2D3748); // Xám đậm cho contrast
  static const Color adminSecondary = Color(0xFF4A5568);
  static const Color adminAccent = Color(0xFFF7FAFC);

  static const Color teacherPrimary = Color(0xFF2D3748); // Xám đậm cho contrast
  static const Color teacherSecondary = Color(0xFF4A5568);
  static const Color teacherAccent = Color(0xFFF7FAFC);

  static const Color studentPrimary = Color(0xFF1976D2); // Xanh dương như dashboard
  static const Color studentSecondary = Color(0xFF1565C0);
  static const Color studentAccent = Color(0xFFE3F2FD);

  /// Lấy theme data theo role
  static ThemeData getThemeByRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return _buildTheme(
          primary: adminPrimary,
          secondary: adminSecondary,
          accent: adminAccent,
        );
      case UserRole.giangVien:
        return _buildTheme(
          primary: teacherPrimary,
          secondary: teacherSecondary,
          accent: teacherAccent,
        );
      case UserRole.sinhVien:
        return _buildTheme(
          primary: studentPrimary,
          secondary: studentSecondary,
          accent: studentAccent,
        );
    }
  }

  /// Lấy màu primary theo role
  static Color getPrimaryColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminPrimary;
      case UserRole.giangVien:
        return teacherPrimary;
      case UserRole.sinhVien:
        return studentPrimary;
    }
  }

  /// Lấy màu secondary theo role
  static Color getSecondaryColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminSecondary;
      case UserRole.giangVien:
        return teacherSecondary;
      case UserRole.sinhVien:
        return studentSecondary;
    }
  }

  /// Lấy màu accent theo role
  static Color getAccentColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminAccent;
      case UserRole.giangVien:
        return teacherAccent;
      case UserRole.sinhVien:
        return studentAccent;
    }
  }

  /// Lấy tên role để hiển thị
  static String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.giangVien:
        return 'Giảng viên';
      case UserRole.sinhVien:
        return 'Sinh viên';
    }
  }

  /// Build theme data
  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color accent,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: accent,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accent,
        labelStyle: TextStyle(color: primary),
        side: BorderSide(color: secondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: accent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Widget để wrap các màn hình với theme theo role
class RoleThemedWidget extends StatelessWidget {
  final UserRole role;
  final Widget child;

  const RoleThemedWidget({
    super.key,
    required this.role,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RoleTheme.getThemeByRole(role),
      child: child,
    );
  }
}

/// Extension để lấy màu theo role từ context
extension RoleThemeExtension on BuildContext {
  Color getPrimaryColor(UserRole role) => RoleTheme.getPrimaryColor(role);
  Color getSecondaryColor(UserRole role) => RoleTheme.getSecondaryColor(role);
  Color getAccentColor(UserRole role) => RoleTheme.getAccentColor(role);
}

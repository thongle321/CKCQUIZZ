import 'package:flutter/foundation.dart';

/// Danh sách các vai trò người dùng trong hệ thống
enum UserRole {
  admin,
  giangVien,
  sinhVien,
}

/// Model dữ liệu người dùng
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? avatar;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
  });

  /// Tạo User từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _getRoleFromString(json['role'] as String),
      avatar: json['avatar'] as String?,
    );
  }

  /// Chuyển User sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': describeEnum(role),
      'avatar': avatar,
    };
  }

  /// Hàm phụ trợ để lấy role từ chuỗi
  static UserRole _getRoleFromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'giangvien':
        return UserRole.giangVien;
      case 'sinhvien':
        return UserRole.sinhVien;
      default:
        return UserRole.sinhVien;
    }
  }
} 
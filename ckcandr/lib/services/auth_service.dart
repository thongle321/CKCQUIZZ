import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';

/// Provider cho Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider cho User hiện tại
final currentUserProvider = StateProvider<User?>((ref) => null);

/// Provider kiểm tra người dùng đã đăng nhập chưa
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider cho role của người dùng hiện tại
final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// Constants cho Auth Service
class AuthConstants {
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
}

/// Service xử lý xác thực
class AuthService {
  /// Đăng nhập và lưu thông tin người dùng
  Future<User?> login(String email, String password) async {
    try {
      // TODO: Thay thế với API call thực tế
      // Phân loại người dùng dựa trên email
      
      if (email.toLowerCase() == 'admin@ckcquizz.com' && password == 'admin') {
        final user = User(
          id: '1',
          email: email,
          name: 'Admin',
          role: UserRole.admin,
        );
        await _saveUserData(user);
        return user;
      } else if (email.toLowerCase().contains('gv@') && password == 'giangvien') {
        final user = User(
          id: '2',
          email: email,
          name: 'Giảng Viên',
          role: UserRole.giangVien,
        );
        await _saveUserData(user);
        return user;
      } else if (email.toLowerCase().contains('sv@') && password == 'sinhvien') {
        final user = User(
          id: '3',
          email: email,
          name: 'Sinh Viên',
          role: UserRole.sinhVien,
        );
        await _saveUserData(user);
        return user;
      }
      
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthConstants.userTokenKey);
    await prefs.remove(AuthConstants.userDataKey);
  }

  /// Kiểm tra xem người dùng đã đăng nhập chưa
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    final userData = prefs.getString(AuthConstants.userDataKey);
    
    if (userData != null && userData.isNotEmpty) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
    
    return null;
  }

  /// Lưu thông tin người dùng vào SharedPreferences
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo token đơn giản (trong thực tế sẽ là JWT từ server)
    final token = base64Encode(utf8.encode('${user.id}:${user.email}:${DateTime.now().millisecondsSinceEpoch}'));
    
    // Lưu token
    await prefs.setString(AuthConstants.userTokenKey, token);
    
    // Lưu thông tin người dùng
    await prefs.setString(AuthConstants.userDataKey, jsonEncode(user.toJson()));
  }
} 
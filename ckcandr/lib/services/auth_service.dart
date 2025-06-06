import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';

/// Provider cho Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider để lưu trữ người dùng hiện tại
final currentUserProvider = StateProvider<User?>((ref) => null);

/// Provider để kiểm tra vai trò người dùng
final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.quyen;
});

/// Provider để kiểm tra người dùng đã đăng nhập chưa
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
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
    // Giả lập đăng nhập
    await Future.delayed(const Duration(seconds: 1));
    
    // Kiểm tra thông tin đăng nhập
    User? user;
    
    if (email == 'admin@ckc.edu.vn' && password == 'admin123') {
      user = User(
        id: '1',
        mssv: 'admin',
        hoVaTen: 'Admin',
        gioiTinh: true,
        email: email,
        quyen: UserRole.admin,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );
    } else if (email == 'giangvien@ckc.edu.vn' && password == 'giangvien123') {
      user = User(
        id: '2',
        mssv: 'GV001',
        hoVaTen: 'Giảng Viên',
        gioiTinh: true,
        email: email,
        quyen: UserRole.giangVien,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );
    } else if (email == 'sinhvien@ckc.edu.vn' && password == 'sinhvien123') {
      user = User(
        id: '3',
        mssv: '111111',
        hoVaTen: 'Sinh Viên',
        gioiTinh: true,
        email: email,
        quyen: UserRole.sinhVien,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );
    }
    
    // Lưu thông tin người dùng nếu đăng nhập thành công
    if (user != null) {
      await _saveUserData(user);
    }
    
    return user;
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    try {
      // Giả lập đăng xuất
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Xóa dữ liệu người dùng từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Xóa tất cả preferences để đảm bảo không còn dữ liệu đăng nhập
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      rethrow; // Ném lại ngoại lệ để xử lý ở tầng UI
    }
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
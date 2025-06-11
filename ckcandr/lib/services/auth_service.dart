import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/api_response_model.dart';
import 'package:ckcandr/services/http_client_service.dart';
import 'package:ckcandr/core/config/api_config.dart';

/// Provider cho Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  final httpClient = ref.read(httpClientServiceProvider);
  return AuthService(httpClient);
});

/// Constants cho Auth Service
class AuthConstants {
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
}

/// API-based Authentication Service
class AuthService {
  final HttpClientService _httpClient;

  AuthService(this._httpClient);

  /// API-based login with backend authentication
  Future<User?> login(String email, String password) async {
    try {
      print('🔐 Starting login process for: $email');

      // Create sign-in request
      final signInRequest = SignInRequest(
        email: email,
        password: password,
      );

      print('📤 Sending login request to: ${ApiConfig.signInEndpoint}');
      print('📤 Request data: ${signInRequest.toJson()}');

      // Make API call to backend
      final response = await _httpClient.post(
        ApiConfig.signInEndpoint,
        signInRequest.toJson(),
        (json) => AuthResponse.fromJson(json),
        includeAuth: false, // No auth needed for login
      );

      print('📥 Login response received:');
      print('   Success: ${response.success}');
      print('   Status Code: ${response.statusCode}');
      print('   Message: ${response.message}');
      print('   Data: ${response.data}');

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        print('✅ Login successful for: ${authResponse.email}');
        print('✅ User roles: ${authResponse.roles}');

        // Convert API roles to UserRole enum
        final userRole = _mapApiRoleToUserRole(authResponse.roles.first);

        // Create user object from API response
        final user = User(
          id: _generateUserIdFromEmail(authResponse.email),
          mssv: _generateMSSVFromEmail(authResponse.email),
          hoVaTen: _generateDisplayNameFromEmail(authResponse.email),
          gioiTinh: true, // Default value
          email: authResponse.email,
          quyen: userRole,
          ngayTao: DateTime.now(),
          ngayCapNhat: DateTime.now(),
        );

        // Save user data and roles
        await _saveUserData(user);
        await _saveUserRoles(authResponse.roles);

        print('✅ User data saved successfully');
        return user;
      } else {
        // Login failed
        print('❌ Login failed:');
        print('   Message: ${response.message}');
        print('   Status code: ${response.statusCode}');
        print('   Errors: ${response.errors}');
        return null;
      }
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  /// API-based logout with backend call
  Future<void> logout() async {
    try {
      // Call backend logout endpoint
      await _httpClient.postSimple(
        ApiConfig.signOutEndpoint,
        {},
        includeAuth: true,
      );
    } catch (e) {
      print('Logout API call failed: $e');
      // Continue with local cleanup even if API call fails
    }

    try {
      // Clear local authentication data
      await _httpClient.clearAuthData();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing local data: $e');
      rethrow;
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

    // Lưu thông tin người dùng
    await prefs.setString(AuthConstants.userDataKey, jsonEncode(user.toJson()));
  }

  /// Save user roles to SharedPreferences
  Future<void> _saveUserRoles(List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.userRolesKey, jsonEncode(roles));
  }

  /// Map API role string to UserRole enum
  UserRole _mapApiRoleToUserRole(String apiRole) {
    switch (apiRole.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.giangVien;
      case 'student':
        return UserRole.sinhVien;
      default:
        return UserRole.sinhVien; // Default to student
    }
  }

  /// Generate user ID from email (temporary solution)
  String _generateUserIdFromEmail(String email) {
    // Extract username part before @ and use as ID
    return email.split('@').first;
  }

  /// Generate MSSV from email (temporary solution)
  String _generateMSSVFromEmail(String email) {
    final username = email.split('@').first;
    // For admin, use 'admin', for others use the username
    if (username.toLowerCase() == 'admin') {
      return 'admin';
    } else if (username.toLowerCase().contains('teacher') || username.toLowerCase().contains('gv')) {
      return 'GV${username.hashCode.abs().toString().substring(0, 3)}';
    } else {
      return username.hashCode.abs().toString().substring(0, 6);
    }
  }

  /// Generate display name from email (temporary solution)
  String _generateDisplayNameFromEmail(String email) {
    final username = email.split('@').first;
    if (username.toLowerCase() == 'admin') {
      return 'Administrator';
    } else if (username.toLowerCase().contains('teacher') || username.toLowerCase().contains('gv')) {
      return 'Giảng viên';
    } else {
      return 'Sinh viên';
    }
  }
}
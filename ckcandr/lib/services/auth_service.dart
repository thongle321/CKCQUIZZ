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

  /// Parse login response - handle both TokenResponse and AuthResponse formats
  dynamic _parseLoginResponse(Map<String, dynamic> json) {
    // Check if response contains accessToken (TokenResponse format)
    if (json.containsKey('accessToken') && json.containsKey('refreshToken')) {
      return LoginResponse.fromJson(json);
    }
    // Otherwise, it's AuthResponse format (email + roles)
    else if (json.containsKey('email') && json.containsKey('roles')) {
      return AuthResponse.fromJson(json);
    }
    // Fallback - try to parse as LoginResponse
    else {
      throw Exception('Unknown response format: $json');
    }
  }

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

      // Make API call to backend - handle both TokenResponse and AuthResponse formats
      final response = await _httpClient.post(
        ApiConfig.signInEndpoint,
        signInRequest.toJson(),
        (json) => _parseLoginResponse(json),
        includeAuth: false, // No auth needed for login
      );

      print('📥 Login response received:');
      print('   Success: ${response.success}');
      print('   Status Code: ${response.statusCode}');
      print('   Message: ${response.message}');
      print('   Data: ${response.data}');

      if (response.success && response.data != null) {
        final responseData = response.data!;
        print('✅ Login successful - response received');
        print('   Response type: ${responseData.runtimeType}');

        // Handle different response formats
        if (responseData is LoginResponse) {
          // TokenResponse format - has accessToken and refreshToken
          print('   Access Token: ${responseData.accessToken.substring(0, 20)}...');
          print('   Refresh Token: ${responseData.refreshToken.substring(0, 20)}...');

          // Store authentication tokens for persistent login
          await _httpClient.storeAuthTokens(
            responseData.accessToken,
            responseData.refreshToken,
            expiryTime: DateTime.now().add(const Duration(hours: 24)),
          );
        } else if (responseData is AuthResponse) {
          // AuthResponse format - has email and roles, tokens are in cookies
          print('   Email: ${responseData.email}');
          print('   Roles: ${responseData.roles}');

          // For AuthResponse, we need to extract tokens from cookies or create dummy tokens
          // Since backend sets tokens in cookies, we'll create placeholder tokens
          await _httpClient.storeAuthTokens(
            'cookie_based_token', // Placeholder since tokens are in cookies
            'cookie_based_refresh_token',
            expiryTime: DateTime.now().add(const Duration(hours: 24)),
          );
        }

        // Get user info from token or make additional API call
        final user = await _getUserInfoFromToken(email);
        if (user != null) {
          // Save user data
          await _saveUserData(user);
          print('✅ User data and tokens saved successfully');
          return user;
        } else {
          print('❌ Failed to get user info after login');
          return null;
        }
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

      // Clear SharedPreferences (but preserve theme settings)
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      await prefs.clear();
      await prefs.setBool('isDarkMode', isDarkMode); // Restore theme setting

      print('✅ Logout completed successfully');
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

  /// Get user info from email (temporary solution until backend provides user info endpoint)
  Future<User?> _getUserInfoFromToken(String email) async {
    try {
      // For now, create user based on email pattern
      // In production, this should be an API call to get user details
      final userRole = _determineUserRoleFromEmail(email);

      final user = User(
        id: _generateUserIdFromEmail(email),
        mssv: _generateMSSVFromEmail(email),
        hoVaTen: _generateDisplayNameFromEmail(email),
        gioiTinh: true, // Default value
        email: email,
        quyen: userRole,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );

      return user;
    } catch (e) {
      print('Error creating user from email: $e');
      return null;
    }
  }

  /// Determine user role from email pattern
  UserRole _determineUserRoleFromEmail(String email) {
    if (email.toLowerCase().contains('admin')) {
      return UserRole.admin;
    } else if (email.toLowerCase().contains('teacher') || email.toLowerCase().contains('gv')) {
      return UserRole.giangVien;
    } else {
      return UserRole.sinhVien;
    }
  }

  /// Validate session by checking stored tokens
  Future<User?> validateSession() async {
    try {
      final isLoggedIn = await _httpClient.isLoggedIn();
      if (!isLoggedIn) {
        return null;
      }

      final isExpired = await _httpClient.isTokenExpired();
      if (isExpired) {
        // Try to refresh token
        final refreshed = await _refreshToken();
        if (!refreshed) {
          await logout(); // Clear invalid session
          return null;
        }
      }

      // Get stored user data
      return await getCurrentUser();
    } catch (e) {
      print('Error validating session: $e');
      return null;
    }
  }

  /// Refresh authentication token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _httpClient.getStoredRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _httpClient.post(
        ApiConfig.refreshTokenEndpoint,
        refreshRequest.toJson(),
        (json) => TokenResponse.fromJson(json),
        includeAuth: false,
      );

      if (response.success && response.data != null) {
        final tokenResponse = response.data!;
        await _httpClient.storeAuthTokens(
          tokenResponse.accessToken,
          tokenResponse.refreshToken,
          expiryTime: DateTime.now().add(const Duration(hours: 24)),
        );
        return true;
      }

      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
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
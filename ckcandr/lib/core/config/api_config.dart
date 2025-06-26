/// API Configuration for CKC Quiz Application
///
/// This file contains all API-related configuration including
/// base URLs, endpoints, and HTTP client setup for connecting
/// to the ASP.NET Core backend API.
library;

class ApiConfig {
  // MOBILE ONLY - API Configuration
  static const String baseUrl = 'http://192.168.0.18:7254';
  static const String apiBaseUrl = baseUrl;

  // API Endpoints
  static const String authEndpoint = '/api/Auth';
  static const String userEndpoint = '/api/NguoiDung';
  
  // Authentication specific endpoints
  static const String signInEndpoint = '$authEndpoint/signin';
  static const String signOutEndpoint = '$authEndpoint/logout';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh-token';
  static const String validateTokenEndpoint = '$authEndpoint/validate-token';
  static const String forgotPasswordEndpoint = '$authEndpoint/forgotpassword';
  static const String verifyOtpEndpoint = '$authEndpoint/verifyotp';
  static const String resetPasswordEndpoint = '$authEndpoint/resetpassword';
  
  // HTTP Client Configuration - Increased timeouts for VM connection
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Cookie and Token Configuration
  static const String accessTokenCookie = 'accessToken';
  static const String refreshTokenCookie = 'refreshToken';
  
  // Local Storage Keys
  static const String userDataKey = 'user_data';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRolesKey = 'user_roles';
  static const String isLoggedInKey = 'is_logged_in';
  static const String tokenExpiryKey = 'token_expiry';
  static const String lastLoginKey = 'last_login';
  
  // API Response Status Codes
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int internalServerErrorCode = 500;
  
  // Role Constants (matching backend)
  static const String adminRole = 'Admin';
  static const String teacherRole = 'Teacher';
  static const String studentRole = 'Student';
  
  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }
  
  // Helper method to check if response is successful
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
}

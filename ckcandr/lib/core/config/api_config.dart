/// API Configuration for CKC Quiz Application
///
/// This file contains all API-related configuration including
/// base URLs, endpoints, and HTTP client setup for connecting
/// to the ASP.NET Core backend API.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // MOBILE ONLY - API Configuration
  // SỬ DỤNG HTTPS VÀ DOMAIN ĐÚNG - CÓ "KING"
  static const bool useHttps = true; // DÙNG HTTPS
  static const String httpServerDomain = 'ckcquizz.ddnsking.com:7254'; // HTTP port (not used)
  static const String httpsServerDomain = 'ckcquizz.ddnsking.com:7254'; // HTTPS port - DOMAIN ĐÚNG CÓ "KING"

  // Fallback domains for network issues
  static const List<String> fallbackDomains = [
    'ckcquizz.ddnsking.com:7254', // Primary domain - DOMAIN ĐÚNG CÓ "KING"
    // TODO: Thay bằng IP thật của server (dùng: ping ckcquizz.ddnsking.com)
    '103.97.125.145:7254', // Example IP - thay bằng IP thật
    '192.168.1.100:7254', // Local network IP
    'localhost:7254', // For local development
    '10.0.2.2:7254', // Android emulator host
  ];

  static String get serverDomain => httpsServerDomain; // DÙNG HTTPS PORT 7254

  static String get baseUrl => useHttps
    ? 'https://$serverDomain'
    : 'http://$serverDomain';
  static String get apiBaseUrl => baseUrl;

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
  static const String changePasswordEndpoint = '$authEndpoint/change-password';
  static const String currentUserProfileEndpoint = '$authEndpoint/current-user-profile';
  static const String updateProfileEndpoint = '$authEndpoint/update-profile';
  
  // HTTP Client Configuration - Increased timeouts for server connection
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // SSL/TLS Configuration - FORCE BYPASS ALL VERIFICATION FOR DEVELOPMENT
  static const bool bypassSSL = true;
  static const bool allowSelfSignedCertificates = true;
  static const bool allowBadCertificates = true;
  
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

  // Helper methods để chuyển đổi protocol
  static String get httpUrl => 'http://$httpServerDomain';
  static String get httpsUrl => 'https://$httpsServerDomain';

  // Method để test kết nối với cả HTTP và HTTPS
  static String getUrlForProtocol(bool useHttps) {
    return useHttps ? httpsUrl : httpUrl;
  }

  // Method để test và tìm domain khả dụng
  static Future<String?> findWorkingDomain() async {
    debugPrint('🔍 Testing ${fallbackDomains.length} fallback domains...');

    for (String domain in fallbackDomains) {
      try {
        final testUrl = useHttps ? 'https://$domain' : 'http://$domain';
        debugPrint('🔍 Testing domain: $testUrl');

        // Create HTTP client with SSL bypass for IP addresses
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 3);
        client.badCertificateCallback = (cert, host, port) {
          // Always accept certificates for IP addresses or localhost
          final isIpOrLocal = RegExp(r'^(\d+\.){3}\d+$').hasMatch(host) ||
                             host.contains('localhost') ||
                             host.contains('127.0.0.1') ||
                             host.contains('10.0.2.2');
          if (isIpOrLocal) {
            debugPrint('🔓 Bypassing SSL for IP/localhost: $host');
            return true;
          }
          return false;
        };

        try {
          final uri = Uri.parse('$testUrl/api/Auth/validate-token');
          final request = await client.getUrl(uri);
          final response = await request.close();
          await response.drain();
          client.close();

          debugPrint('✅ Domain $domain is reachable (Status: ${response.statusCode})');
          return domain;
        } catch (e) {
          debugPrint('❌ Domain $domain failed: $e');
          client.close();
        }
      } catch (e) {
        debugPrint('❌ Error testing domain $domain: $e');
      }
    }

    debugPrint('❌ No working domain found from ${fallbackDomains.length} options');
    return null;
  }

  // Method để get base URL - TẠM THỜI TẮT FALLBACK SYSTEM
  static Future<String> getWorkingBaseUrl() async {
    // Tắt fallback system - trả về baseUrl trực tiếp
    return baseUrl;
  }
}

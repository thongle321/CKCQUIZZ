/// HTTP Client Service for CKC Quiz Application
/// 
/// This service provides a centralized HTTP client for making API calls
/// to the ASP.NET Core backend. It handles authentication tokens,
/// error responses, and provides a consistent interface for API communication.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/api_response_model.dart';

/// Provider for HTTP Client Service
final httpClientServiceProvider = Provider<HttpClientService>((ref) {
  return HttpClientService();
});

/// HTTP Client Service for API communication
class HttpClientService {
  late http.Client _client;

  HttpClientService() {
    _client = _createHttpClient();
  }

  /// Create HTTP client - simple for web compatibility
  http.Client _createHttpClient() {
    // Use simple HTTP client for web compatibility
    // Certificate issues will be handled by browser
    return http.Client();
  }

  /// Get headers with authentication token if available
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    
    if (includeAuth) {
      final token = await _getStoredToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  /// Get stored authentication token
  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConfig.tokenKey);
    } catch (e) {
      print('Error getting stored token: $e');
      return null;
    }
  }

  /// Store authentication token
  Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.tokenKey, token);
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  /// Clear stored authentication data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.tokenKey);
      await prefs.remove(ApiConfig.refreshTokenKey);
      await prefs.remove(ApiConfig.userDataKey);
      await prefs.remove(ApiConfig.userRolesKey);
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  /// Handle HTTP response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (ApiConfig.isSuccessResponse(response.statusCode)) {
        if (response.body.isEmpty) {
          return ApiResponse.success(null as T, statusCode: response.statusCode);
        }
        
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final data = fromJson(jsonData);
        return ApiResponse.success(data, statusCode: response.statusCode);
      } else {
        // Handle error response
        String errorMessage = 'Request failed';
        Map<String, dynamic>? errors;
        
        if (response.body.isNotEmpty) {
          try {
            final errorJson = jsonDecode(response.body);
            if (errorJson is String) {
              errorMessage = errorJson;
            } else if (errorJson is Map<String, dynamic>) {
              errorMessage = errorJson['message'] ?? 
                           errorJson['title'] ?? 
                           errorJson.toString();
              errors = errorJson['errors'] as Map<String, dynamic>?;
            }
          } catch (e) {
            errorMessage = response.body;
          }
        }
        
        return ApiResponse.error(
          errorMessage,
          statusCode: response.statusCode,
          errors: errors,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client.get(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);
      
      return _handleResponse(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP error occurred');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic POST request using HTTPS with certificate bypass
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final headers = await _getHeaders(includeAuth: includeAuth);
      final requestBody = jsonEncode(data);

      // Debug logging
      print('🌐 API Request:');
      print('   URL: $url');
      print('   Headers: $headers');
      print('   Body: $requestBody');

      final response = await _client.post(
        url,
        headers: headers,
        body: requestBody,
      ).timeout(ApiConfig.connectionTimeout);

      // Debug logging for response
      print('📥 API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      return _handleResponse(response, fromJson);

    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      return ApiResponse.error('Connection failed: $e');

    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      return ApiResponse.error('HTTP error: $e');

    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      return ApiResponse.error('Invalid response format: $e');

    } catch (e) {
      print('❌ General Exception: $e');
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// POST request without response body parsing (for simple responses)
  Future<ApiResponse<String>> postSimple(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (ApiConfig.isSuccessResponse(response.statusCode)) {
        return ApiResponse.success(
          response.body.isNotEmpty ? response.body : 'Success',
          statusCode: response.statusCode,
        );
      } else {
        String errorMessage = 'Request failed';
        if (response.body.isNotEmpty) {
          try {
            final errorJson = jsonDecode(response.body);
            if (errorJson is String) {
              errorMessage = errorJson;
            } else if (errorJson is Map<String, dynamic>) {
              errorMessage = errorJson['message'] ?? 
                           errorJson['title'] ?? 
                           errorJson.toString();
            }
          } catch (e) {
            errorMessage = response.body;
          }
        }
        
        return ApiResponse.error(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP error occurred');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

/// API Service for CKC Quiz Application
/// 
/// This service handles all HTTP communication with the ASP.NET Core backend API.
/// It provides methods for user management, authentication, and other API operations.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/http_client_service.dart';

/// Exception thrown when API calls fail
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorResponse? errorResponse;

  ApiException(this.message, {this.statusCode, this.errorResponse});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Main API service class
class ApiService {
  final HttpClientService _httpClient;

  ApiService(this._httpClient);



  /// Get all users with pagination and search
  Future<PagedResult<GetNguoiDungDTO>> getUsers({
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }

      final endpoint = '${ApiConfig.userEndpoint}?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => PagedResult<GetNguoiDungDTO>.fromJson(
          json,
          (itemJson) => GetNguoiDungDTO.fromJson(itemJson),
        ),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get users');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get users: $e');
    }
  }

  /// Get user by ID
  Future<GetNguoiDungDTO> getUserById(String id) async {
    try {
      final endpoint = '${ApiConfig.userEndpoint}/$id';

      final response = await _httpClient.get(
        endpoint,
        (json) => GetNguoiDungDTO.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get user');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get user: $e');
    }
  }

  /// Create new user
  Future<GetNguoiDungDTO> createUser(CreateNguoiDungRequestDTO request) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.userEndpoint,
        request.toJson(),
        (json) => GetNguoiDungDTO.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to create user');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create user: $e');
    }
  }

  /// Update user
  Future<void> updateUser(String id, UpdateNguoiDungRequestDTO request) async {
    try {
      final response = await _httpClient.putSimple(
        '${ApiConfig.userEndpoint}/$id',
        request.toJson(),
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to update user');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      final response = await _httpClient.deleteSimple(
        '${ApiConfig.userEndpoint}/$id',
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to delete user');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete user: $e');
    }
  }

  /// Get all available roles
  Future<List<String>> getRoles() async {
    try {
      final response = await _httpClient.getList(
        '${ApiConfig.userEndpoint}/roles',
        (json) => json.cast<String>(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get roles');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get roles: $e');
    }
  }
}

/// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return ApiService(httpClient);
});

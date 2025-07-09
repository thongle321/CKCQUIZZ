/// API Service for CKC Quiz Application
/// 
/// This service handles all HTTP communication with the ASP.NET Core backend API.
/// It provides methods for user management, authentication, and other API operations.

import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/models/role_management_model.dart';
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
    String? role,
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

      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
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

  /// Get current user profile
  Future<CurrentUserProfileDTO> getCurrentUserProfile() async {
    try {
      final response = await _httpClient.get(
        ApiConfig.currentUserProfileEndpoint,
        (json) => CurrentUserProfileDTO.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get current user profile');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get current user profile: $e');
    }
  }

  /// Update current user profile
  Future<void> updateCurrentUserProfile(UpdateUserProfileDTO request) async {
    try {
      final response = await _httpClient.putSimple(
        ApiConfig.updateProfileEndpoint,
        request.toJson(),
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to update profile');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update profile: $e');
    }
  }

  /// Upload avatar image
  Future<String> uploadAvatar(String imagePath) async {
    try {
      print('🔍 DEBUG Upload Avatar - START');
      print('   File path: $imagePath');

      final file = File(imagePath);
      final fileExists = await file.exists();
      print('   File exists: $fileExists');

      if (!fileExists) {
        print('❌ File not found at path: $imagePath');
        throw ApiException('File not found');
      }

      // Get file info
      final fileSize = await file.length();
      final fileName = path.basename(imagePath);
      final extension = path.extension(imagePath).toLowerCase();

      print('📁 File info:');
      print('   Name: $fileName');
      print('   Size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      print('   Extension: $extension');

      // Validate file size and format
      if (fileSize > 5 * 1024 * 1024) {
        print('❌ File too large: ${fileSize} bytes');
        throw ApiException('File quá lớn (>5MB)');
      }

      if (!['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
        print('❌ Invalid file format: $extension');
        throw ApiException('File format không hỗ trợ. Chỉ chấp nhận .jpg, .jpeg, .png, .gif');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/Files/upload-avatar'),
      );

      print('🌐 Request URL: ${request.url}');

      // Add authorization header
      final token = await _httpClient.getStoredAccessToken();
      final jwtToken = _httpClient.getJWTFromCookies();

      print('🔐 Auth info:');
      print('   Stored token: ${token != null ? "${token.substring(0, math.min(20, token.length))}..." : "null"}');
      print('   JWT from cookies: ${jwtToken != null ? "${jwtToken.substring(0, math.min(20, jwtToken.length))}..." : "null"}');

      if (token != null && token != 'cookie_jwt_auth_active') {
        request.headers['Authorization'] = 'Bearer $token';
        print('   Using stored token for auth');
      } else {
        if (jwtToken != null && jwtToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $jwtToken';
          print('   Using JWT from cookies for auth');
        } else {
          print('⚠️ No valid token found for authentication');
        }
      }

      // Add default headers
      request.headers['Accept'] = 'application/json';

      print('📤 Request headers: ${request.headers}');

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
          filename: fileName,
        ),
      );

      print('📎 File added to request: $fileName');
      print('🚀 Sending upload request...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Upload Response:');
      print('   Status code: ${streamedResponse.statusCode}');
      print('   Response headers: ${response.headers}');
      print('   Response body length: ${response.body.length}');
      print('   Response body: ${response.body}');

      if (streamedResponse.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            print('❌ Empty response body');
            throw ApiException('Server returned empty response');
          }

          final jsonResponse = json.decode(response.body);
          print('✅ Parsed JSON response: $jsonResponse');

          if (jsonResponse['url'] != null) {
            final imageUrl = jsonResponse['url'] as String;
            print('✅ Upload successful, image URL: $imageUrl');
            return imageUrl;
          } else {
            print('❌ No URL in response');
            throw ApiException('Server did not return image URL');
          }
        } catch (e) {
          print('❌ JSON parse error: $e');
          print('📄 Raw response: ${response.body}');
          throw ApiException('Invalid response format: $e');
        }
      } else {
        print('❌ Upload failed with status: ${streamedResponse.statusCode}');
        try {
          if (response.body.isNotEmpty) {
            final errorResponse = json.decode(response.body);
            print('📄 Error response: $errorResponse');
            throw ApiException(errorResponse['message'] ?? 'Failed to upload avatar');
          } else {
            throw ApiException('Upload failed with status ${streamedResponse.statusCode}');
          }
        } catch (e) {
          print('❌ Error parsing error response: $e');
          throw ApiException('Upload failed: ${response.body}');
        }
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw ApiException('No internet connection');
    } catch (e) {
      print('❌ Upload avatar error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload avatar: $e');
    }
  }

  /// Change password
  Future<void> changePassword(ChangePasswordDTO request) async {
    try {
      print('🔍 DEBUG Change Password - START');
      print('   Endpoint: ${ApiConfig.changePasswordEndpoint}');

      // Validate request data
      final requestData = request.toJson();
      print('📝 Request validation:');
      print('   Has currentPassword: ${requestData['currentPassword']?.toString().isNotEmpty == true}');
      print('   Has newPassword: ${requestData['newPassword']?.toString().isNotEmpty == true}');
      print('   Has confirmPassword: ${requestData['confirmPassword']?.toString().isNotEmpty == true}');
      print('   Current password length: ${requestData['currentPassword']?.toString().length ?? 0}');
      print('   New password length: ${requestData['newPassword']?.toString().length ?? 0}');
      print('   Passwords match: ${requestData['newPassword'] == requestData['confirmPassword']}');

      // Test authentication state before making request
      final token = await _httpClient.getStoredAccessToken();
      final jwtToken = _httpClient.getJWTFromCookies();

      print('🔐 Auth state:');
      print('   Stored token: ${token != null ? "${token.substring(0, math.min(20, token.length))}..." : "null"}');
      print('   JWT from cookies: ${jwtToken != null ? "${jwtToken.substring(0, math.min(20, jwtToken.length))}..." : "null"}');

      // Test current user endpoint first
      try {
        print('🧪 Testing current user endpoint...');
        final userResponse = await _httpClient.get(
          ApiConfig.currentUserProfileEndpoint,
          (json) => json,
        );
        print('👤 Current user test result: ${userResponse.success}');
        if (!userResponse.success) {
          print('❌ Current user test failed: ${userResponse.message}');
          print('   Status code: ${userResponse.statusCode}');
        } else {
          print('✅ Current user test successful');
        }
      } catch (e) {
        print('❌ Current user test error: $e');
      }

      print('🚀 Sending change password request...');
      print('   Request data: $requestData');

      final response = await _httpClient.postSimple(
        ApiConfig.changePasswordEndpoint,
        requestData,
      );

      print('📥 Change Password Response:');
      print('   Success: ${response.success}');
      print('   Status code: ${response.statusCode}');
      print('   Message: ${response.message}');
      print('   Data: ${response.data}');

      if (!response.success) {
        print('❌ Change password failed');
        print('   Error message: ${response.message}');
        print('   Status code: ${response.statusCode}');
        throw ApiException(response.message ?? 'Failed to change password');
      } else {
        print('✅ Change password successful');
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw ApiException('No internet connection');
    } catch (e) {
      print('❌ Change password error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to change password: $e');
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

  /// Get all teachers for dropdown selection
  Future<List<GetNguoiDungDTO>> getTeachers() async {
    try {
      final queryParams = <String, String>{
        'role': 'Teacher', // Filter by Teacher role
        'pageSize': '100', // Get enough teachers for dropdown
      };

      final endpoint = '${ApiConfig.userEndpoint}?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => PagedResult<GetNguoiDungDTO>.fromJson(
          json,
          (itemJson) => GetNguoiDungDTO.fromJson(itemJson),
        ),
      );

      if (response.success) {
        // Client-side filtering as fallback if server-side filtering doesn't work
        final teachers = response.data!.items.where((user) =>
          user.currentRole?.toLowerCase() == 'teacher'
        ).toList();
        return teachers;
      } else {
        throw ApiException(response.message ?? 'Failed to get teachers');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get teachers: $e');
    }
  }

  // ===== SUBJECT (MON HOC) METHODS =====

  /// Get all subjects
  Future<List<ApiMonHoc>> getSubjects() async {
    try {
      final response = await _httpClient.getList(
        '/api/MonHoc',
        (jsonList) => jsonList.map((json) => ApiMonHoc.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get subjects');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get subjects: $e');
    }
  }

  /// Create new subject
  Future<ApiMonHoc> createSubject(CreateMonHocRequestDTO request) async {
    try {
      final response = await _httpClient.post(
        '/api/MonHoc',
        request.toJson(),
        (json) => ApiMonHoc.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to create subject');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create subject: $e');
    }
  }

  /// Update subject
  Future<void> updateSubject(int maMonHoc, UpdateMonHocRequestDTO request) async {
    try {
      final response = await _httpClient.putSimple(
        '/api/MonHoc/$maMonHoc',
        request.toJson(),
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to update subject');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update subject: $e');
    }
  }

  /// Delete subject
  Future<void> deleteSubject(int maMonHoc) async {
    try {
      final response = await _httpClient.deleteSimple('/api/MonHoc/$maMonHoc');

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to delete subject');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete subject: $e');
    }
  }

  // ===== CLASS (LOP HOC) METHODS =====

  /// Get all classes
  Future<List<LopHoc>> getClasses({bool? hienthi}) async {
    try {
      final queryParams = <String, String>{};
      if (hienthi != null) {
        queryParams['hienthi'] = hienthi.toString();
      }

      final endpoint = queryParams.isEmpty
          ? '/api/Lop'
          : '/api/Lop?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.getList(
        endpoint,
        (jsonList) => jsonList.map((json) => LopHoc.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get classes');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get classes: $e');
    }
  }

  /// Get class by ID
  Future<LopHoc> getClassById(int id) async {
    try {
      final response = await _httpClient.get(
        '/api/Lop/$id',
        (json) => LopHoc.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get class: $e');
    }
  }

  /// Create new class
  Future<LopHoc> createClass(CreateLopRequestDTO request) async {
    try {
      final response = await _httpClient.post(
        '/api/Lop',
        request.toJson(),
        (json) => LopHoc.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to create class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create class: $e');
    }
  }

  /// Update class
  Future<LopHoc> updateClass(int id, UpdateLopRequestDTO request) async {
    try {
      final response = await _httpClient.put(
        '/api/Lop/$id',
        request.toJson(),
        (json) => LopHoc.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to update class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update class: $e');
    }
  }

  /// Delete class
  Future<void> deleteClass(int id) async {
    try {
      final response = await _httpClient.deleteSimple('/api/Lop/$id');

      if (!response.success) {
        // Check for specific error messages related to foreign key constraints
        String errorMessage = response.message ?? 'Failed to delete class';

        if (errorMessage.contains('REFERENCE constraint') ||
            errorMessage.contains('conflicted') ||
            errorMessage.contains('foreign key')) {
          throw ApiException('Không thể xóa lớp này vì đã có học sinh tham gia hoặc có đề thi liên quan. Vui lòng ẩn lớp thay vì xóa.');
        }

        throw ApiException(errorMessage);
      }
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } catch (e) {
      if (e is ApiException) rethrow;

      // Handle specific database constraint errors
      String errorStr = e.toString();
      if (errorStr.contains('REFERENCE constraint') ||
          errorStr.contains('conflicted') ||
          errorStr.contains('foreign key')) {
        throw ApiException('Không thể xóa lớp này vì đã có học sinh tham gia hoặc có đề thi liên quan. Vui lòng ẩn lớp thay vì xóa.');
      }

      throw ApiException('Lỗi khi xóa lớp: $e');
    }
  }

  /// Toggle class status
  Future<void> toggleClassStatus(int id, bool hienthi) async {
    try {
      final response = await _httpClient.putSimple(
        '/api/Lop/$id/toggle-status?hienthi=$hienthi',
        {},
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to toggle class status');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to toggle class status: $e');
    }
  }

  /// Toggle exam status (enable/disable exam)
  Future<void> toggleExamStatus(int examId, bool trangthai) async {
    try {
      debugPrint('🔄 API: Toggling exam status for examId: $examId, status: $trangthai');

      final response = await _httpClient.putSimple(
        '/api/DeThi/$examId/toggle-status?trangthai=$trangthai',
        {},
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to toggle exam status');
      }

      debugPrint('✅ API: Toggle exam status successful');
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Toggle exam status error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to toggle exam status: $e');
    }
  }

  /// Refresh invite code
  Future<String> refreshInviteCode(int id) async {
    try {
      final response = await _httpClient.post(
        '/api/Lop/$id/invite-code',
        {},
        (json) => json['inviteCode'] as String,
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to refresh invite code');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to refresh invite code: $e');
    }
  }

  // ===== STUDENT MANAGEMENT METHODS =====

  /// Get students in class with pagination
  Future<PagedResult<GetNguoiDungDTO>> getStudentsInClass(
    int classId, {
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }

      final endpoint = '/api/Lop/$classId/students?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => PagedResult<GetNguoiDungDTO>.fromJson(
          json,
          (item) => GetNguoiDungDTO.fromJson(item),
        ),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get students in class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get students in class: $e');
    }
  }

  /// Get teachers in class
  Future<List<GetNguoiDungDTO>> getTeachersInClass(int classId) async {
    try {
      final response = await _httpClient.getList(
        '/api/Lop/$classId/teachers',
        (jsonList) => jsonList.map((json) => GetNguoiDungDTO.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get teachers in class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get teachers in class: $e');
    }
  }

  /// Add student to class
  Future<void> addStudentToClass(int classId, String studentId) async {
    try {
      final response = await _httpClient.postSimple(
        '/api/Lop/$classId/students',
        {'manguoidungId': studentId},
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to add student to class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to add student to class: $e');
    }
  }

  /// Remove student from class
  Future<void> removeStudentFromClass(int classId, String studentId) async {
    try {
      final response = await _httpClient.deleteSimple('/api/Lop/$classId/students/$studentId');

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to remove student from class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to remove student from class: $e');
    }
  }

  /// Get pending join requests count for a class
  /// Note: This is a placeholder - API endpoint needs to be implemented on server
  Future<int> getPendingRequestsCount(int classId) async {
    try {
      // TODO: Replace with actual API endpoint when available
      // For now, return 0 as placeholder
      return 0;
    } catch (e) {
      return 0; // Return 0 on error to avoid breaking UI
    }
  }

  /// Get subjects with groups for notifications
  Future<List<MonHocWithNhomLopDTO>> getSubjectsWithGroups({bool? hienthi}) async {
    try {
      final queryParams = <String, String>{};
      if (hienthi != null) {
        queryParams['hienthi'] = hienthi.toString();
      }

      final endpoint = queryParams.isEmpty
          ? '/api/Lop/subjects-with-groups'
          : '/api/Lop/subjects-with-groups?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.getList(
        endpoint,
        (jsonList) => jsonList.map((json) => MonHocWithNhomLopDTO.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get subjects with groups');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get subjects with groups: $e');
    }
  }

  // ===== EXAM TAKING METHODS =====

  /// Get all exams for current student
  Future<List<ExamForStudent>> getMyExams() async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/my-exams',
        (jsonList) => jsonList.map((item) => ExamForStudent.fromJson(item as Map<String, dynamic>)).toList(),
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get my exams');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get my exams: $e');
    }
  }

  /// Get exams for a specific class (student taking view)
  Future<List<ExamForStudent>> getStudentExamsForClass(int classId) async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/class/$classId',
        (jsonList) => jsonList.map((item) => ExamForStudent.fromJson(item as Map<String, dynamic>)).toList(),
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get class exams');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get class exams: $e');
    }
  }

  /// Get exam questions for taking exam
  Future<List<ExamQuestion>> getExamQuestions(int examId) async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/$examId/questions-for-student',
        (jsonList) => jsonList.map((item) => ExamQuestion.fromJson(item as Map<String, dynamic>)).toList(),
      );

      if (response.success) {
        debugPrint('✅ Exam questions loaded: ${response.data?.length ?? 0} questions');
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get exam questions');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam questions: $e');
    }
  }

  // ===== EXAM TAKING METHODS (Match Vue.js exactly) =====

  /// Start exam - Tạo session thi cho sinh viên (match Vue.js /Exam/start)
  Future<Map<String, dynamic>> startExam(int examId) async {
    try {
      debugPrint('🚀 API: Starting exam with ID: $examId');

      final response = await _httpClient.post(
        '/api/Exam/start',
        {
          'ExamId': examId,
        },
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        debugPrint('✅ API: Start exam successful: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(response.message ?? 'Failed to start exam');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Start exam error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to start exam: $e');
    }
  }

  /// Get exam details - Lấy chi tiết đề thi cho sinh viên làm bài (match Vue.js /Exam/{examId})
  Future<Map<String, dynamic>> getExamDetails(int examId) async {
    try {
      debugPrint('📝 API: Getting exam questions for exam ID: $examId');

      final response = await _httpClient.get(
        '/api/Exam/$examId',
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        debugPrint('✅ API: Get exam questions successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam questions');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Get exam questions error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam questions: $e');
    }
  }

  /// Update exam answer - Cập nhật đáp án sinh viên (real-time, match Vue.js /Exam/update-answer)
  Future<void> updateExamAnswer({
    required int ketQuaId,
    required int macauhoi,
    int? macautl, // nullable cho essay questions
    int dapansv = 1,
    String? dapantuluansv,
  }) async {
    try {
      debugPrint('💾 API: Updating answer - KetQuaId: $ketQuaId, Macauhoi: $macauhoi, Macautl: $macautl, Essay: $dapantuluansv');

      final requestData = <String, dynamic>{
        'KetQuaId': ketQuaId,
        'Macauhoi': macauhoi,
        'Dapansv': dapansv,
      };

      // Thêm macautl cho multiple choice
      if (macautl != null) {
        requestData['Macautl'] = macautl;
      }

      // Thêm đáp án tự luận nếu có
      if (dapantuluansv != null) {
        requestData['Dapantuluansv'] = dapantuluansv;
      }

      // Server endpoint là POST method, không phải PUT
      final response = await _httpClient.postSimple(
        '/api/Exam/update-answer',
        requestData,
      );

      if (response.success) {
        debugPrint('✅ API: Update answer successful');
      } else {
        debugPrint('❌ API: Update answer failed: ${response.message}');
        throw ApiException(response.message ?? 'Failed to update answer');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Update answer error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update answer: $e');
    }
  }

  /// Submit exam - Match Vue.js /Exam/submit endpoint
  Future<Map<String, dynamic>> submitExam({
    required int ketQuaId,
    required int examId,
    int? thoiGianLamBai,
  }) async {
    try {
      debugPrint('📤 API: Submitting exam - KetQuaId: $ketQuaId, ExamId: $examId');

      final response = await _httpClient.post(
        '/api/Exam/submit',
        {
          'KetQuaId': ketQuaId,
          'ExamId': examId,
          'thoiGianLamBai': thoiGianLamBai,
        },
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        debugPrint('✅ API: Submit exam successful: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(response.message ?? 'Failed to submit exam');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Submit exam error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit exam: $e');
    }
  }

  /// Get exam result details - Lấy chi tiết kết quả bài thi
  Future<Map<String, dynamic>> getExamResultDetails(int ketQuaId) async {
    try {
      debugPrint('📖 API: Getting exam result details for KetQuaId: $ketQuaId');

      final response = await _httpClient.get(
        '/api/Exam/result/$ketQuaId',
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        debugPrint('✅ API: Get exam result details successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam result details');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Get exam result details error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam result details: $e');
    }
  }

  /// Get my exams for student - Match Vue.js /DeThi/my-exams endpoint
  Future<List<dynamic>> getMyExamsForStudent() async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/my-exams',
        (jsonList) => jsonList,
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get my exams');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get my exams: $e');
    }
  }

  /// Submit exam answers (Legacy method - keep for backward compatibility)
  Future<ExamResult> submitExamLegacy(SubmitExamRequest request) async {
    try {
      final response = await _httpClient.post(
        '/api/KetQua/submit',
        request.toJson(),
        (json) => ExamResult.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to submit exam');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit exam: $e');
    }
  }

  /// Get exam result by ID
  Future<ExamResult> getExamResult(int resultId) async {
    try {
      final response = await _httpClient.get(
        '/api/KetQua/$resultId',
        (json) => ExamResult.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam result');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam result: $e');
    }
  }

  /// Get all results for an exam (for teachers) - includes all students in assigned classes
  Future<TestResultResponse> getExamResults(int examId) async {
    try {
      debugPrint('📊 API: Getting exam results for examId: $examId');

      final response = await _httpClient.get(
        '/api/DeThi/results/$examId',
        (json) => TestResultResponse.fromJson(json),
      );

      if (response.success) {
        debugPrint('✅ API: Get exam results successful - ${response.data?.results.length} students found');
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam results');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Get exam results error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam results: $e');
    }
  }

  /// Get legacy exam results (only students who took the exam) - for backward compatibility
  Future<List<ExamResult>> getLegacyExamResults(int examId) async {
    try {
      final response = await _httpClient.getList(
        '/api/KetQua/exam/$examId',
        (jsonList) => jsonList.map((item) => ExamResult.fromJson(item as Map<String, dynamic>)).toList(),
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get exam results');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam results: $e');
    }
  }

  /// Get detailed result with answers for a specific student
  Future<ExamResultDetail> getExamResultDetail(int resultId) async {
    try {
      debugPrint('📊 API: Getting exam result detail for resultId: $resultId');

      final response = await _httpClient.get(
        '/api/KetQua/$resultId/detail',
        (json) => ExamResultDetail.fromJson(json),
      );

      if (response.success) {
        debugPrint('✅ API: Get exam result detail successful');
        return response.data!;
      } else {
        debugPrint('❌ API: Get exam result detail failed: ${response.message}');
        throw ApiException(response.message ?? 'Failed to get exam result detail');
      }
    } on SocketException {
      debugPrint('❌ API: No internet connection for exam result detail');
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Get exam result detail error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam result detail: $e');
    }
  }

  /// Get student exam result from ExamController (alternative API)
  Future<Map<String, dynamic>?> getStudentExamResult(int ketQuaId) async {
    try {
      debugPrint('📊 API: Getting student exam result for ketQuaId: $ketQuaId');

      final response = await _httpClient.get(
        '/api/Exam/exam-result/$ketQuaId',
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        debugPrint('✅ API: Get student exam result successful');
        return response.data as Map<String, dynamic>;
      } else {
        debugPrint('❌ API: Get student exam result failed: ${response.message}');
        throw ApiException(response.message ?? 'Failed to get student exam result');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Get student exam result error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get student exam result: $e');
    }
  }

  /// Get exam permissions for student result viewing
  Future<Map<String, dynamic>?> getExamPermissions(int examId) async {
    try {
      debugPrint('🔐 API: Getting exam permissions for examId: $examId');

      // Try to get exam details which should include permissions
      final response = await _httpClient.get(
        '/api/DeThi/$examId',
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('✅ API: Get exam permissions successful');

        // Extract permission fields if they exist
        return {
          'hienthibailam': data['hienthibailam'] ?? false,
          'xemdiemthi': data['xemdiemthi'] ?? false,
          'xemdapan': data['xemdapan'] ?? false,
        };
      } else {
        debugPrint('❌ API: Get exam permissions failed: ${response.message}');
        // Return default permissions (all false) if API fails
        return {
          'hienthibailam': false,
          'xemdiemthi': false,
          'xemdapan': false,
        };
      }
    } on SocketException {
      debugPrint('❌ API: No internet connection for exam permissions');
      // Return default permissions if no internet
      return {
        'hienthibailam': false,
        'xemdiemthi': false,
        'xemdapan': false,
      };
    } catch (e) {
      debugPrint('❌ API: Get exam permissions error: $e');
      // Return default permissions if any error occurs
      return {
        'hienthibailam': false,
        'xemdiemthi': false,
        'xemdapan': false,
      };
    }
  }

  /// Export exam results to Excel/PDF
  Future<String> exportExamResults(int examId, String format) async {
    try {
      debugPrint('📤 API: Exporting exam results - ExamId: $examId, Format: $format');

      // Sử dụng endpoint DeThi để export kết quả thi
      final response = await _httpClient.get(
        '/api/DeThi/$examId/export?format=$format',
        (json) => json['downloadUrl'] as String,
      );

      if (response.success) {
        debugPrint('✅ API: Export exam results successful');
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to export exam results');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      debugPrint('❌ API: Export exam results error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to export exam results: $e');
    }
  }

  // ===== NOTIFICATION METHODS =====

  /// Get notifications for user (student) - DEPRECATED
  /// Use getStudentNotifications instead
  @Deprecated('Use getStudentNotifications instead')
  Future<List<dynamic>> getNotificationsForUser(String userId) async {
    try {
      // Redirect to new method
      final result = await getStudentNotifications(userId: userId);
      return result['items'] as List<dynamic>;
    } catch (e) {
      throw ApiException('Failed to get notifications: $e');
    }
  }

  /// Get notifications for current teacher
  Future<List<dynamic>> getMyNotifications({int page = 1, int pageSize = 10, String? search}) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final endpoint = '/api/ThongBao/me?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.getList(
        endpoint,
        (jsonList) => jsonList,
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get my notifications');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get my notifications: $e');
    }
  }

  /// Get student notifications - Uses /api/ThongBao endpoint with proper pagination
  /// This endpoint returns paginated notifications with new format
  Future<Map<String, dynamic>> getStudentNotifications({
    required String userId,
    int page = 1,
    int pageSize = 10,
    String? search
  }) async {
    try {
      // Build query parameters for server-side pagination
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Use the general ThongBao endpoint with pagination parameters
      final endpoint = '/api/ThongBao?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => json,
      );

      if (response.success) {
        final responseData = response.data as Map<String, dynamic>;
        final totalCount = responseData['totalCount'] as int;
        final items = responseData['items'] as List<dynamic>;

        // Convert items to ThongBao objects using new format
        final notifications = items.map((item) =>
          ThongBao.fromNewApiFormat(item as Map<String, dynamic>)
        ).toList();

        return {
          'items': notifications,
          'totalCount': totalCount,
          'currentPage': page,
          'pageSize': pageSize,
        };
      } else {
        throw ApiException(response.message ?? 'Failed to get student notifications');
      }
    } catch (e) {
      // WORKAROUND: Fallback to mock data if API fails
      if (e.toString().contains('Manhom') || e.toString().contains('FromSql')) {
        print('🔧 WORKAROUND: Backend SQL error detected, using mock notifications');
        return _getMockStudentNotifications(userId, page, pageSize, search);
      }
      print('❌ Error getting notifications: $e');
      rethrow;
    }
  }

  /// Mock notifications for demo when backend has SQL error
  Map<String, dynamic> _getMockStudentNotifications(String userId, int page, int pageSize, String? search) {
    final mockNotifications = [
      ThongBao(
        maTb: 1,
        noiDung: '📢 Thông báo: Bài kiểm tra giữa kỳ môn Lập Trình Căn Bản sẽ được tổ chức vào ngày 15/07/2025. Thời gian: 90 phút. Hình thức: Trực tuyến.',
        tenMonHoc: 'Lập Trình Căn Bản',
        thoiGianTao: DateTime.now().subtract(const Duration(hours: 2)),
        hoTenNguoiTao: 'Thầy Nguyễn Văn A',
        avatarNguoiTao: null,
        tenLop: 'DHCNTT16A',
        maLop: 1,
        type: NotificationType.examNew,
        isRead: false,
      ),
      ThongBao(
        maTb: 2,
        noiDung: '📚 Thông báo: Tài liệu bài giảng chương 5 đã được cập nhật. Sinh viên vui lòng tải về và ôn tập.',
        tenMonHoc: 'Lập Trình Căn Bản',
        thoiGianTao: DateTime.now().subtract(const Duration(days: 1)),
        hoTenNguoiTao: 'Thầy Nguyễn Văn A',
        avatarNguoiTao: null,
        tenLop: 'DHCNTT16A',
        maLop: 1,
        type: NotificationType.general,
        isRead: true,
      ),
      ThongBao(
        maTb: 3,
        noiDung: '⏰ Nhắc nhở: Hạn nộp bài tập lớn là 20/07/2025. Sinh viên chưa nộp vui lòng hoàn thành và nộp đúng hạn.',
        tenMonHoc: 'Lập Trình Căn Bản',
        thoiGianTao: DateTime.now().subtract(const Duration(days: 2)),
        hoTenNguoiTao: 'Thầy Nguyễn Văn A',
        avatarNguoiTao: null,
        tenLop: 'DHCNTT16A',
        maLop: 1,
        type: NotificationType.general,
        isRead: false,
      ),
    ];

    // Apply search filter if provided
    List<ThongBao> filteredItems = mockNotifications;
    if (search != null && search.isNotEmpty) {
      filteredItems = mockNotifications.where((item) =>
        item.noiDung.toLowerCase().contains(search.toLowerCase()) ||
        (item.tenMonHoc?.toLowerCase().contains(search.toLowerCase()) ?? false) ||
        (item.hoTenNguoiTao?.toLowerCase().contains(search.toLowerCase()) ?? false)
      ).toList();
    }

    // Apply pagination
    final totalCount = filteredItems.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalCount);
    final paginatedItems = filteredItems.sublist(
      startIndex.clamp(0, totalCount),
      endIndex
    );

    return {
      'items': paginatedItems,
      'totalCount': totalCount,
      'currentPage': page,
      'pageSize': pageSize,
    };
  }

  /// Get student notifications (simple list) - Backward compatibility
  Future<List<ThongBao>> getStudentNotificationsList(String userId) async {
    try {
      final result = await getStudentNotifications(userId: userId);
      return result['items'] as List<ThongBao>;
    } catch (e) {
      throw ApiException('Failed to get student notifications list: $e');
    }
  }

  /// Mark notification as read (local state management)
  /// Note: Backend doesn't have read/unread tracking, so we manage this locally
  Future<bool> markNotificationAsRead(int notificationId) async {
    // trong thực tế có thể gọi API để đánh dấu đã đọc
    // hiện tại chỉ return true để indicate success
    return true;
  }

  /// Send notification (for teachers/system) - renamed to avoid conflict
  Future<void> createNotification(dynamic notification) async {
    try {
      final response = await _httpClient.postSimple(
        '/api/ThongBao',
        notification.toJson(),
      );

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to send notification');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send notification: $e');
    }
  }

  /// Join class by invite code (for students)
  /// Note: This is a placeholder - API endpoint needs to be implemented on server
  // ===== JOIN REQUEST METHODS =====

  /// Student joins class by invite code (creates pending request)
  Future<String> joinClassByInviteCode(String inviteCode) async {
    try {
      final request = JoinClassRequestDTO(inviteCode: inviteCode);
      final response = await _httpClient.postSimple(
        '/api/Lop/join-by-code',
        request.toJson(),
      );

      if (response.success) {
        return response.data ?? 'Yêu cầu tham gia lớp đã được gửi. Chờ giáo viên duyệt.';
      } else {
        throw ApiException(response.message ?? 'Failed to join class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to join class: $e');
    }
  }

  /// Student leaves class (self-removal)
  Future<String> leaveClass(int classId) async {
    try {
      final response = await _httpClient.deleteSimple(
        '/api/Lop/$classId/leave',
      );

      if (response.success) {
        return response.data ?? 'Đã rời khỏi lớp học thành công.';
      } else {
        throw ApiException(response.message ?? 'Failed to leave class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to leave class: $e');
    }
  }

  /// Get count of pending join requests for a class
  Future<int> getPendingRequestCount(int lopId) async {
    try {
      final response = await _httpClient.get(
        '/api/Lop/$lopId/pending-requests/count',
        (json) => PendingRequestCountDTO.fromJson(json),
      );

      if (response.success) {
        return response.data?.pendingCount ?? 0;
      } else {
        throw ApiException(response.message ?? 'Failed to get pending count');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get pending count: $e');
    }
  }

  /// Get list of pending students for a class
  Future<List<PendingStudentDTO>> getPendingStudents(int lopId) async {
    try {
      final response = await _httpClient.getList(
        '/api/Lop/$lopId/pending-requests',
        (jsonList) => jsonList.map((json) => PendingStudentDTO.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get pending students');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get pending students: $e');
    }
  }

  /// Approve a pending join request
  Future<String> approveJoinRequest(int lopId, String studentId) async {
    try {
      final response = await _httpClient.putSimple(
        '/api/Lop/$lopId/approve/$studentId',
        {},
      );

      if (response.success) {
        return response.data ?? 'Đã duyệt yêu cầu tham gia lớp.';
      } else {
        throw ApiException(response.message ?? 'Failed to approve request');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to approve request: $e');
    }
  }

  /// Reject a pending join request
  Future<String> rejectJoinRequest(int lopId, String studentId) async {
    try {
      final response = await _httpClient.deleteSimple(
        '/api/Lop/$lopId/reject/$studentId',
      );

      if (response.success) {
        return response.data ?? 'Đã từ chối yêu cầu tham gia lớp.';
      } else {
        throw ApiException(response.message ?? 'Failed to reject request');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to reject request: $e');
    }
  }

  /// Get available students (not in the specified class)
  Future<PagedResult<GetNguoiDungDTO>> getAvailableStudents({
    required int classId,
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'role': 'Student', // Only get students
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }

      // Build URL with query parameters
      final uri = Uri.parse(ApiConfig.getFullUrl('/api/NguoiDung'))
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri.toString().replaceFirst(ApiConfig.getFullUrl(''), ''),
        (json) => PagedResult.fromJson(
          json,
          (item) => GetNguoiDungDTO.fromJson(item),
        ),
      );

      if (response.success) {
        final allStudents = response.data!;

        // Client-side filtering for students only (fallback if server-side filtering doesn't work)
        final studentsOnly = allStudents.items.where((user) =>
          user.currentRole?.toLowerCase() == 'student'
        ).toList();

        // Get students already in the class
        final studentsInClass = await getStudentsInClass(classId, page: 1, pageSize: 1000);
        final studentIdsInClass = studentsInClass.items.map((s) => s.mssv).toSet();

        // Filter out students already in class
        final availableStudents = studentsOnly
            .where((student) => !studentIdsInClass.contains(student.mssv))
            .toList();

        return PagedResult(
          totalCount: availableStudents.length,
          items: availableStudents,
        );
      } else {
        throw ApiException(response.message ?? 'Failed to get available students');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get available students: $e');
    }
  }

  // ===== CHAPTER (CHUONG) METHODS =====

  /// Get all chapters for a subject
  Future<List<ChuongDTO>> getChapters({int? mamonhocId}) async {
    try {
      // WORKAROUND: Lấy tất cả chương rồi filter trong Flutter
      // vì server có bug logic chỉ trả về chương do user tạo
      String endpoint = '/api/Chuong';

      print('🔧 WORKAROUND: Getting all chapters then filtering in Flutter');
      print('   Requested mamonhocId: $mamonhocId');

      final response = await _httpClient.getList(
        endpoint,
        (jsonList) => jsonList.map((json) => ChuongDTO.fromJson(json)).toList(),
      );

      if (response.success) {
        var allChapters = response.data!;
        print('📊 Total chapters from server: ${allChapters.length}');

        // Filter theo môn học nếu có
        if (mamonhocId != null) {
          allChapters = allChapters.where((chapter) => chapter.mamonhoc == mamonhocId).toList();
          print('📊 Filtered chapters for subject $mamonhocId: ${allChapters.length}');
        }

        return allChapters;
      } else if (response.statusCode == 403) {
        // Handle 403 Forbidden - return empty list for Teacher compatibility
        print('⚠️ 403 Forbidden - Teacher permission issue, returning empty chapters list');
        return <ChuongDTO>[];
      } else {
        throw ApiException(response.message ?? 'Failed to get chapters');
      }
    } catch (e) {
      print('❌ Error in getChapters: $e');
      // Return empty list instead of throwing exception for better UX
      print('🔄 Returning empty chapters list due to error');
      return <ChuongDTO>[];
    }
  }

  /// Get chapter by ID
  Future<ChuongDTO> getChapterById(int id) async {
    try {
      final response = await _httpClient.get(
        '/api/Chuong/$id',
        (json) => ChuongDTO.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get chapter');
      }
    } catch (e) {
      throw ApiException('Failed to get chapter: $e');
    }
  }

  /// Create new chapter
  Future<ChuongDTO> createChapter(CreateChuongRequestDTO request) async {
    try {
      final response = await _httpClient.post(
        '/api/Chuong',
        request.toJson(),
        (json) => ChuongDTO.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to create chapter');
      }
    } catch (e) {
      throw ApiException('Failed to create chapter: $e');
    }
  }

  /// Update chapter
  Future<ChuongDTO> updateChapter(int id, UpdateChuongRequestDTO request) async {
    try {
      final response = await _httpClient.put(
        '/api/Chuong/$id',
        request.toJson(),
        (json) => ChuongDTO.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to update chapter');
      }
    } catch (e) {
      throw ApiException('Failed to update chapter: $e');
    }
  }

  /// Delete chapter
  Future<void> deleteChapter(int id) async {
    try {
      final response = await _httpClient.deleteSimple('/api/Chuong/$id');

      if (!response.success) {
        throw ApiException(response.message ?? 'Failed to delete chapter');
      }
    } catch (e) {
      throw ApiException('Failed to delete chapter: $e');
    }
  }

  /// Get assigned subjects for current instructor
  Future<List<MonHocDTO>> getAssignedSubjects() async {
    try {
      final response = await _httpClient.getList(
        '/api/PhanCong/assigned-subjects',
        (jsonList) => jsonList.map((json) => MonHocDTO.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get assigned subjects');
      }
    } catch (e) {
      throw ApiException('Failed to get assigned subjects: $e');
    }
  }

  // ===== EXAM (DE THI) METHODS =====

  /// Get all exams (tất cả đề thi của môn học được phân công)
  Future<List<DeThiModel>> getAllDeThis() async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi',
        (jsonList) => jsonList.map((json) => DeThiModel.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get exams');
      }
    } catch (e) {
      throw ApiException('Failed to get exams: $e');
    }
  }

  /// Get exams created by current teacher only (chỉ đề thi do mình tạo)
  Future<List<DeThiModel>> getMyCreatedExams() async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/my-created-exams', // API mới - chỉ đề thi của mình
        (jsonList) => jsonList.map((json) => DeThiModel.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get my created exams');
      }
    } catch (e) {
      throw ApiException('Failed to get my created exams: $e');
    }
  }

  /// Get exam by ID
  Future<DeThiDetailModel> getDeThiById(int id) async {
    try {
      final response = await _httpClient.get(
        '/api/DeThi/$id',
        (json) => DeThiDetailModel.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam');
      }
    } catch (e) {
      throw ApiException('Failed to get exam: $e');
    }
  }

  /// Create new exam
  Future<DeThiModel> createDeThi(DeThiCreateRequest request) async {
    try {
      final response = await _httpClient.post(
        '/api/DeThi',
        request.toJson(),
        (json) => DeThiModel.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to create exam');
      }
    } catch (e) {
      throw ApiException('Failed to create exam: $e');
    }
  }

  /// Update exam
  Future<bool> updateDeThi(int id, DeThiUpdateRequest request) async {
    try {
      debugPrint('🔄 API updateDeThi - ID: $id');
      debugPrint('📤 Request data: ${request.toJson()}');

      // Use putSimple instead of put for better 204 handling
      final response = await _httpClient.putSimple(
        '/api/DeThi/$id',
        request.toJson(),
      );

      debugPrint('📥 Update response success: ${response.success}');
      debugPrint('📊 Response data: ${response.data}');

      return response.success;
    } catch (e) {
      debugPrint('💥 API updateDeThi error: $e');
      throw ApiException('Failed to update exam: $e');
    }
  }

  /// Delete exam
  Future<bool> deleteDeThi(int id) async {
    try {
      final response = await _httpClient.deleteSimple('/api/DeThi/$id');
      return response.success;
    } catch (e) {
      throw ApiException('Failed to delete exam: $e');
    }
  }

  /// Get questions in exam (for composer)
  Future<List<CauHoiSoanThaoModel>> getCauHoiCuaDeThi(int deThiId) async {
    try {
      final response = await _httpClient.getList(
        '/api/SoanThaoDeThi/$deThiId/cauhoi',
        (jsonList) => jsonList.map((json) => CauHoiSoanThaoModel.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam questions');
      }
    } catch (e) {
      throw ApiException('Failed to get exam questions: $e');
    }
  }

  /// Add questions to exam
  Future<bool> addCauHoiVaoDeThi(int deThiId, DapAnSoanThaoRequest request) async {
    try {
      final response = await _httpClient.post(
        '/api/SoanThaoDeThi/$deThiId/cauhoi',
        request.toJson(),
        (json) => json,
      );

      return response.success;
    } catch (e) {
      throw ApiException('Failed to add questions to exam: $e');
    }
  }

  /// Remove question from exam
  Future<bool> removeCauHoiKhoiDeThi(int deThiId, int cauHoiId) async {
    try {
      final response = await _httpClient.deleteSimple('/api/SoanThaoDeThi/$deThiId/cauhoi/$cauHoiId');
      return response.success;
    } catch (e) {
      throw ApiException('Failed to remove question from exam: $e');
    }
  }

  /// Get exams for class (student view)
  Future<List<ExamForClassModel>> getExamsForClass(int classId) async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/class/$classId',
        (jsonList) => jsonList.map((json) => ExamForClassModel.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get class exams');
      }
    } catch (e) {
      throw ApiException('Failed to get class exams: $e');
    }
  }

  /// Get all exams for student
  Future<List<ExamForClassModel>> getAllExamsForStudent() async {
    try {
      final response = await _httpClient.getList(
        '/api/DeThi/my-exams',
        (jsonList) => jsonList.map((json) => ExamForClassModel.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get student exams');
      }
    } catch (e) {
      throw ApiException('Failed to get student exams: $e');
    }
  }

  /// Get questions by subject ID (tất cả câu hỏi của môn học)
  Future<List<CauHoi>> getQuestionsBySubject(int subjectId) async {
    try {
      final response = await _httpClient.getList(
        '/api/CauHoi/ByMonHoc/$subjectId',
        (jsonList) => jsonList.map((json) => CauHoi.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get questions by subject');
      }
    } catch (e) {
      throw ApiException('Failed to get questions by subject: $e');
    }
  }

  /// Get questions created by current teacher only (chỉ câu hỏi do mình tạo)
  Future<PagedResult<CauHoi>> getMyCreatedQuestions({
    int pageNumber = 1,
    int pageSize = 10,
    int? maMonHoc,
    int? maChuong,
    int? doKho,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (maMonHoc != null) queryParams['maMonHoc'] = maMonHoc.toString();
      if (maChuong != null) queryParams['maChuong'] = maChuong.toString();
      if (doKho != null) queryParams['doKho'] = doKho.toString();
      if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;

      final endpoint = '/api/CauHoi/my-created-questions?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => PagedResult<CauHoi>.fromJson(
          json,
          (itemJson) => CauHoi.fromJson(itemJson),
        ),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get my created questions');
      }
    } catch (e) {
      throw ApiException('Failed to get my created questions: $e');
    }
  }

  /// Get questions by subject ID and chapter IDs
  Future<List<CauHoi>> getQuestionsBySubjectAndChapters(int subjectId, List<int> chapterIds) async {
    try {
      final chapterIdsParam = chapterIds.join(',');
      final response = await _httpClient.getList(
        '/api/CauHoi/ByMonHocAndChuongs/$subjectId?chapterIds=$chapterIdsParam',
        (jsonList) => jsonList.map((json) => CauHoi.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get questions by subject and chapters');
      }
    } catch (e) {
      throw ApiException('Failed to get questions by subject and chapters: $e');
    }
  }

  /// Get my created questions by subject ID (chỉ câu hỏi do giảng viên hiện tại tạo)
  Future<List<CauHoi>> getMyQuestionsBySubject(int subjectId) async {
    try {
      final queryParams = <String, String>{
        'MaMonHoc': subjectId.toString(),
        'pageNumber': '1',
        'pageSize': '1000', // Lấy tất cả
      };

      final endpoint = '/api/CauHoi/my-created-questions?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => PagedResult<CauHoi>.fromJson(
          json,
          (itemJson) => CauHoi.fromJson(itemJson),
        ),
      );

      if (response.success && response.data != null) {
        return response.data!.items;
      } else {
        throw ApiException(response.message ?? 'Failed to get my questions by subject');
      }
    } catch (e) {
      throw ApiException('Failed to get my questions by subject: $e');
    }
  }

  /// Add questions to exam
  Future<bool> addQuestionsToExam(int examId, List<int> questionIds) async {
    try {
      final response = await _httpClient.post(
        '/api/SoanThaoDeThi/$examId/add-questions',
        {'questionIds': questionIds},
        (json) => json,
      );

      return response.success;
    } catch (e) {
      throw ApiException('Failed to add questions to exam: $e');
    }
  }

  /// Remove question from exam
  Future<bool> removeQuestionFromExam(int examId, int questionId) async {
    try {
      final response = await _httpClient.post(
        '/api/SoanThaoDeThi/$examId/remove-question/$questionId',
        {},
        (json) => json,
      );

      return response.success;
    } catch (e) {
      throw ApiException('Failed to remove question from exam: $e');
    }
  }

  /// Get questions in exam
  Future<List<CauHoiSoanThaoModel>> getQuestionsInExam(int examId) async {
    try {
      final response = await _httpClient.getList(
        '/api/SoanThaoDeThi/$examId/cauhoi',
        (jsonList) => jsonList.map((json) => CauHoiSoanThaoModel.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get questions in exam');
      }
    } catch (e) {
      throw ApiException('Failed to get questions in exam: $e');
    }
  }

  /// Send notification
  Future<bool> sendNotification(dynamic notificationRequest) async {
    try {
      final response = await _httpClient.post(
        '/api/ThongBao',
        notificationRequest.toJson(),
        (json) => json,
      );

      return response.success;
    } catch (e) {
      // Don't throw error for notifications to avoid disrupting main flow
      debugPrint('Failed to send notification: $e');
      return false;
    }
  }

  // ===== RESET PASSWORD FLOW METHODS =====

  /// Verify current password by attempting sign in
  Future<bool> verifyCurrentPassword(String email, String currentPassword) async {
    try {
      print('🔍 DEBUG Verify Current Password - START');
      print('   Email: $email');
      print('   Password length: ${currentPassword.length}');

      final signInRequest = {
        'email': email,
        'password': currentPassword,
      };

      final response = await _httpClient.postSimple(
        ApiConfig.signInEndpoint,
        signInRequest,
        includeAuth: false, // No auth needed for sign in
      );

      print('📥 Verify password response:');
      print('   Success: ${response.success}');
      print('   Status code: ${response.statusCode}');

      return response.success;
    } catch (e) {
      print('❌ Verify current password error: $e');
      return false;
    }
  }

  /// Request OTP for password reset
  Future<void> forgotPassword(String email) async {
    try {
      print('🔍 DEBUG Forgot Password - START');
      print('   Email: $email');

      final requestData = {'email': email};

      final response = await _httpClient.postSimple(
        ApiConfig.forgotPasswordEndpoint,
        requestData,
        includeAuth: false, // No auth needed for forgot password
      );

      print('📥 Forgot password response:');
      print('   Success: ${response.success}');
      print('   Status code: ${response.statusCode}');
      print('   Message: ${response.message}');

      if (!response.success) {
        throw ApiException(
          response.message ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }

      print('✅ OTP sent successfully');
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send OTP: $e');
    }
  }

  /// Verify OTP and get reset token
  Future<String> verifyOTP(String email, String otp) async {
    try {
      print('🔍 DEBUG Verify OTP - START');
      print('   Email: $email');
      print('   OTP: $otp');

      final requestData = {
        'email': email,
        'otp': otp,
      };

      final response = await _httpClient.post(
        ApiConfig.verifyOtpEndpoint,
        requestData,
        (json) => json, // Return raw JSON
        includeAuth: false, // No auth needed for OTP verification
      );

      print('📥 Verify OTP response:');
      print('   Success: ${response.success}');
      print('   Status code: ${response.statusCode}');
      print('   Message: ${response.message}');

      if (!response.success) {
        throw ApiException(
          response.message ?? 'Failed to verify OTP',
          statusCode: response.statusCode,
        );
      }

      // Extract reset token from response
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final resetToken = responseData['passwordResetToken'];
        if (resetToken is String) {
          print('✅ OTP verified, reset token received');
          return resetToken;
        }
      }
      throw ApiException('Invalid response format: missing reset token');
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to verify OTP: $e');
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String email, String token, String newPassword, String confirmPassword) async {
    try {
      print('🔍 DEBUG Reset Password - START');
      print('   Email: $email');
      print('   Token length: ${token.length}');
      print('   New password length: ${newPassword.length}');

      final requestData = {
        'email': email,
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

      final response = await _httpClient.postSimple(
        ApiConfig.resetPasswordEndpoint,
        requestData,
        includeAuth: false, // No auth needed for password reset
      );

      print('📥 Reset password response:');
      print('   Success: ${response.success}');
      print('   Status code: ${response.statusCode}');
      print('   Message: ${response.message}');

      if (!response.success) {
        throw ApiException(
          response.message ?? 'Failed to reset password',
          statusCode: response.statusCode,
        );
      }

      print('✅ Password reset successfully');
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to reset password: $e');
    }
  }

  // ===== GENERIC FILE UPLOAD METHODS =====

  /// Upload file using generic /api/Files/upload endpoint
  Future<String?> uploadFileGeneric(String filePath) async {
    try {
      print('🔍 DEBUG Generic File Upload - START');
      print('   File path: $filePath');

      final file = File(filePath);
      final fileExists = await file.exists();
      print('   File exists: $fileExists');

      if (!fileExists) {
        print('❌ File not found at path: $filePath');
        throw ApiException('File not found');
      }

      // Get file info
      final fileSize = await file.length();
      final fileName = path.basename(filePath);
      print('   File name: $fileName');
      print('   File size: $fileSize bytes');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/Files/upload'),
      );

      print('🌐 Request URL: ${request.url}');

      // Add authorization header
      final token = await _httpClient.getStoredAccessToken();
      final jwtToken = _httpClient.getJWTFromCookies();

      print('🔐 Auth info:');
      print('   Stored token: ${token != null ? "${token.substring(0, math.min(20, token.length))}..." : "null"}');
      print('   JWT from cookies: ${jwtToken != null ? "${jwtToken.substring(0, math.min(20, jwtToken.length))}..." : "null"}');

      if (token != null && token != 'cookie_jwt_auth_active') {
        request.headers['Authorization'] = 'Bearer $token';
        print('   Using stored token for auth');
      } else {
        if (jwtToken != null && jwtToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $jwtToken';
          print('   Using JWT from cookies for auth');
        } else {
          print('⚠️ No valid token found for authentication');
        }
      }

      // Add default headers
      request.headers['Accept'] = 'application/json';

      print('📤 Request headers: ${request.headers}');

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
        ),
      );

      print('📤 Sending generic file upload request...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Generic file upload response:');
      print('   Status code: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('📄 Response data: $responseData');

          // Extract file URL from response
          if (responseData is Map<String, dynamic>) {
            // Try different possible keys for the file URL
            final fileUrl = responseData['url'] ??
                           responseData['fileUrl'] ??
                           responseData['path'] ??
                           responseData['filePath'] ??
                           responseData['data'];

            if (fileUrl is String) {
              print('✅ Generic file upload successful: $fileUrl');
              return fileUrl;
            }
          }

          print('❌ No valid file URL found in response');
          throw ApiException('Invalid response format: missing file URL');
        } catch (e) {
          print('❌ Error parsing response: $e');
          throw ApiException('Failed to parse upload response');
        }
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          print('📄 Error response: $errorResponse');
          throw ApiException(errorResponse['message'] ?? 'Failed to upload file');
        } catch (e) {
          print('❌ Error parsing error response: $e');
          throw ApiException('Upload failed: ${response.body}');
        }
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw ApiException('No internet connection');
    } catch (e) {
      print('❌ Generic file upload error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload file: $e');
    }
  }

  // ===== ROLE MANAGEMENT METHODS =====

  /// Get all role groups
  Future<List<RoleGroup>> getRoleGroups() async {
    try {
      print('🔍 Getting role groups...');

      final response = await _httpClient.getList(
        '/api/permission',
        (jsonList) => jsonList.map((json) => RoleGroup.fromJson(json)).toList(),
      );

      if (response.success) {
        print('✅ Role groups loaded: ${response.data!.length}');
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get role groups');
      }
    } catch (e) {
      print('❌ Error getting role groups: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get role groups: $e');
    }
  }

  /// Get role group detail by ID
  Future<RoleGroupDetail> getRoleGroupDetail(String id) async {
    try {
      print('🔍 Getting role group detail for ID: $id');

      final response = await _httpClient.get(
        '/api/permission/$id',
        (json) => RoleGroupDetail.fromJson(json),
      );

      if (response.success) {
        print('✅ Role group detail loaded');
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get role group detail');
      }
    } catch (e) {
      print('❌ Error getting role group detail: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get role group detail: $e');
    }
  }

  /// Get all functions for permission management
  Future<List<FunctionModel>> getFunctions() async {
    try {
      print('🔍 Getting functions...');

      final response = await _httpClient.getList(
        '/api/permission/functions',
        (jsonList) => jsonList.map((json) => FunctionModel.fromJson(json)).toList(),
      );

      if (response.success) {
        print('✅ Functions loaded: ${response.data!.length}');
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get functions');
      }
    } catch (e) {
      print('❌ Error getting functions: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get functions: $e');
    }
  }

  /// Create new role group
  Future<void> createRoleGroup(RoleGroupRequest request) async {
    try {
      print('🔍 Creating role group: ${request.tenNhomQuyen}');

      final response = await _httpClient.postSimple(
        '/api/permission',
        request.toJson(),
      );

      if (response.success) {
        print('✅ Role group created successfully');
      } else {
        throw ApiException(response.message ?? 'Failed to create role group');
      }
    } catch (e) {
      print('❌ Error creating role group: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create role group: $e');
    }
  }

  /// Update role group
  Future<void> updateRoleGroup(String id, RoleGroupRequest request) async {
    try {
      print('🔍 Updating role group: $id');

      final response = await _httpClient.putSimple(
        '/api/permission/$id',
        request.toJson(),
      );

      if (response.success) {
        print('✅ Role group updated successfully');
      } else {
        throw ApiException(response.message ?? 'Failed to update role group');
      }
    } catch (e) {
      print('❌ Error updating role group: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update role group: $e');
    }
  }

  /// Delete role group
  Future<void> deleteRoleGroup(String id) async {
    try {
      print('🔍 Deleting role group: $id');

      final response = await _httpClient.deleteSimple('/api/permission/$id');

      if (response.success) {
        print('✅ Role group deleted successfully');
      } else {
        throw ApiException(response.message ?? 'Failed to delete role group');
      }
    } catch (e) {
      print('❌ Error deleting role group: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete role group: $e');
    }
  }

  // ===== DASHBOARD METHODS =====

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      print('🔍 Getting dashboard statistics');

      final response = await _httpClient.get(
        '/api/Dashboard',
        (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        print('✅ Dashboard statistics retrieved successfully');
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get dashboard statistics');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      print('❌ Error getting dashboard statistics: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get dashboard statistics: $e');
    }
  }
}

/// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return ApiService(httpClient);
});

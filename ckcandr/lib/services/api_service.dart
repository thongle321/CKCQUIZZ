/// API Service for CKC Quiz Application
/// 
/// This service handles all HTTP communication with the ASP.NET Core backend API.
/// It provides methods for user management, authentication, and other API operations.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
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
        throw ApiException(response.message ?? 'Failed to delete class');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete class: $e');
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
      String endpoint = '/api/Chuong';
      if (mamonhocId != null) {
        endpoint += '?mamonhocId=$mamonhocId';
      }

      final response = await _httpClient.getList(
        endpoint,
        (jsonList) => jsonList.map((json) => ChuongDTO.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get chapters');
      }
    } catch (e) {
      throw ApiException('Failed to get chapters: $e');
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
}

/// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return ApiService(httpClient);
});

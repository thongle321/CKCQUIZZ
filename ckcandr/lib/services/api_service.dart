/// API Service for CKC Quiz Application
/// 
/// This service handles all HTTP communication with the ASP.NET Core backend API.
/// It provides methods for user management, authentication, and other API operations.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
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

  /// Submit exam answers
  Future<ExamResult> submitExam(SubmitExamRequest request) async {
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

  /// Get all results for an exam (for teachers)
  Future<List<ExamResult>> getExamResults(int examId) async {
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
      final response = await _httpClient.get(
        '/api/KetQua/$resultId/detail',
        (json) => ExamResultDetail.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to get exam result detail');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get exam result detail: $e');
    }
  }

  /// Export exam results to Excel/PDF
  Future<String> exportExamResults(int examId, String format) async {
    try {
      final response = await _httpClient.get(
        '/api/KetQua/export/$examId?format=$format',
        (json) => json['downloadUrl'] as String,
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ApiException(response.message ?? 'Failed to export exam results');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to export exam results: $e');
    }
  }

  // ===== NOTIFICATION METHODS =====

  /// Get notifications for user (student)
  Future<List<dynamic>> getNotificationsForUser(String userId) async {
    try {
      final response = await _httpClient.getList(
        '/api/ThongBao/notifications/$userId',
        (jsonList) => jsonList,
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get notifications');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
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

  /// Get student notifications (tin nhắn cho người dùng) - Enhanced for student features
  Future<List<ThongBao>> getStudentNotifications(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ApiException('User ID is required');
      }

      final response = await _httpClient.getList(
        '/api/ThongBao/notifications/$userId',
        (jsonList) => jsonList.map((item) => ThongBao.fromApiResponse(item as Map<String, dynamic>)).toList(),
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw ApiException(response.message ?? 'Failed to get student notifications');
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get student notifications: $e');
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

  // ===== EXAM (DE THI) METHODS =====

  /// Get all exams
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

  /// Get questions by subject ID
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
}

/// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return ApiService(httpClient);
});

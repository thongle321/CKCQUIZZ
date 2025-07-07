import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/phan_cong_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/services/http_client_service.dart';

/// Exception thrown when Phân công API calls fail
class PhanCongApiException implements Exception {
  final String message;
  final int? statusCode;

  PhanCongApiException(this.message, {this.statusCode});

  @override
  String toString() => 'PhanCongApiException: $message (Status: $statusCode)';
}

/// Service for managing Phân công (Assignment) operations
class PhanCongService {
  final HttpClientService _httpClient;

  PhanCongService(this._httpClient);

  /// Get all assignments
  Future<List<PhanCong>> getAllAssignments() async {
    try {
      final response = await _httpClient.getList(
        '/api/phancong',
        (jsonList) => jsonList.map((json) => PhanCong.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw PhanCongApiException(response.message ?? 'Failed to get assignments');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to get assignments: $e');
    }
  }

  /// Get all lecturers (teachers) for assignment dropdown
  Future<List<GiangVien>> getLecturers() async {
    try {
      final response = await _httpClient.getList(
        '/api/phancong/lecturers',
        (jsonList) => jsonList.map((json) => GiangVien.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw PhanCongApiException(response.message ?? 'Failed to get lecturers');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to get lecturers: $e');
    }
  }

  /// Get subjects for assignment (reuse from MonHoc API)
  Future<List<ApiMonHoc>> getSubjects() async {
    try {
      final response = await _httpClient.getList(
        '/api/MonHoc',
        (jsonList) => jsonList.map((json) => ApiMonHoc.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw PhanCongApiException(response.message ?? 'Failed to get subjects');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to get subjects: $e');
    }
  }



  /// Add new assignment
  Future<void> addAssignment(String giangVienId, List<String> listMaMonHoc) async {
    try {
      final request = CreatePhanCongRequest(
        giangVienId: giangVienId,
        listMaMonHoc: listMaMonHoc,
      );

      final response = await _httpClient.postSimple(
        '/api/phancong',
        request.toJson(),
      );

      if (!response.success) {
        throw PhanCongApiException(response.message ?? 'Failed to add assignment');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to add assignment: $e');
    }
  }

  /// Delete specific assignment
  Future<void> deleteAssignment(int maMonHoc, String maNguoiDung) async {
    try {
      final response = await _httpClient.deleteSimple(
        '/api/phancong/$maMonHoc/$maNguoiDung',
      );

      if (!response.success) {
        throw PhanCongApiException(response.message ?? 'Failed to delete assignment');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to delete assignment: $e');
    }
  }

  /// Delete all assignments by user
  Future<void> deleteAllAssignmentsByUser(String maNguoiDung) async {
    try {
      final response = await _httpClient.deleteSimple(
        '/api/phancong/delete-by-user/$maNguoiDung',
      );

      if (!response.success) {
        throw PhanCongApiException(response.message ?? 'Failed to delete all assignments by user');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to delete all assignments by user: $e');
    }
  }

  /// Get assignments by user
  Future<List<PhanCong>> getAssignmentsByUser(String maNguoiDung) async {
    try {
      final response = await _httpClient.getList(
        '/api/phancong/by-user/$maNguoiDung',
        (jsonList) => jsonList.map((json) => PhanCong.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw PhanCongApiException(response.message ?? 'Failed to get assignments by user');
      }
    } on SocketException {
      throw PhanCongApiException('No internet connection');
    } catch (e) {
      if (e is PhanCongApiException) rethrow;
      throw PhanCongApiException('Failed to get assignments by user: $e');
    }
  }
}

// ===== PROVIDERS =====

/// Provider for PhanCongService
final phanCongServiceProvider = Provider<PhanCongService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return PhanCongService(httpClient);
});

/// Provider for all assignments list
final phanCongListProvider = FutureProvider.autoDispose<List<PhanCong>>((ref) async {
  final service = ref.watch(phanCongServiceProvider);
  return service.getAllAssignments();
});

/// Provider for lecturers list
final lecturersListProvider = FutureProvider.autoDispose<List<GiangVien>>((ref) async {
  final service = ref.watch(phanCongServiceProvider);
  return service.getLecturers();
});

/// Provider for subjects list (for assignment)
final subjectsForAssignmentProvider = FutureProvider.autoDispose<List<ApiMonHoc>>((ref) async {
  final service = ref.watch(phanCongServiceProvider);
  return service.getSubjects();
});

/// Provider for assignments by user
final assignmentsByUserProvider = FutureProvider.family<List<PhanCong>, String>((ref, userId) async {
  final service = ref.watch(phanCongServiceProvider);
  return service.getAssignmentsByUser(userId);
});

/// StateNotifier for managing assignment operations
class PhanCongNotifier extends StateNotifier<AsyncValue<List<PhanCong>>> {
  final PhanCongService _service;

  PhanCongNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAssignments();
  }

  /// Load all assignments
  Future<void> loadAssignments() async {
    state = const AsyncValue.loading();
    try {
      final assignments = await _service.getAllAssignments();
      state = AsyncValue.data(assignments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add new assignment
  Future<void> addAssignment(String giangVienId, List<String> listMaMonHoc) async {
    try {
      await _service.addAssignment(giangVienId, listMaMonHoc);
      await loadAssignments(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(int maMonHoc, String maNguoiDung) async {
    try {
      await _service.deleteAssignment(maMonHoc, maNguoiDung);
      await loadAssignments(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all assignments by user
  Future<void> deleteAllAssignmentsByUser(String maNguoiDung) async {
    try {
      await _service.deleteAllAssignmentsByUser(maNguoiDung);
      await loadAssignments(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for PhanCongNotifier
final phanCongNotifierProvider = StateNotifierProvider<PhanCongNotifier, AsyncValue<List<PhanCong>>>((ref) {
  final service = ref.watch(phanCongServiceProvider);
  return PhanCongNotifier(service);
});

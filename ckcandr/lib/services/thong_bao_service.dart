import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/http_client_service.dart';

/// Exception thrown when Thông báo API calls fail
class ThongBaoApiException implements Exception {
  final String message;
  final int? statusCode;

  ThongBaoApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ThongBaoApiException: $message (Status: $statusCode)';
}

/// Service for managing Thông báo (Notification) operations
class ThongBaoService {
  final HttpClientService _httpClient;

  ThongBaoService(this._httpClient);

  /// Get all notifications with pagination
  Future<ThongBaoPagedResponse> getNotifications({
    int page = 1,
    int pageSize = 5,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final endpoint = '/api/ThongBao/me?${Uri(queryParameters: queryParams).query}';

      final response = await _httpClient.get(
        endpoint,
        (json) => ThongBaoPagedResponse.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ThongBaoApiException(response.message ?? 'Failed to get notifications');
      }
    } on SocketException {
      throw ThongBaoApiException('No internet connection');
    } catch (e) {
      if (e is ThongBaoApiException) rethrow;
      throw ThongBaoApiException('Failed to get notifications: $e');
    }
  }

  /// Get subjects with groups for notification dropdown
  Future<List<SubjectWithGroups>> getSubjectsWithGroups({bool? hienthi}) async {
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
        (jsonList) => jsonList.map((json) => SubjectWithGroups.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ThongBaoApiException(response.message ?? 'Failed to get subjects with groups');
      }
    } on SocketException {
      throw ThongBaoApiException('No internet connection');
    } catch (e) {
      if (e is ThongBaoApiException) rethrow;
      throw ThongBaoApiException('Failed to get subjects with groups: $e');
    }
  }

  /// Get notification detail by ID
  Future<ThongBaoDetail> getNotificationDetail(int maTb) async {
    try {
      final response = await _httpClient.get(
        '/api/ThongBao/detail/$maTb',
        (json) => ThongBaoDetail.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw ThongBaoApiException(response.message ?? 'Failed to get notification detail');
      }
    } on SocketException {
      throw ThongBaoApiException('No internet connection');
    } catch (e) {
      if (e is ThongBaoApiException) rethrow;
      throw ThongBaoApiException('Failed to get notification detail: $e');
    }
  }

  /// Create new notification
  Future<void> createNotification(CreateThongBaoRequest request) async {
    try {
      final response = await _httpClient.postSimple(
        '/api/ThongBao',
        request.toJson(),
      );

      if (!response.success) {
        throw ThongBaoApiException(response.message ?? 'Failed to create notification');
      }
    } on SocketException {
      throw ThongBaoApiException('No internet connection');
    } catch (e) {
      if (e is ThongBaoApiException) rethrow;
      throw ThongBaoApiException('Failed to create notification: $e');
    }
  }

  /// Update notification
  Future<void> updateNotification(int maTb, UpdateThongBaoRequest request) async {
    try {
      final response = await _httpClient.putSimple(
        '/api/ThongBao/$maTb',
        request.toJson(),
      );

      if (!response.success) {
        throw ThongBaoApiException(response.message ?? 'Failed to update notification');
      }
    } on SocketException {
      throw ThongBaoApiException('No internet connection');
    } catch (e) {
      if (e is ThongBaoApiException) rethrow;
      throw ThongBaoApiException('Failed to update notification: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int maTb) async {
    try {
      final response = await _httpClient.deleteSimple('/api/ThongBao/$maTb');

      if (!response.success) {
        throw ThongBaoApiException(response.message ?? 'Failed to delete notification');
      }
    } on SocketException {
      throw ThongBaoApiException('No internet connection');
    } catch (e) {
      if (e is ThongBaoApiException) rethrow;
      throw ThongBaoApiException('Failed to delete notification: $e');
    }
  }
}

// ===== PROVIDERS =====

/// Provider for ThongBaoService
final thongBaoServiceProvider = Provider<ThongBaoService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return ThongBaoService(httpClient);
});

/// Provider for subjects with groups list
final subjectsWithGroupsProvider = FutureProvider.autoDispose<List<SubjectWithGroups>>((ref) async {
  final service = ref.watch(thongBaoServiceProvider);
  return service.getSubjectsWithGroups(hienthi: true);
});

/// Provider for notification detail
final notificationDetailProvider = FutureProvider.family<ThongBaoDetail, int>((ref, maTb) async {
  final service = ref.watch(thongBaoServiceProvider);
  return service.getNotificationDetail(maTb);
});

/// StateNotifier for managing notification operations with pagination
class ThongBaoNotifier extends StateNotifier<AsyncValue<ThongBaoPagedResponse>> {
  final ThongBaoService _service;
  int _currentPage = 1;
  int _pageSize = 5;
  String _searchQuery = '';

  ThongBaoNotifier(this._service) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;

  /// Load notifications with current pagination settings
  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final response = await _service.getNotifications(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Change page
  Future<void> changePage(int page) async {
    _currentPage = page;
    await loadNotifications();
  }

  /// Change page size
  Future<void> changePageSize(int pageSize) async {
    _pageSize = pageSize;
    _currentPage = 1; // Reset to first page
    await loadNotifications();
  }

  /// Search notifications
  Future<void> search(String query) async {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page
    await loadNotifications();
  }

  /// Create new notification
  Future<void> createNotification(CreateThongBaoRequest request) async {
    try {
      await _service.createNotification(request);
      await loadNotifications(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  /// Update notification
  Future<void> updateNotification(int maTb, UpdateThongBaoRequest request) async {
    try {
      await _service.updateNotification(maTb, request);
      await loadNotifications(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int maTb) async {
    try {
      await _service.deleteNotification(maTb);
      
      // Check if we need to go to previous page after deletion
      final currentState = state;
      if (currentState is AsyncData) {
        final currentData = currentState.value;
        if (currentData?.items.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
      }
      
      await loadNotifications(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for ThongBaoNotifier
final thongBaoNotifierProvider = StateNotifierProvider<ThongBaoNotifier, AsyncValue<ThongBaoPagedResponse>>((ref) {
  final service = ref.watch(thongBaoServiceProvider);
  return ThongBaoNotifier(service);
});

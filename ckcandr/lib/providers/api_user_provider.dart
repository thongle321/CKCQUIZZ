/// API User Provider for CKC Quiz Application
///
/// This provider handles user management through API calls to the backend server.
/// It provides methods for loading, creating, updating users via REST API.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// State for API user operations
class ApiUserState {
  final List<GetNguoiDungDTO> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final String? error;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const ApiUserState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.error,
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 10,
  });

  ApiUserState copyWith({
    List<GetNguoiDungDTO>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreData,
    String? error,
    int? totalCount,
    int? currentPage,
    int? pageSize,
  }) {
    return ApiUserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      error: error,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

/// Notifier for managing API user operations
class ApiUserNotifier extends StateNotifier<ApiUserState> {
  final ApiService _apiService;

  ApiUserNotifier(this._apiService) : super(const ApiUserState());

  /// Load users from API with pagination and search (initial load)
  Future<void> loadUsers({
    String? searchQuery,
    String? role,
    int page = 1,
    int pageSize = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.getUsers(
        searchQuery: searchQuery,
        role: role,
        page: page,
        pageSize: pageSize,
      );

      final hasMore = result.items.length == pageSize &&
                     (result.items.length + (page - 1) * pageSize) < result.totalCount;

      state = state.copyWith(
        users: result.items,
        totalCount: result.totalCount,
        currentPage: page,
        pageSize: pageSize,
        hasMoreData: hasMore,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đã xảy ra lỗi không xác định: $e',
      );
    }
  }

  /// Load more users for infinite scroll
  Future<void> loadMoreUsers({
    String? searchQuery,
    String? role,
  }) async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _apiService.getUsers(
        searchQuery: searchQuery,
        role: role,
        page: nextPage,
        pageSize: state.pageSize,
      );

      final allUsers = [...state.users, ...result.items];
      final hasMore = result.items.length == state.pageSize &&
                     allUsers.length < result.totalCount;

      state = state.copyWith(
        users: allUsers,
        totalCount: result.totalCount,
        currentPage: nextPage,
        hasMoreData: hasMore,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Đã xảy ra lỗi không xác định: $e',
      );
    }
  }

  /// Create new user
  Future<bool> createUser(CreateNguoiDungRequestDTO request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.createUser(request);

      // Reload users after successful creation
      await loadUsers(
        page: 1,
        pageSize: 1000, // Load all users
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatApiError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đã xảy ra lỗi không xác định: $e',
      );
      return false;
    }
  }

  /// Update user
  Future<bool> updateUser(String id, UpdateNguoiDungRequestDTO request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.updateUser(id, request);

      // Reload users after successful update
      await loadUsers(
        page: 1,
        pageSize: 1000, // Load all users
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatApiError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đã xảy ra lỗi không xác định: $e',
      );
      return false;
    }
  }

  /// Toggle user status (enable/disable user)
  Future<bool> toggleUserStatus(String id, bool hienthi) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.toggleUserStatus(id, hienthi);

      // Reload users after successful status change
      await loadUsers(
        page: 1,
        pageSize: 1000, // Load all users
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatApiError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đã xảy ra lỗi không xác định: $e',
      );
      return false;
    }
  }





  /// Refresh - reset to first page
  Future<void> refresh() async {
    await loadUsers(
      page: 1,
      pageSize: 1000, // Load all users
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Format API error for display
  String _formatApiError(ApiException e) {
    if (e.errorResponse?.errors != null) {
      final errors = e.errorResponse!.errors!;
      final errorMessages = <String>[];
      
      errors.forEach((field, messages) {
        errorMessages.addAll(messages);
      });
      
      return errorMessages.join('\n');
    }
    
    return e.message;
  }
}

/// Provider for API user management
final apiUserProvider = StateNotifierProvider<ApiUserNotifier, ApiUserState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ApiUserNotifier(apiService);
});

/// Provider for available roles
final rolesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    return await apiService.getRoles();
  } catch (e) {
    debugPrint('❌ Error loading roles: $e');
    // Return default roles if API fails
    return ['Admin', 'Teacher', 'Student'];
  }
});

/// Provider for teachers list
final teachersProvider = FutureProvider<List<GetNguoiDungDTO>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    return await apiService.getTeachers();
  } catch (e) {
    debugPrint('❌ Error loading teachers: $e');
    // Return empty list if API fails
    return [];
  }
});

/// Helper function to convert API DTO to User model
User convertApiUserToUser(GetNguoiDungDTO dto) {
  return User(
    id: dto.mssv,
    mssv: dto.mssv,
    hoVaTen: dto.hoten,
    email: dto.email,
    gioiTinh: true, // Default value since API doesn't provide this
    quyen: _mapRoleStringToEnum(dto.currentRole ?? 'Student'),
    trangThai: dto.trangthai ?? true,
    ngaySinh: dto.ngaysinh,
    // Note: phoneNumber not included in User model
    ngayTao: DateTime.now(), // Default since API doesn't provide this
    ngayCapNhat: DateTime.now(), // Default since API doesn't provide this
  );
}

/// Helper function to map role string to enum
UserRole _mapRoleStringToEnum(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'teacher':
      return UserRole.giangVien;
    case 'student':
    default:
      return UserRole.sinhVien;
  }
}

/// Helper function to map role enum to string
String mapRoleEnumToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Admin';
    case UserRole.giangVien:
      return 'Teacher';
    case UserRole.sinhVien:
      return 'Student';
  }
}

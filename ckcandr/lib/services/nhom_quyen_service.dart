import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/nhom_quyen_model.dart';
import 'package:ckcandr/services/http_client_service.dart';

/// Exception thrown when Nhóm quyền API calls fail
class NhomQuyenApiException implements Exception {
  final String message;
  final int? statusCode;

  NhomQuyenApiException(this.message, {this.statusCode});

  @override
  String toString() => 'NhomQuyenApiException: $message (Status: $statusCode)';
}

/// Service for managing Nhóm quyền (Permission Groups) operations
class NhomQuyenService {
  final HttpClientService _httpClient;

  NhomQuyenService(this._httpClient);

  /// Get all permission groups
  Future<List<NhomQuyen>> getAllPermissionGroups() async {
    try {
      final response = await _httpClient.getList(
        '/api/permission',
        (jsonList) => jsonList.map((json) => NhomQuyen.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw NhomQuyenApiException(response.message ?? 'Failed to get permission groups');
      }
    } on SocketException {
      throw NhomQuyenApiException('No internet connection');
    } catch (e) {
      if (e is NhomQuyenApiException) rethrow;
      throw NhomQuyenApiException('Failed to get permission groups: $e');
    }
  }

  /// Get all available functions
  Future<List<ChucNang>> getAllFunctions() async {
    try {
      final response = await _httpClient.getList(
        '/api/permission/functions',
        (jsonList) => jsonList.map((json) => ChucNang.fromJson(json)).toList(),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw NhomQuyenApiException(response.message ?? 'Failed to get functions');
      }
    } on SocketException {
      throw NhomQuyenApiException('No internet connection');
    } catch (e) {
      if (e is NhomQuyenApiException) rethrow;
      throw NhomQuyenApiException('Failed to get functions: $e');
    }
  }

  /// Get permission group detail by ID
  Future<NhomQuyenDetail> getPermissionGroupDetail(String id) async {
    try {
      final response = await _httpClient.get(
        '/api/permission/$id',
        (json) => NhomQuyenDetail.fromJson(json),
      );

      if (response.success) {
        return response.data!;
      } else {
        throw NhomQuyenApiException(response.message ?? 'Failed to get permission group detail');
      }
    } on SocketException {
      throw NhomQuyenApiException('No internet connection');
    } catch (e) {
      if (e is NhomQuyenApiException) rethrow;
      throw NhomQuyenApiException('Failed to get permission group detail: $e');
    }
  }

  /// Create new permission group
  Future<void> createPermissionGroup(CreateNhomQuyenRequest request) async {
    try {
      final response = await _httpClient.postSimple(
        '/api/permission',
        request.toJson(),
      );

      if (!response.success) {
        throw NhomQuyenApiException(response.message ?? 'Failed to create permission group');
      }
    } on SocketException {
      throw NhomQuyenApiException('No internet connection');
    } catch (e) {
      if (e is NhomQuyenApiException) rethrow;
      throw NhomQuyenApiException('Failed to create permission group: $e');
    }
  }

  /// Update permission group
  Future<void> updatePermissionGroup(String id, UpdateNhomQuyenRequest request) async {
    try {
      final response = await _httpClient.putSimple(
        '/api/permission/$id',
        request.toJson(),
      );

      if (!response.success) {
        throw NhomQuyenApiException(response.message ?? 'Failed to update permission group');
      }
    } on SocketException {
      throw NhomQuyenApiException('No internet connection');
    } catch (e) {
      if (e is NhomQuyenApiException) rethrow;
      throw NhomQuyenApiException('Failed to update permission group: $e');
    }
  }

  /// Delete permission group
  Future<void> deletePermissionGroup(String id) async {
    try {
      final response = await _httpClient.deleteSimple('/api/permission/$id');

      if (!response.success) {
        throw NhomQuyenApiException(response.message ?? 'Failed to delete permission group');
      }
    } on SocketException {
      throw NhomQuyenApiException('No internet connection');
    } catch (e) {
      if (e is NhomQuyenApiException) rethrow;
      throw NhomQuyenApiException('Failed to delete permission group: $e');
    }
  }
}

// ===== PROVIDERS =====

/// Provider for NhomQuyenService
final nhomQuyenServiceProvider = Provider<NhomQuyenService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return NhomQuyenService(httpClient);
});

/// Provider for all permission groups list
final permissionGroupsListProvider = FutureProvider.autoDispose<List<NhomQuyen>>((ref) async {
  final service = ref.watch(nhomQuyenServiceProvider);
  return service.getAllPermissionGroups();
});

/// Provider for all functions list
final functionsListProvider = FutureProvider.autoDispose<List<ChucNang>>((ref) async {
  final service = ref.watch(nhomQuyenServiceProvider);
  return service.getAllFunctions();
});

/// Provider for permission group detail
final permissionGroupDetailProvider = FutureProvider.family<NhomQuyenDetail, String>((ref, id) async {
  final service = ref.watch(nhomQuyenServiceProvider);
  return service.getPermissionGroupDetail(id);
});

/// StateNotifier for managing permission group operations
class NhomQuyenNotifier extends StateNotifier<AsyncValue<List<NhomQuyen>>> {
  final NhomQuyenService _service;

  NhomQuyenNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPermissionGroups();
  }

  /// Load all permission groups
  Future<void> loadPermissionGroups() async {
    state = const AsyncValue.loading();
    try {
      final groups = await _service.getAllPermissionGroups();
      state = AsyncValue.data(groups);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Create new permission group
  Future<void> createPermissionGroup(CreateNhomQuyenRequest request) async {
    try {
      await _service.createPermissionGroup(request);
      await loadPermissionGroups(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  /// Update permission group
  Future<void> updatePermissionGroup(String id, UpdateNhomQuyenRequest request) async {
    try {
      await _service.updatePermissionGroup(id, request);
      await loadPermissionGroups(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete permission group
  Future<void> deletePermissionGroup(String id) async {
    try {
      await _service.deletePermissionGroup(id);
      await loadPermissionGroups(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for NhomQuyenNotifier
final nhomQuyenNotifierProvider = StateNotifierProvider<NhomQuyenNotifier, AsyncValue<List<NhomQuyen>>>((ref) {
  final service = ref.watch(nhomQuyenServiceProvider);
  return NhomQuyenNotifier(service);
});

/// StateNotifier for managing permission group form state
class PermissionGroupFormNotifier extends StateNotifier<PermissionGroupFormState> {
  PermissionGroupFormNotifier() : super(PermissionGroupFormState.initial());

  void setPermissionGroups(List<NhomQuyen> groups) {
    state = state.copyWith(permissionGroups: groups);
  }

  void setFunctions(List<ChucNang> functions) {
    state = state.copyWith(functions: functions);
  }

  void setSelectedGroup(NhomQuyenDetail? group) {
    if (group != null) {
      state = state.copyWith(
        selectedGroup: group,
        tenNhomQuyen: group.tenNhomQuyen,
        thamGiaThi: group.thamGiaThi,
        thamGiaHocPhan: group.thamGiaHocPhan,
        permissions: Map.fromEntries(
          group.permissions.map((p) => MapEntry('${p.chucNang}_${p.hanhDong}', p.isGranted))
        ),
      );
    } else {
      state = PermissionGroupFormState.initial();
    }
  }

  void updateTenNhomQuyen(String value) {
    state = state.copyWith(tenNhomQuyen: value);
  }

  void updateThamGiaThi(bool value) {
    state = state.copyWith(thamGiaThi: value);
  }

  void updateThamGiaHocPhan(bool value) {
    state = state.copyWith(thamGiaHocPhan: value);
  }

  void updatePermission(String chucNang, String hanhDong, bool isGranted) {
    final key = '${chucNang}_$hanhDong';
    final updatedPermissions = Map<String, bool>.from(state.permissions);
    updatedPermissions[key] = isGranted;
    state = state.copyWith(permissions: updatedPermissions);
  }

  void reset() {
    state = PermissionGroupFormState.initial();
  }

  CreateNhomQuyenRequest toCreateRequest() {
    final permissions = <Permission>[];
    
    // Add regular permissions
    state.permissions.forEach((key, isGranted) {
      if (isGranted) {
        final parts = key.split('_');
        if (parts.length == 2) {
          permissions.add(Permission(
            chucNang: parts[0],
            hanhDong: parts[1],
            isGranted: true,
          ));
        }
      }
    });

    // Add special permissions
    if (state.thamGiaThi) {
      permissions.add(const Permission(
        chucNang: 'thamgiathi',
        hanhDong: 'join',
        isGranted: true,
      ));
    }

    if (state.thamGiaHocPhan) {
      permissions.add(const Permission(
        chucNang: 'thamgiahocphan',
        hanhDong: 'join',
        isGranted: true,
      ));
    }

    return CreateNhomQuyenRequest(
      tenNhomQuyen: state.tenNhomQuyen,
      thamGiaThi: state.thamGiaThi,
      thamGiaHocPhan: state.thamGiaHocPhan,
      permissions: permissions,
    );
  }

  UpdateNhomQuyenRequest toUpdateRequest() {
    final permissions = <Permission>[];
    
    // Add regular permissions
    state.permissions.forEach((key, isGranted) {
      if (isGranted) {
        final parts = key.split('_');
        if (parts.length == 2) {
          permissions.add(Permission(
            chucNang: parts[0],
            hanhDong: parts[1],
            isGranted: true,
          ));
        }
      }
    });

    // Add special permissions
    if (state.thamGiaThi) {
      permissions.add(const Permission(
        chucNang: 'thamgiathi',
        hanhDong: 'join',
        isGranted: true,
      ));
    }

    if (state.thamGiaHocPhan) {
      permissions.add(const Permission(
        chucNang: 'thamgiahocphan',
        hanhDong: 'join',
        isGranted: true,
      ));
    }

    return UpdateNhomQuyenRequest(
      tenNhomQuyen: state.tenNhomQuyen,
      thamGiaThi: state.thamGiaThi,
      thamGiaHocPhan: state.thamGiaHocPhan,
      permissions: permissions,
    );
  }
}

/// State class for permission group form
class PermissionGroupFormState {
  final List<NhomQuyen> permissionGroups;
  final List<ChucNang> functions;
  final NhomQuyenDetail? selectedGroup;
  final String tenNhomQuyen;
  final bool thamGiaThi;
  final bool thamGiaHocPhan;
  final Map<String, bool> permissions; // key: "chucNang_hanhDong", value: isGranted

  const PermissionGroupFormState({
    required this.permissionGroups,
    required this.functions,
    this.selectedGroup,
    required this.tenNhomQuyen,
    required this.thamGiaThi,
    required this.thamGiaHocPhan,
    required this.permissions,
  });

  factory PermissionGroupFormState.initial() {
    return const PermissionGroupFormState(
      permissionGroups: [],
      functions: [],
      selectedGroup: null,
      tenNhomQuyen: '',
      thamGiaThi: false,
      thamGiaHocPhan: false,
      permissions: {},
    );
  }

  PermissionGroupFormState copyWith({
    List<NhomQuyen>? permissionGroups,
    List<ChucNang>? functions,
    NhomQuyenDetail? selectedGroup,
    String? tenNhomQuyen,
    bool? thamGiaThi,
    bool? thamGiaHocPhan,
    Map<String, bool>? permissions,
  }) {
    return PermissionGroupFormState(
      permissionGroups: permissionGroups ?? this.permissionGroups,
      functions: functions ?? this.functions,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      tenNhomQuyen: tenNhomQuyen ?? this.tenNhomQuyen,
      thamGiaThi: thamGiaThi ?? this.thamGiaThi,
      thamGiaHocPhan: thamGiaHocPhan ?? this.thamGiaHocPhan,
      permissions: permissions ?? this.permissions,
    );
  }
}

/// Provider for PermissionGroupFormNotifier
final permissionGroupFormNotifierProvider = StateNotifierProvider<PermissionGroupFormNotifier, PermissionGroupFormState>((ref) {
  return PermissionGroupFormNotifier();
});

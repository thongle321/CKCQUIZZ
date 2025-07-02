import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/role_management_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// Provider cho danh sách nhóm quyền
final roleGroupsProvider = StateNotifierProvider<RoleGroupsNotifier, AsyncValue<List<RoleGroup>>>((ref) {
  return RoleGroupsNotifier(ref);
});

class RoleGroupsNotifier extends StateNotifier<AsyncValue<List<RoleGroup>>> {
  final Ref _ref;

  RoleGroupsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadRoleGroups();
  }

  /// Load danh sách nhóm quyền
  Future<void> loadRoleGroups() async {
    try {
      state = const AsyncValue.loading();
      
      final apiService = _ref.read(apiServiceProvider);
      final roleGroups = await apiService.getRoleGroups();
      
      state = AsyncValue.data(roleGroups);
      print('🎯 Role groups loaded: ${roleGroups.length}');
    } catch (error, stackTrace) {
      print('❌ Error loading role groups: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    await loadRoleGroups();
  }

  /// Xóa nhóm quyền
  Future<void> deleteRoleGroup(String id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.deleteRoleGroup(id);
      
      // Refresh danh sách sau khi xóa
      await loadRoleGroups();
      print('✅ Role group deleted and list refreshed');
    } catch (error) {
      print('❌ Error deleting role group: $error');
      rethrow;
    }
  }
}

/// Provider cho chi tiết nhóm quyền
final roleGroupDetailProvider = StateNotifierProvider.family<RoleGroupDetailNotifier, AsyncValue<RoleGroupDetail?>, String>((ref, id) {
  return RoleGroupDetailNotifier(ref, id);
});

class RoleGroupDetailNotifier extends StateNotifier<AsyncValue<RoleGroupDetail?>> {
  final Ref _ref;
  final String _id;

  RoleGroupDetailNotifier(this._ref, this._id) : super(const AsyncValue.loading()) {
    if (_id.isNotEmpty) {
      loadRoleGroupDetail();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  /// Load chi tiết nhóm quyền
  Future<void> loadRoleGroupDetail() async {
    try {
      state = const AsyncValue.loading();
      
      final apiService = _ref.read(apiServiceProvider);
      final detail = await apiService.getRoleGroupDetail(_id);
      
      state = AsyncValue.data(detail);
      print('🎯 Role group detail loaded: ${detail.tenNhomQuyen}');
    } catch (error, stackTrace) {
      print('❌ Error loading role group detail: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider cho danh sách chức năng
final functionsProvider = StateNotifierProvider<FunctionsNotifier, AsyncValue<List<FunctionModel>>>((ref) {
  return FunctionsNotifier(ref);
});

class FunctionsNotifier extends StateNotifier<AsyncValue<List<FunctionModel>>> {
  final Ref _ref;

  FunctionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadFunctions();
  }

  /// Load danh sách chức năng
  Future<void> loadFunctions() async {
    try {
      state = const AsyncValue.loading();
      
      final apiService = _ref.read(apiServiceProvider);
      final functions = await apiService.getFunctions();
      
      state = AsyncValue.data(functions);
      print('🎯 Functions loaded: ${functions.length}');
    } catch (error, stackTrace) {
      print('❌ Error loading functions: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider cho form tạo/sửa nhóm quyền
final roleGroupFormProvider = StateNotifierProvider<RoleGroupFormNotifier, RoleGroupFormState>((ref) {
  return RoleGroupFormNotifier(ref);
});

class RoleGroupFormState {
  final String? id;
  final String tenNhomQuyen;
  final bool thamGiaThi;
  final bool thamGiaHocPhan;
  final List<RolePermission> permissions;
  final bool isLoading;
  final String? error;

  const RoleGroupFormState({
    this.id,
    this.tenNhomQuyen = '',
    this.thamGiaThi = false,
    this.thamGiaHocPhan = false,
    this.permissions = const [],
    this.isLoading = false,
    this.error,
  });

  RoleGroupFormState copyWith({
    String? id,
    String? tenNhomQuyen,
    bool? thamGiaThi,
    bool? thamGiaHocPhan,
    List<RolePermission>? permissions,
    bool? isLoading,
    String? error,
  }) {
    return RoleGroupFormState(
      id: id ?? this.id,
      tenNhomQuyen: tenNhomQuyen ?? this.tenNhomQuyen,
      thamGiaThi: thamGiaThi ?? this.thamGiaThi,
      thamGiaHocPhan: thamGiaHocPhan ?? this.thamGiaHocPhan,
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RoleGroupFormNotifier extends StateNotifier<RoleGroupFormState> {
  final Ref _ref;

  RoleGroupFormNotifier(this._ref) : super(const RoleGroupFormState());

  /// Reset form
  void reset() {
    state = const RoleGroupFormState();
  }

  /// Initialize form với data có sẵn
  void initializeWithData(RoleGroupDetail detail) {
    state = RoleGroupFormState(
      id: detail.id,
      tenNhomQuyen: detail.tenNhomQuyen,
      thamGiaThi: detail.thamGiaThi,
      thamGiaHocPhan: detail.thamGiaHocPhan,
      permissions: detail.permissions,
    );
  }

  /// Initialize form cho tạo mới
  void initializeForCreate(List<FunctionModel> functions) {
    final permissions = PermissionHelper.createDefaultPermissions(functions);
    state = RoleGroupFormState(permissions: permissions);
  }

  /// Update tên nhóm quyền
  void updateTenNhomQuyen(String value) {
    state = state.copyWith(tenNhomQuyen: value);
  }

  /// Toggle tham gia thi
  void toggleThamGiaThi(bool value) {
    state = state.copyWith(thamGiaThi: value);
    _updateSpecialPermission('thamgiathi', 'join', value);
  }

  /// Toggle tham gia học phần
  void toggleThamGiaHocPhan(bool value) {
    state = state.copyWith(thamGiaHocPhan: value);
    _updateSpecialPermission('thamgiahocphan', 'join', value);
  }

  /// Update special permission
  void _updateSpecialPermission(String chucNang, String hanhDong, bool isGranted) {
    final permissions = List<RolePermission>.from(state.permissions);
    final index = permissions.indexWhere((p) => p.chucNang == chucNang && p.hanhDong == hanhDong);
    
    if (index != -1) {
      permissions[index] = permissions[index].copyWith(isGranted: isGranted);
    } else if (isGranted) {
      permissions.add(RolePermission(
        chucNang: chucNang,
        hanhDong: hanhDong,
        isGranted: true,
      ));
    }
    
    state = state.copyWith(permissions: permissions);
  }

  /// Toggle permission
  void togglePermission(String chucNang, String hanhDong, bool isGranted) {
    final permissions = List<RolePermission>.from(state.permissions);
    final index = permissions.indexWhere((p) => p.chucNang == chucNang && p.hanhDong == hanhDong);
    
    if (index != -1) {
      permissions[index] = permissions[index].copyWith(isGranted: isGranted);
    } else if (isGranted) {
      permissions.add(RolePermission(
        chucNang: chucNang,
        hanhDong: hanhDong,
        isGranted: true,
      ));
    }
    
    state = state.copyWith(permissions: permissions);
  }

  /// Check if permission is granted
  bool isPermissionGranted(String chucNang, String hanhDong) {
    return state.permissions.any((p) => 
      p.chucNang == chucNang && 
      p.hanhDong == hanhDong && 
      p.isGranted
    );
  }

  /// Save role group
  Future<bool> save() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final apiService = _ref.read(apiServiceProvider);
      final request = RoleGroupRequest(
        id: state.id,
        tenNhomQuyen: state.tenNhomQuyen,
        thamGiaThi: state.thamGiaThi,
        thamGiaHocPhan: state.thamGiaHocPhan,
        permissions: state.permissions.where((p) => p.isGranted).toList(),
      );

      if (state.id != null) {
        await apiService.updateRoleGroup(state.id!, request);
      } else {
        await apiService.createRoleGroup(request);
      }

      // Refresh danh sách nhóm quyền
      _ref.read(roleGroupsProvider.notifier).refresh();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }
}

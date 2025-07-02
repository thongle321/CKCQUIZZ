import 'package:json_annotation/json_annotation.dart';

part 'role_management_model.g.dart';

/// Model cho danh sách nhóm quyền
@JsonSerializable()
class RoleGroup {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'soNguoiDung')
  final int soNguoiDung;

  @JsonKey(name: 'permissions')
  final List<RolePermission>? permissions;

  const RoleGroup({
    required this.id,
    required this.tenNhomQuyen,
    required this.soNguoiDung,
    this.permissions,
  });

  factory RoleGroup.fromJson(Map<String, dynamic> json) => 
      _$RoleGroupFromJson(json);
  Map<String, dynamic> toJson() => _$RoleGroupToJson(this);
}

/// Model cho chi tiết nhóm quyền
@JsonSerializable()
class RoleGroupDetail {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'thamGiaThi')
  final bool thamGiaThi;

  @JsonKey(name: 'thamGiaHocPhan')
  final bool thamGiaHocPhan;

  @JsonKey(name: 'permissions')
  final List<RolePermission> permissions;

  const RoleGroupDetail({
    required this.id,
    required this.tenNhomQuyen,
    required this.thamGiaThi,
    required this.thamGiaHocPhan,
    required this.permissions,
  });

  factory RoleGroupDetail.fromJson(Map<String, dynamic> json) => 
      _$RoleGroupDetailFromJson(json);
  Map<String, dynamic> toJson() => _$RoleGroupDetailToJson(this);

  /// Get filtered permissions (excluding special join permissions)
  List<RolePermission> get filteredPermissions {
    return permissions.where((p) => 
        p.chucNang != "thamgiathi" && 
        p.chucNang != "thamgiahocphan"
    ).toList();
  }
}

/// Model cho quyền
@JsonSerializable()
class RolePermission {
  @JsonKey(name: 'chucNang')
  final String chucNang;

  @JsonKey(name: 'hanhDong')
  final String hanhDong;

  @JsonKey(name: 'isGranted')
  final bool isGranted;

  const RolePermission({
    required this.chucNang,
    required this.hanhDong,
    required this.isGranted,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) => 
      _$RolePermissionFromJson(json);
  Map<String, dynamic> toJson() => _$RolePermissionToJson(this);

  RolePermission copyWith({
    String? chucNang,
    String? hanhDong,
    bool? isGranted,
  }) {
    return RolePermission(
      chucNang: chucNang ?? this.chucNang,
      hanhDong: hanhDong ?? this.hanhDong,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}

/// Model cho chức năng
@JsonSerializable()
class FunctionModel {
  @JsonKey(name: 'chucNang')
  final String chucNang;

  @JsonKey(name: 'tenChucNang')
  final String tenChucNang;

  const FunctionModel({
    required this.chucNang,
    required this.tenChucNang,
  });

  factory FunctionModel.fromJson(Map<String, dynamic> json) => 
      _$FunctionModelFromJson(json);
  Map<String, dynamic> toJson() => _$FunctionModelToJson(this);
}

/// Request model cho tạo/cập nhật nhóm quyền
@JsonSerializable()
class RoleGroupRequest {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'thamGiaThi')
  final bool thamGiaThi;

  @JsonKey(name: 'thamGiaHocPhan')
  final bool thamGiaHocPhan;

  @JsonKey(name: 'permissions')
  final List<RolePermission> permissions;

  const RoleGroupRequest({
    this.id,
    required this.tenNhomQuyen,
    required this.thamGiaThi,
    required this.thamGiaHocPhan,
    required this.permissions,
  });

  factory RoleGroupRequest.fromJson(Map<String, dynamic> json) => 
      _$RoleGroupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RoleGroupRequestToJson(this);
}

/// Enum cho các hành động quyền
enum PermissionAction {
  view('view', 'Xem'),
  create('create', 'Thêm'),
  update('update', 'Sửa'),
  delete('delete', 'Xóa');

  const PermissionAction(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Helper class cho quản lý quyền
class PermissionHelper {
  static const List<String> specialFunctions = ['thamgiathi', 'thamgiahocphan'];
  
  static bool isSpecialFunction(String chucNang) {
    return specialFunctions.contains(chucNang);
  }
  
  static List<RolePermission> createDefaultPermissions(List<FunctionModel> functions) {
    final permissions = <RolePermission>[];

    for (final function in functions) {
      if (!isSpecialFunction(function.chucNang)) {
        for (final action in PermissionAction.values) {
          permissions.add(RolePermission(
            chucNang: function.chucNang,
            hanhDong: action.value,
            isGranted: false,
          ));
        }
      }
    }

    return permissions;
  }

  static List<FunctionModel> getFilteredFunctions(List<FunctionModel> allFunctions) {
    return allFunctions.where((f) => !isSpecialFunction(f.chucNang)).toList();
  }
}

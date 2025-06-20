import 'package:json_annotation/json_annotation.dart';

part 'nhom_quyen_model.g.dart';

/// Model cho Nhóm quyền
@JsonSerializable()
class NhomQuyen {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'soNguoiDung')
  final int? soNguoiDung;

  @JsonKey(name: 'permissions')
  final List<Permission>? permissions;

  const NhomQuyen({
    this.id,
    required this.tenNhomQuyen,
    this.soNguoiDung,
    this.permissions,
  });

  factory NhomQuyen.fromJson(Map<String, dynamic> json) => _$NhomQuyenFromJson(json);
  Map<String, dynamic> toJson() => _$NhomQuyenToJson(this);

  NhomQuyen copyWith({
    String? id,
    String? tenNhomQuyen,
    int? soNguoiDung,
    List<Permission>? permissions,
  }) {
    return NhomQuyen(
      id: id ?? this.id,
      tenNhomQuyen: tenNhomQuyen ?? this.tenNhomQuyen,
      soNguoiDung: soNguoiDung ?? this.soNguoiDung,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NhomQuyen && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NhomQuyen(id: $id, tenNhomQuyen: $tenNhomQuyen, soNguoiDung: $soNguoiDung)';
}

/// Model cho Permission (quyền)
@JsonSerializable()
class Permission {
  @JsonKey(name: 'chucNang')
  final String chucNang;

  @JsonKey(name: 'hanhDong')
  final String hanhDong;

  @JsonKey(name: 'isGranted')
  final bool isGranted;

  const Permission({
    required this.chucNang,
    required this.hanhDong,
    required this.isGranted,
  });

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);

  Permission copyWith({
    String? chucNang,
    String? hanhDong,
    bool? isGranted,
  }) {
    return Permission(
      chucNang: chucNang ?? this.chucNang,
      hanhDong: hanhDong ?? this.hanhDong,
      isGranted: isGranted ?? this.isGranted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission &&
        other.chucNang == chucNang &&
        other.hanhDong == hanhDong;
  }

  @override
  int get hashCode => Object.hash(chucNang, hanhDong);

  @override
  String toString() => 'Permission(chucNang: $chucNang, hanhDong: $hanhDong, isGranted: $isGranted)';
}

/// Model cho ChucNang (chức năng)
@JsonSerializable()
class ChucNang {
  @JsonKey(name: 'chucNang')
  final String chucNang;

  @JsonKey(name: 'tenChucNang')
  final String tenChucNang;

  const ChucNang({
    required this.chucNang,
    required this.tenChucNang,
  });

  factory ChucNang.fromJson(Map<String, dynamic> json) => _$ChucNangFromJson(json);
  Map<String, dynamic> toJson() => _$ChucNangToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChucNang && other.chucNang == chucNang;
  }

  @override
  int get hashCode => chucNang.hashCode;

  @override
  String toString() => 'ChucNang(chucNang: $chucNang, tenChucNang: $tenChucNang)';
}

/// Model cho request tạo nhóm quyền mới
@JsonSerializable()
class CreateNhomQuyenRequest {
  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'thamGiaThi')
  final bool thamGiaThi;

  @JsonKey(name: 'thamGiaHocPhan')
  final bool thamGiaHocPhan;

  @JsonKey(name: 'permissions')
  final List<Permission> permissions;

  const CreateNhomQuyenRequest({
    required this.tenNhomQuyen,
    required this.thamGiaThi,
    required this.thamGiaHocPhan,
    required this.permissions,
  });

  factory CreateNhomQuyenRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateNhomQuyenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateNhomQuyenRequestToJson(this);
}

/// Model cho request cập nhật nhóm quyền
@JsonSerializable()
class UpdateNhomQuyenRequest {
  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'thamGiaThi')
  final bool thamGiaThi;

  @JsonKey(name: 'thamGiaHocPhan')
  final bool thamGiaHocPhan;

  @JsonKey(name: 'permissions')
  final List<Permission> permissions;

  const UpdateNhomQuyenRequest({
    required this.tenNhomQuyen,
    required this.thamGiaThi,
    required this.thamGiaHocPhan,
    required this.permissions,
  });

  factory UpdateNhomQuyenRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateNhomQuyenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateNhomQuyenRequestToJson(this);
}

/// Model cho chi tiết nhóm quyền
@JsonSerializable()
class NhomQuyenDetail {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'tenNhomQuyen')
  final String tenNhomQuyen;

  @JsonKey(name: 'permissions')
  final List<Permission> permissions;

  const NhomQuyenDetail({
    required this.id,
    required this.tenNhomQuyen,
    required this.permissions,
  });

  factory NhomQuyenDetail.fromJson(Map<String, dynamic> json) => 
      _$NhomQuyenDetailFromJson(json);
  Map<String, dynamic> toJson() => _$NhomQuyenDetailToJson(this);

  /// Get special permissions
  bool get thamGiaThi {
    return permissions.any((p) => p.chucNang == "thamgiathi" && p.hanhDong == "join" && p.isGranted);
  }

  bool get thamGiaHocPhan {
    return permissions.any((p) => p.chucNang == "thamgiahocphan" && p.hanhDong == "join" && p.isGranted);
  }

  /// Get filtered permissions (excluding special join permissions)
  List<Permission> get filteredPermissions {
    return permissions.where((p) => 
        p.chucNang != "thamgiathi" && 
        p.chucNang != "thamgiahocphan"
    ).toList();
  }
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
  
  static List<Permission> createDefaultPermissions(List<ChucNang> functions) {
    final permissions = <Permission>[];

    for (final function in functions) {
      if (!isSpecialFunction(function.chucNang)) {
        for (final action in PermissionAction.values) {
          permissions.add(Permission(
            chucNang: function.chucNang,
            hanhDong: action.value,
            isGranted: false,
          ));
        }
      }
    }

    return permissions;
  }
  
  static List<Permission> addSpecialPermissions(
    List<Permission> permissions, 
    bool thamGiaThi, 
    bool thamGiaHocPhan
  ) {
    final result = List<Permission>.from(permissions);
    
    if (thamGiaThi) {
      result.add(const Permission(
        chucNang: 'thamgiathi',
        hanhDong: 'join',
        isGranted: true,
      ));
    }
    
    if (thamGiaHocPhan) {
      result.add(const Permission(
        chucNang: 'thamgiahocphan',
        hanhDong: 'join',
        isGranted: true,
      ));
    }
    
    return result;
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_management_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleGroup _$RoleGroupFromJson(Map<String, dynamic> json) => RoleGroup(
      id: json['id'] as String,
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      soNguoiDung: (json['soNguoiDung'] as num).toInt(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => RolePermission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoleGroupToJson(RoleGroup instance) => <String, dynamic>{
      'id': instance.id,
      'tenNhomQuyen': instance.tenNhomQuyen,
      'soNguoiDung': instance.soNguoiDung,
      'permissions': instance.permissions,
    };

RoleGroupDetail _$RoleGroupDetailFromJson(Map<String, dynamic> json) =>
    RoleGroupDetail(
      id: json['id'] as String,
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      thamGiaThi: json['thamGiaThi'] as bool,
      thamGiaHocPhan: json['thamGiaHocPhan'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => RolePermission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoleGroupDetailToJson(RoleGroupDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenNhomQuyen': instance.tenNhomQuyen,
      'thamGiaThi': instance.thamGiaThi,
      'thamGiaHocPhan': instance.thamGiaHocPhan,
      'permissions': instance.permissions,
    };

RolePermission _$RolePermissionFromJson(Map<String, dynamic> json) =>
    RolePermission(
      chucNang: json['chucNang'] as String,
      hanhDong: json['hanhDong'] as String,
      isGranted: json['isGranted'] as bool,
    );

Map<String, dynamic> _$RolePermissionToJson(RolePermission instance) =>
    <String, dynamic>{
      'chucNang': instance.chucNang,
      'hanhDong': instance.hanhDong,
      'isGranted': instance.isGranted,
    };

FunctionModel _$FunctionModelFromJson(Map<String, dynamic> json) =>
    FunctionModel(
      chucNang: json['chucNang'] as String,
      tenChucNang: json['tenChucNang'] as String,
    );

Map<String, dynamic> _$FunctionModelToJson(FunctionModel instance) =>
    <String, dynamic>{
      'chucNang': instance.chucNang,
      'tenChucNang': instance.tenChucNang,
    };

RoleGroupRequest _$RoleGroupRequestFromJson(Map<String, dynamic> json) =>
    RoleGroupRequest(
      id: json['id'] as String?,
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      thamGiaThi: json['thamGiaThi'] as bool,
      thamGiaHocPhan: json['thamGiaHocPhan'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => RolePermission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoleGroupRequestToJson(RoleGroupRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenNhomQuyen': instance.tenNhomQuyen,
      'thamGiaThi': instance.thamGiaThi,
      'thamGiaHocPhan': instance.thamGiaHocPhan,
      'permissions': instance.permissions,
    };

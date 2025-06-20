// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nhom_quyen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NhomQuyen _$NhomQuyenFromJson(Map<String, dynamic> json) => NhomQuyen(
      id: json['id'] as String?,
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      soNguoiDung: (json['soNguoiDung'] as num?)?.toInt(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => Permission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NhomQuyenToJson(NhomQuyen instance) => <String, dynamic>{
      'id': instance.id,
      'tenNhomQuyen': instance.tenNhomQuyen,
      'soNguoiDung': instance.soNguoiDung,
      'permissions': instance.permissions,
    };

Permission _$PermissionFromJson(Map<String, dynamic> json) => Permission(
      chucNang: json['chucNang'] as String,
      hanhDong: json['hanhDong'] as String,
      isGranted: json['isGranted'] as bool,
    );

Map<String, dynamic> _$PermissionToJson(Permission instance) =>
    <String, dynamic>{
      'chucNang': instance.chucNang,
      'hanhDong': instance.hanhDong,
      'isGranted': instance.isGranted,
    };

ChucNang _$ChucNangFromJson(Map<String, dynamic> json) => ChucNang(
      chucNang: json['chucNang'] as String,
      tenChucNang: json['tenChucNang'] as String,
    );

Map<String, dynamic> _$ChucNangToJson(ChucNang instance) => <String, dynamic>{
      'chucNang': instance.chucNang,
      'tenChucNang': instance.tenChucNang,
    };

CreateNhomQuyenRequest _$CreateNhomQuyenRequestFromJson(
        Map<String, dynamic> json) =>
    CreateNhomQuyenRequest(
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      thamGiaThi: json['thamGiaThi'] as bool,
      thamGiaHocPhan: json['thamGiaHocPhan'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => Permission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateNhomQuyenRequestToJson(
        CreateNhomQuyenRequest instance) =>
    <String, dynamic>{
      'tenNhomQuyen': instance.tenNhomQuyen,
      'thamGiaThi': instance.thamGiaThi,
      'thamGiaHocPhan': instance.thamGiaHocPhan,
      'permissions': instance.permissions,
    };

UpdateNhomQuyenRequest _$UpdateNhomQuyenRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateNhomQuyenRequest(
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      thamGiaThi: json['thamGiaThi'] as bool,
      thamGiaHocPhan: json['thamGiaHocPhan'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => Permission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateNhomQuyenRequestToJson(
        UpdateNhomQuyenRequest instance) =>
    <String, dynamic>{
      'tenNhomQuyen': instance.tenNhomQuyen,
      'thamGiaThi': instance.thamGiaThi,
      'thamGiaHocPhan': instance.thamGiaHocPhan,
      'permissions': instance.permissions,
    };

NhomQuyenDetail _$NhomQuyenDetailFromJson(Map<String, dynamic> json) =>
    NhomQuyenDetail(
      id: json['id'] as String,
      tenNhomQuyen: json['tenNhomQuyen'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => Permission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NhomQuyenDetailToJson(NhomQuyenDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenNhomQuyen': instance.tenNhomQuyen,
      'permissions': instance.permissions,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thong_bao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThongBao _$ThongBaoFromJson(Map<String, dynamic> json) => ThongBao(
      maTb: (json['matb'] as num?)?.toInt(),
      noiDung: json['noidung'] as String,
      maMonHoc: json['mamonhoc'] as String?,
      tenMonHoc: json['tenmonhoc'] as String?,
      namHoc: (json['namhoc'] as num?)?.toInt(),
      hocKy: (json['hocky'] as num?)?.toInt(),
      thoiGianTao: json['thoigiantao'] == null
          ? null
          : DateTime.parse(json['thoigiantao'] as String),
      nhom: (json['nhom'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ThongBaoToJson(ThongBao instance) => <String, dynamic>{
      'matb': instance.maTb,
      'noidung': instance.noiDung,
      'mamonhoc': instance.maMonHoc,
      'tenmonhoc': instance.tenMonHoc,
      'namhoc': instance.namHoc,
      'hocky': instance.hocKy,
      'thoigiantao': instance.thoiGianTao?.toIso8601String(),
      'nhom': instance.nhom,
    };

CreateThongBaoRequest _$CreateThongBaoRequestFromJson(
        Map<String, dynamic> json) =>
    CreateThongBaoRequest(
      noiDung: json['noidung'] as String,
      nhomIds: (json['nhomIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CreateThongBaoRequestToJson(
        CreateThongBaoRequest instance) =>
    <String, dynamic>{
      'noidung': instance.noiDung,
      'nhomIds': instance.nhomIds,
    };

UpdateThongBaoRequest _$UpdateThongBaoRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateThongBaoRequest(
      noiDung: json['noidung'] as String,
      nhomIds: (json['nhomIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UpdateThongBaoRequestToJson(
        UpdateThongBaoRequest instance) =>
    <String, dynamic>{
      'noidung': instance.noiDung,
      'nhomIds': instance.nhomIds,
    };

ThongBaoDetail _$ThongBaoDetailFromJson(Map<String, dynamic> json) =>
    ThongBaoDetail(
      maTb: (json['matb'] as num).toInt(),
      noiDung: json['noidung'] as String,
      maMonHoc: (json['mamonhoc'] as num).toInt(),
      nhom: (json['nhom'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ThongBaoDetailToJson(ThongBaoDetail instance) =>
    <String, dynamic>{
      'matb': instance.maTb,
      'noidung': instance.noiDung,
      'mamonhoc': instance.maMonHoc,
      'nhom': instance.nhom,
    };

SubjectWithGroups _$SubjectWithGroupsFromJson(Map<String, dynamic> json) =>
    SubjectWithGroups(
      maMonHoc: json['mamonhoc'] as String,
      tenMonHoc: json['tenmonhoc'] as String,
      namHoc: json['namhoc'] as String,
      hocKy: (json['hocky'] as num).toInt(),
      nhomLop: (json['nhomLop'] as List<dynamic>)
          .map((e) => NhomLop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectWithGroupsToJson(SubjectWithGroups instance) =>
    <String, dynamic>{
      'mamonhoc': instance.maMonHoc,
      'tenmonhoc': instance.tenMonHoc,
      'namhoc': instance.namHoc,
      'hocky': instance.hocKy,
      'nhomLop': instance.nhomLop,
    };

NhomLop _$NhomLopFromJson(Map<String, dynamic> json) => NhomLop(
      maNhom: json['manhom'] as String,
      tenNhom: json['tennhom'] as String,
    );

Map<String, dynamic> _$NhomLopToJson(NhomLop instance) => <String, dynamic>{
      'manhom': instance.maNhom,
      'tennhom': instance.tenNhom,
    };

ThongBaoPagedResponse _$ThongBaoPagedResponseFromJson(
        Map<String, dynamic> json) =>
    ThongBaoPagedResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ThongBao.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$ThongBaoPagedResponseToJson(
        ThongBaoPagedResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
    };

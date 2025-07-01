// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thong_bao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThongBao _$ThongBaoFromJson(Map<String, dynamic> json) => ThongBao(
      maTb: (json['matb'] as num?)?.toInt(),
      noiDung: json['noidung'] as String,
      maMonHoc: (json['mamonhoc'] as num?)?.toInt(),
      tenMonHoc: json['tenmonhoc'] as String?,
      namHoc: (json['namhoc'] as num?)?.toInt(),
      hocKy: (json['hocky'] as num?)?.toInt(),
      thoiGianTao: json['thoigiantao'] == null
          ? null
          : DateTime.parse(json['thoigiantao'] as String),
      nhom: (json['nhom'] as List<dynamic>?)?.map((e) => e as String).toList(),
      nguoiTao: json['nguoitao'] as String?,
      hoTenNguoiTao: json['hoten'] as String?,
      avatarNguoiTao: json['avatar'] as String?,
      tenLop: json['tennhom'] as String?,
      maLop: (json['manhom'] as num?)?.toInt(),
      examId: (json['examId'] as num?)?.toInt(),
      examStartTime: json['examStartTime'] == null
          ? null
          : DateTime.parse(json['examStartTime'] as String),
      examEndTime: json['examEndTime'] == null
          ? null
          : DateTime.parse(json['examEndTime'] as String),
      examName: json['examName'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.general,
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
      'nguoitao': instance.nguoiTao,
      'hoten': instance.hoTenNguoiTao,
      'avatar': instance.avatarNguoiTao,
      'tennhom': instance.tenLop,
      'manhom': instance.maLop,
      'examId': instance.examId,
      'examStartTime': instance.examStartTime?.toIso8601String(),
      'examEndTime': instance.examEndTime?.toIso8601String(),
      'examName': instance.examName,
      'isRead': instance.isRead,
      'type': _$NotificationTypeEnumMap[instance.type]!,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.general: 'general',
  NotificationType.examNew: 'examNew',
  NotificationType.examReminder: 'examReminder',
  NotificationType.examUpdate: 'examUpdate',
  NotificationType.examResult: 'examResult',
  NotificationType.classInfo: 'classInfo',
  NotificationType.system: 'system',
};

CreateThongBaoRequest _$CreateThongBaoRequestFromJson(
        Map<String, dynamic> json) =>
    CreateThongBaoRequest(
      noiDung: json['noidung'] as String,
      thoigiantao: json['thoigiantao'] == null
          ? null
          : DateTime.parse(json['thoigiantao'] as String),
      nhomIds: (json['nhomIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CreateThongBaoRequestToJson(
        CreateThongBaoRequest instance) =>
    <String, dynamic>{
      'noidung': instance.noiDung,
      'thoigiantao': instance.thoigiantao?.toIso8601String(),
      'nhomIds': instance.nhomIds,
    };

UpdateThongBaoRequest _$UpdateThongBaoRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateThongBaoRequest(
      noiDung: json['noidung'] as String,
      thoigiantao: json['thoigiantao'] == null
          ? null
          : DateTime.parse(json['thoigiantao'] as String),
      nguoitao: json['nguoitao'] as String,
      nhomIds: (json['nhomIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UpdateThongBaoRequestToJson(
        UpdateThongBaoRequest instance) =>
    <String, dynamic>{
      'noidung': instance.noiDung,
      'thoigiantao': instance.thoigiantao?.toIso8601String(),
      'nguoitao': instance.nguoitao,
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

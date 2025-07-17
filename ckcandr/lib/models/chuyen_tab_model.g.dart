// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chuyen_tab_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChuyenTabResponse _$ChuyenTabResponseFromJson(Map<String, dynamic> json) =>
    ChuyenTabResponse(
      soLanHienTai: (json['soLanHienTai'] as num).toInt(),
      nopBai: json['nopBai'] as bool,
      thongBao: json['thongBao'] as String,
      gioiHan: (json['gioiHan'] as num).toInt(),
    );

Map<String, dynamic> _$ChuyenTabResponseToJson(ChuyenTabResponse instance) =>
    <String, dynamic>{
      'soLanHienTai': instance.soLanHienTai,
      'nopBai': instance.nopBai,
      'thongBao': instance.thongBao,
      'gioiHan': instance.gioiHan,
    };

ChuyenTabRequest _$ChuyenTabRequestFromJson(Map<String, dynamic> json) =>
    ChuyenTabRequest(
      ketQuaId: (json['ketQuaId'] as num).toInt(),
    );

Map<String, dynamic> _$ChuyenTabRequestToJson(ChuyenTabRequest instance) =>
    <String, dynamic>{
      'ketQuaId': instance.ketQuaId,
    };

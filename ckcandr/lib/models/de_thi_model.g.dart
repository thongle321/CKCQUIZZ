// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'de_thi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeThiModel _$DeThiModelFromJson(Map<String, dynamic> json) => DeThiModel(
      made: (json['made'] as num).toInt(),
      tende: json['tende'] as String?,
      giaoCho: json['giaoCho'] as String,
      monthi: (json['monthi'] as num).toInt(),
      thoigianbatdau: json['thoigianbatdau'] == null
          ? null
          : DateTime.parse(json['thoigianbatdau'] as String),
      thoigianketthuc: json['thoigianketthuc'] == null
          ? null
          : DateTime.parse(json['thoigianketthuc'] as String),
      trangthai: json['trangthai'] as bool,
    );

Map<String, dynamic> _$DeThiModelToJson(DeThiModel instance) =>
    <String, dynamic>{
      'made': instance.made,
      'tende': instance.tende,
      'giaoCho': instance.giaoCho,
      'monthi': instance.monthi,
      'thoigianbatdau': instance.thoigianbatdau?.toIso8601String(),
      'thoigianketthuc': instance.thoigianketthuc?.toIso8601String(),
      'trangthai': instance.trangthai,
    };

DeThiDetailModel _$DeThiDetailModelFromJson(Map<String, dynamic> json) =>
    DeThiDetailModel(
      made: (json['made'] as num).toInt(),
      tende: json['tende'] as String?,
      monthi: (json['monthi'] as num?)?.toInt(),
      thoigianthi: (json['thoigianthi'] as num).toInt(),
      thoigiantbatdau: json['thoigiantbatdau'] == null
          ? null
          : DateTime.parse(json['thoigiantbatdau'] as String),
      thoigianketthuc: json['thoigianketthuc'] == null
          ? null
          : DateTime.parse(json['thoigianketthuc'] as String),
      hienthibailam: json['hienthibailam'] as bool,
      xemdiemthi: json['xemdiemthi'] as bool,
      xemdapan: json['xemdapan'] as bool,
      troncauhoi: json['troncauhoi'] as bool,
      loaide: (json['loaide'] as num).toInt(),
      socaude: (json['socaude'] as num).toInt(),
      socautb: (json['socautb'] as num).toInt(),
      socaukho: (json['socaukho'] as num).toInt(),
      malops: (json['malops'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      machuongs: (json['machuongs'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$DeThiDetailModelToJson(DeThiDetailModel instance) =>
    <String, dynamic>{
      'made': instance.made,
      'tende': instance.tende,
      'monthi': instance.monthi,
      'thoigianthi': instance.thoigianthi,
      'thoigiantbatdau': instance.thoigiantbatdau?.toIso8601String(),
      'thoigianketthuc': instance.thoigianketthuc?.toIso8601String(),
      'hienthibailam': instance.hienthibailam,
      'xemdiemthi': instance.xemdiemthi,
      'xemdapan': instance.xemdapan,
      'troncauhoi': instance.troncauhoi,
      'loaide': instance.loaide,
      'socaude': instance.socaude,
      'socautb': instance.socautb,
      'socaukho': instance.socaukho,
      'malops': instance.malops,
      'machuongs': instance.machuongs,
    };

DeThiCreateRequest _$DeThiCreateRequestFromJson(Map<String, dynamic> json) =>
    DeThiCreateRequest(
      tende: json['tende'] as String,
      thoigianbatdau: DateTime.parse(json['thoigianbatdau'] as String),
      thoigianketthuc: DateTime.parse(json['thoigianketthuc'] as String),
      thoigianthi: (json['thoigianthi'] as num).toInt(),
      monthi: (json['monthi'] as num).toInt(),
      malops: (json['malops'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      xemdiemthi: json['xemdiemthi'] as bool,
      hienthibailam: json['hienthibailam'] as bool,
      xemdapan: json['xemdapan'] as bool,
      troncauhoi: json['troncauhoi'] as bool,
      loaide: (json['loaide'] as num).toInt(),
      machuongs: (json['machuongs'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      socaude: (json['socaude'] as num).toInt(),
      socautb: (json['socautb'] as num).toInt(),
      socaukho: (json['socaukho'] as num).toInt(),
    );

Map<String, dynamic> _$DeThiCreateRequestToJson(DeThiCreateRequest instance) =>
    <String, dynamic>{
      'tende': instance.tende,
      'thoigianbatdau': instance.thoigianbatdau.toIso8601String(),
      'thoigianketthuc': instance.thoigianketthuc.toIso8601String(),
      'thoigianthi': instance.thoigianthi,
      'monthi': instance.monthi,
      'malops': instance.malops,
      'xemdiemthi': instance.xemdiemthi,
      'hienthibailam': instance.hienthibailam,
      'xemdapan': instance.xemdapan,
      'troncauhoi': instance.troncauhoi,
      'loaide': instance.loaide,
      'machuongs': instance.machuongs,
      'socaude': instance.socaude,
      'socautb': instance.socautb,
      'socaukho': instance.socaukho,
    };

DeThiUpdateRequest _$DeThiUpdateRequestFromJson(Map<String, dynamic> json) =>
    DeThiUpdateRequest(
      tende: json['tende'] as String,
      thoigianbatdau: DateTime.parse(json['thoigianbatdau'] as String),
      thoigianketthuc: DateTime.parse(json['thoigianketthuc'] as String),
      thoigianthi: (json['thoigianthi'] as num).toInt(),
      monthi: (json['monthi'] as num).toInt(),
      malops: (json['malops'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      xemdiemthi: json['xemdiemthi'] as bool,
      hienthibailam: json['hienthibailam'] as bool,
      xemdapan: json['xemdapan'] as bool,
      troncauhoi: json['troncauhoi'] as bool,
      loaide: (json['loaide'] as num).toInt(),
      machuongs: (json['machuongs'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      socaude: (json['socaude'] as num).toInt(),
      socautb: (json['socautb'] as num).toInt(),
      socaukho: (json['socaukho'] as num).toInt(),
    );

Map<String, dynamic> _$DeThiUpdateRequestToJson(DeThiUpdateRequest instance) =>
    <String, dynamic>{
      'tende': instance.tende,
      'thoigianbatdau': instance.thoigianbatdau.toIso8601String(),
      'thoigianketthuc': instance.thoigianketthuc.toIso8601String(),
      'thoigianthi': instance.thoigianthi,
      'monthi': instance.monthi,
      'malops': instance.malops,
      'xemdiemthi': instance.xemdiemthi,
      'hienthibailam': instance.hienthibailam,
      'xemdapan': instance.xemdapan,
      'troncauhoi': instance.troncauhoi,
      'loaide': instance.loaide,
      'machuongs': instance.machuongs,
      'socaude': instance.socaude,
      'socautb': instance.socautb,
      'socaukho': instance.socaukho,
    };

CauHoiSoanThaoModel _$CauHoiSoanThaoModelFromJson(Map<String, dynamic> json) =>
    CauHoiSoanThaoModel(
      macauhoi: (json['macauhoi'] as num).toInt(),
      noiDung: json['noiDung'] as String,
      doKho: json['doKho'] as String,
    );

Map<String, dynamic> _$CauHoiSoanThaoModelToJson(
        CauHoiSoanThaoModel instance) =>
    <String, dynamic>{
      'macauhoi': instance.macauhoi,
      'noiDung': instance.noiDung,
      'doKho': instance.doKho,
    };

DapAnSoanThaoRequest _$DapAnSoanThaoRequestFromJson(
        Map<String, dynamic> json) =>
    DapAnSoanThaoRequest(
      cauHoiIds: (json['cauHoiIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$DapAnSoanThaoRequestToJson(
        DapAnSoanThaoRequest instance) =>
    <String, dynamic>{
      'cauHoiIds': instance.cauHoiIds,
    };

ExamForClassModel _$ExamForClassModelFromJson(Map<String, dynamic> json) =>
    ExamForClassModel(
      made: (json['made'] as num).toInt(),
      tende: json['tende'] as String?,
      tenMonHoc: json['tenMonHoc'] as String?,
      tongSoCau: (json['tongSoCau'] as num).toInt(),
      thoigianthi: (json['thoigianthi'] as num?)?.toInt(),
      thoigiantbatdau: json['thoigiantbatdau'] == null
          ? null
          : DateTime.parse(json['thoigiantbatdau'] as String),
      thoigianketthuc: json['thoigianketthuc'] == null
          ? null
          : DateTime.parse(json['thoigianketthuc'] as String),
      trangthaiThi: json['trangthaiThi'] as String,
      ketQuaId: (json['ketQuaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExamForClassModelToJson(ExamForClassModel instance) =>
    <String, dynamic>{
      'made': instance.made,
      'tende': instance.tende,
      'tenMonHoc': instance.tenMonHoc,
      'tongSoCau': instance.tongSoCau,
      'thoigianthi': instance.thoigianthi,
      'thoigiantbatdau': instance.thoigiantbatdau?.toIso8601String(),
      'thoigianketthuc': instance.thoigianketthuc?.toIso8601String(),
      'trangthaiThi': instance.trangthaiThi,
      'ketQuaId': instance.ketQuaId,
    };

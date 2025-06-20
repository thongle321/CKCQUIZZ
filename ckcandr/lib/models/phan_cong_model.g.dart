// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phan_cong_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhanCong _$PhanCongFromJson(Map<String, dynamic> json) => PhanCong(
      id: (json['id'] as num?)?.toInt(),
      maNguoiDung: json['manguoidung'] as String,
      hoTen: json['hoten'] as String,
      maMonHoc: (json['mamonhoc'] as num).toInt(),
      tenMonHoc: json['tenmonhoc'] as String,
      soTinChi: (json['sotinchi'] as num?)?.toInt(),
      soTietLyThuyet: (json['sotietlythuyet'] as num?)?.toInt(),
      soTietThucHanh: (json['sotietthuchanh'] as num?)?.toInt(),
      trangThai: json['trangthai'] as bool?,
    );

Map<String, dynamic> _$PhanCongToJson(PhanCong instance) => <String, dynamic>{
      'id': instance.id,
      'manguoidung': instance.maNguoiDung,
      'hoten': instance.hoTen,
      'mamonhoc': instance.maMonHoc,
      'tenmonhoc': instance.tenMonHoc,
      'sotinchi': instance.soTinChi,
      'sotietlythuyet': instance.soTietLyThuyet,
      'sotietthuchanh': instance.soTietThucHanh,
      'trangthai': instance.trangThai,
    };

CreatePhanCongRequest _$CreatePhanCongRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePhanCongRequest(
      giangVienId: json['giangVienId'] as String,
      listMaMonHoc: (json['listMaMonHoc'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreatePhanCongRequestToJson(
        CreatePhanCongRequest instance) =>
    <String, dynamic>{
      'giangVienId': instance.giangVienId,
      'listMaMonHoc': instance.listMaMonHoc,
    };

GiangVien _$GiangVienFromJson(Map<String, dynamic> json) => GiangVien(
      id: json['id'] as String,
      hoTen: json['hoten'] as String,
      email: json['email'] as String?,
      mssv: json['mssv'] as String?,
      trangThai: json['trangthai'] as bool?,
    );

Map<String, dynamic> _$GiangVienToJson(GiangVien instance) => <String, dynamic>{
      'id': instance.id,
      'hoten': instance.hoTen,
      'email': instance.email,
      'mssv': instance.mssv,
      'trangthai': instance.trangThai,
    };

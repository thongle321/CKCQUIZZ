import 'package:json_annotation/json_annotation.dart';

part 'phan_cong_model.g.dart';

/// Model cho Phân công giảng viên - môn học
@JsonSerializable()
class PhanCong {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'manguoidung')
  final String maNguoiDung;

  @JsonKey(name: 'hoten')
  final String hoTen;

  @JsonKey(name: 'mamonhoc')
  final int maMonHoc;

  @JsonKey(name: 'tenmonhoc')
  final String tenMonHoc;

  @JsonKey(name: 'sotinchi')
  final int? soTinChi;

  @JsonKey(name: 'sotietlythuyet')
  final int? soTietLyThuyet;

  @JsonKey(name: 'sotietthuchanh')
  final int? soTietThucHanh;

  @JsonKey(name: 'trangthai')
  final bool? trangThai;

  const PhanCong({
    this.id,
    required this.maNguoiDung,
    required this.hoTen,
    required this.maMonHoc,
    required this.tenMonHoc,
    this.soTinChi,
    this.soTietLyThuyet,
    this.soTietThucHanh,
    this.trangThai,
  });

  factory PhanCong.fromJson(Map<String, dynamic> json) => _$PhanCongFromJson(json);
  Map<String, dynamic> toJson() => _$PhanCongToJson(this);

  PhanCong copyWith({
    int? id,
    String? maNguoiDung,
    String? hoTen,
    int? maMonHoc,
    String? tenMonHoc,
    int? soTinChi,
    int? soTietLyThuyet,
    int? soTietThucHanh,
    bool? trangThai,
  }) {
    return PhanCong(
      id: id ?? this.id,
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      hoTen: hoTen ?? this.hoTen,
      maMonHoc: maMonHoc ?? this.maMonHoc,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      soTinChi: soTinChi ?? this.soTinChi,
      soTietLyThuyet: soTietLyThuyet ?? this.soTietLyThuyet,
      soTietThucHanh: soTietThucHanh ?? this.soTietThucHanh,
      trangThai: trangThai ?? this.trangThai,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhanCong &&
        other.id == id &&
        other.maNguoiDung == maNguoiDung &&
        other.maMonHoc == maMonHoc;
  }

  @override
  int get hashCode => Object.hash(id, maNguoiDung, maMonHoc);

  @override
  String toString() {
    return 'PhanCong(id: $id, maNguoiDung: $maNguoiDung, hoTen: $hoTen, maMonHoc: $maMonHoc, tenMonHoc: $tenMonHoc)';
  }
}

/// Model cho request tạo phân công mới
@JsonSerializable()
class CreatePhanCongRequest {
  @JsonKey(name: 'giangVienId')
  final String giangVienId;

  @JsonKey(name: 'listMaMonHoc')
  final List<String> listMaMonHoc;

  const CreatePhanCongRequest({
    required this.giangVienId,
    required this.listMaMonHoc,
  });

  factory CreatePhanCongRequest.fromJson(Map<String, dynamic> json) => 
      _$CreatePhanCongRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePhanCongRequestToJson(this);
}

/// Model cho giảng viên (dùng trong dropdown phân công)
@JsonSerializable()
class GiangVien {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'hoten')
  final String hoTen;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'mssv')
  final String? mssv;

  @JsonKey(name: 'trangthai')
  final bool? trangThai;

  const GiangVien({
    required this.id,
    required this.hoTen,
    this.email,
    this.mssv,
    this.trangThai,
  });

  factory GiangVien.fromJson(Map<String, dynamic> json) => _$GiangVienFromJson(json);
  Map<String, dynamic> toJson() => _$GiangVienToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GiangVien && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GiangVien(id: $id, hoTen: $hoTen, email: $email)';
}

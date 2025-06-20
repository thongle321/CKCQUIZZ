import 'package:json_annotation/json_annotation.dart';

part 'thong_bao_model.g.dart';

/// Model cho Thông báo dựa trên API structure
@JsonSerializable()
class ThongBao {
  @JsonKey(name: 'matb')
  final int? maTb;

  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'mamonhoc')
  final String? maMonHoc;

  @JsonKey(name: 'tenmonhoc')
  final String? tenMonHoc;

  @JsonKey(name: 'namhoc')
  final int? namHoc;

  @JsonKey(name: 'hocky')
  final int? hocKy;

  @JsonKey(name: 'thoigiantao')
  final DateTime? thoiGianTao;

  @JsonKey(name: 'nhom')
  final List<String>? nhom;

  const ThongBao({
    this.maTb,
    required this.noiDung,
    this.maMonHoc,
    this.tenMonHoc,
    this.namHoc,
    this.hocKy,
    this.thoiGianTao,
    this.nhom,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) => _$ThongBaoFromJson(json);
  Map<String, dynamic> toJson() => _$ThongBaoToJson(this);

  ThongBao copyWith({
    int? maTb,
    String? noiDung,
    String? maMonHoc,
    String? tenMonHoc,
    int? namHoc,
    int? hocKy,
    DateTime? thoiGianTao,
    List<String>? nhom,
  }) {
    return ThongBao(
      maTb: maTb ?? this.maTb,
      noiDung: noiDung ?? this.noiDung,
      maMonHoc: maMonHoc ?? this.maMonHoc,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      namHoc: namHoc ?? this.namHoc,
      hocKy: hocKy ?? this.hocKy,
      thoiGianTao: thoiGianTao ?? this.thoiGianTao,
      nhom: nhom ?? this.nhom,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThongBao && other.maTb == maTb;
  }

  @override
  int get hashCode => maTb.hashCode;

  @override
  String toString() {
    return 'ThongBao(maTb: $maTb, noiDung: $noiDung, maMonHoc: $maMonHoc, tenMonHoc: $tenMonHoc)';
  }
}

/// Model cho request tạo thông báo mới
@JsonSerializable()
class CreateThongBaoRequest {
  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'nhomIds')
  final List<int> nhomIds;

  const CreateThongBaoRequest({
    required this.noiDung,
    required this.nhomIds,
  });

  factory CreateThongBaoRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateThongBaoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateThongBaoRequestToJson(this);
}

/// Model cho request cập nhật thông báo
@JsonSerializable()
class UpdateThongBaoRequest {
  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'nhomIds')
  final List<int> nhomIds;

  const UpdateThongBaoRequest({
    required this.noiDung,
    required this.nhomIds,
  });

  factory UpdateThongBaoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateThongBaoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateThongBaoRequestToJson(this);
}

/// Model cho chi tiết thông báo
@JsonSerializable()
class ThongBaoDetail {
  @JsonKey(name: 'matb')
  final int maTb;

  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'mamonhoc')
  final int maMonHoc;

  @JsonKey(name: 'nhom')
  final List<int>? nhom;

  const ThongBaoDetail({
    required this.maTb,
    required this.noiDung,
    required this.maMonHoc,
    this.nhom,
  });

  factory ThongBaoDetail.fromJson(Map<String, dynamic> json) =>
      _$ThongBaoDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ThongBaoDetailToJson(this);
}

/// Model cho học phần với nhóm (dùng trong dropdown)
@JsonSerializable()
class SubjectWithGroups {
  @JsonKey(name: 'mamonhoc')
  final String maMonHoc;

  @JsonKey(name: 'tenmonhoc')
  final String tenMonHoc;

  @JsonKey(name: 'namhoc')
  final String namHoc;

  @JsonKey(name: 'hocky')
  final int hocKy;

  @JsonKey(name: 'nhomLop')
  final List<NhomLop> nhomLop;

  const SubjectWithGroups({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.namHoc,
    required this.hocKy,
    required this.nhomLop,
  });

  factory SubjectWithGroups.fromJson(Map<String, dynamic> json) =>
      _$SubjectWithGroupsFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectWithGroupsToJson(this);
}

/// Model cho nhóm lớp
@JsonSerializable()
class NhomLop {
  @JsonKey(name: 'manhom')
  final String maNhom;

  @JsonKey(name: 'tennhom')
  final String tenNhom;

  const NhomLop({
    required this.maNhom,
    required this.tenNhom,
  });

  factory NhomLop.fromJson(Map<String, dynamic> json) => _$NhomLopFromJson(json);
  Map<String, dynamic> toJson() => _$NhomLopToJson(this);
}

/// Model cho response phân trang thông báo
@JsonSerializable()
class ThongBaoPagedResponse {
  @JsonKey(name: 'items')
  final List<ThongBao> items;

  @JsonKey(name: 'totalCount')
  final int totalCount;

  const ThongBaoPagedResponse({
    required this.items,
    required this.totalCount,
  });

  factory ThongBaoPagedResponse.fromJson(Map<String, dynamic> json) =>
      _$ThongBaoPagedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThongBaoPagedResponseToJson(this);
}
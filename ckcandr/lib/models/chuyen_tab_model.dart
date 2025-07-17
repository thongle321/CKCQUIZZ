import 'package:json_annotation/json_annotation.dart';

part 'chuyen_tab_model.g.dart';

/// Model cho response API tăng số lần chuyển tab
@JsonSerializable()
class ChuyenTabResponse {
  @JsonKey(name: 'soLanHienTai')
  final int soLanHienTai;

  @JsonKey(name: 'nopBai')
  final bool nopBai;

  @JsonKey(name: 'thongBao')
  final String thongBao;

  @JsonKey(name: 'gioiHan')
  final int gioiHan;

  const ChuyenTabResponse({
    required this.soLanHienTai,
    required this.nopBai,
    required this.thongBao,
    required this.gioiHan,
  });

  factory ChuyenTabResponse.fromJson(Map<String, dynamic> json) => _$ChuyenTabResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChuyenTabResponseToJson(this);
}

/// Model cho request API tăng số lần chuyển tab
@JsonSerializable()
class ChuyenTabRequest {
  @JsonKey(name: 'ketQuaId')
  final int ketQuaId;

  const ChuyenTabRequest({
    required this.ketQuaId,
  });

  factory ChuyenTabRequest.fromJson(Map<String, dynamic> json) => _$ChuyenTabRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChuyenTabRequestToJson(this);
}

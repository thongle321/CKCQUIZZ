/// Models for Quiz/Exam Management (Đề Kiểm Tra)
/// 
/// These models correspond to the backend ViewModels and DTOs
/// for managing quizzes/exams in the CKC Quiz application.

import 'package:json_annotation/json_annotation.dart';

part 'de_thi_model.g.dart';

/// Enum for exam types (Loại đề)
enum LoaiDe {
  @JsonValue(1)
  tuDong(1, 'Tự động'),
  @JsonValue(2)
  thuCong(2, 'Thủ công');

  const LoaiDe(this.value, this.displayName);
  final int value;
  final String displayName;
}

/// Enum for exam status
enum TrangThaiDeThi {
  sapDienRa('SapDienRa', 'Sắp diễn ra'),
  dangDienRa('DangDienRa', 'Đang diễn ra'),
  daKetThuc('DaKetThuc', 'Đã kết thúc');

  const TrangThaiDeThi(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Main exam model corresponding to DeThiViewModel
@JsonSerializable()
class DeThiModel {
  final int made;
  final String? tende;
  final String giaoCho;
  final int monthi;
  final DateTime? thoigianbatdau;
  final DateTime? thoigianketthuc;
  final bool trangthai;

  const DeThiModel({
    required this.made,
    this.tende,
    required this.giaoCho,
    required this.monthi,
    this.thoigianbatdau,
    this.thoigianketthuc,
    required this.trangthai,
  });

  factory DeThiModel.fromJson(Map<String, dynamic> json) => _$DeThiModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeThiModelToJson(this);

  /// Get exam status based on current time
  TrangThaiDeThi getTrangThaiDeThi() {
    final now = DateTime.now();
    
    if (thoigianbatdau == null || thoigianketthuc == null) {
      return TrangThaiDeThi.sapDienRa;
    }
    
    if (now.isBefore(thoigianbatdau!)) {
      return TrangThaiDeThi.sapDienRa;
    } else if (now.isAfter(thoigianketthuc!)) {
      return TrangThaiDeThi.daKetThuc;
    } else {
      return TrangThaiDeThi.dangDienRa;
    }
  }

  /// Check if exam can be edited
  bool get canEdit => getTrangThaiDeThi() == TrangThaiDeThi.sapDienRa;

  /// Check if exam can be deleted
  bool get canDelete => getTrangThaiDeThi() == TrangThaiDeThi.sapDienRa;

  DeThiModel copyWith({
    int? made,
    String? tende,
    String? giaoCho,
    int? monthi,
    DateTime? thoigianbatdau,
    DateTime? thoigianketthuc,
    bool? trangthai,
  }) {
    return DeThiModel(
      made: made ?? this.made,
      tende: tende ?? this.tende,
      giaoCho: giaoCho ?? this.giaoCho,
      monthi: monthi ?? this.monthi,
      thoigianbatdau: thoigianbatdau ?? this.thoigianbatdau,
      thoigianketthuc: thoigianketthuc ?? this.thoigianketthuc,
      trangthai: trangthai ?? this.trangthai,
    );
  }
}

/// Detailed exam model corresponding to DeThiDetailViewModel
@JsonSerializable()
class DeThiDetailModel {
  final int made;
  final String? tende;
  final int? monthi;
  final int thoigianthi;
  final DateTime? thoigiantbatdau;
  final DateTime? thoigianketthuc;
  final bool hienthibailam;
  final bool xemdiemthi;
  final bool xemdapan;
  final bool troncauhoi;
  final int loaide;
  final int socaude;
  final int socautb;
  final int socaukho;
  final List<int> malops;
  final List<int> machuongs;

  const DeThiDetailModel({
    required this.made,
    this.tende,
    this.monthi,
    required this.thoigianthi,
    this.thoigiantbatdau,
    this.thoigianketthuc,
    required this.hienthibailam,
    required this.xemdiemthi,
    required this.xemdapan,
    required this.troncauhoi,
    required this.loaide,
    required this.socaude,
    required this.socautb,
    required this.socaukho,
    required this.malops,
    required this.machuongs,
  });

  factory DeThiDetailModel.fromJson(Map<String, dynamic> json) => _$DeThiDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeThiDetailModelToJson(this);

  DeThiDetailModel copyWith({
    int? made,
    String? tende,
    int? monthi,
    int? thoigianthi,
    DateTime? thoigiantbatdau,
    DateTime? thoigianketthuc,
    bool? hienthibailam,
    bool? xemdiemthi,
    bool? xemdapan,
    bool? troncauhoi,
    int? loaide,
    int? socaude,
    int? socautb,
    int? socaukho,
    List<int>? malops,
    List<int>? machuongs,
  }) {
    return DeThiDetailModel(
      made: made ?? this.made,
      tende: tende ?? this.tende,
      monthi: monthi ?? this.monthi,
      thoigianthi: thoigianthi ?? this.thoigianthi,
      thoigiantbatdau: thoigiantbatdau ?? this.thoigiantbatdau,
      thoigianketthuc: thoigianketthuc ?? this.thoigianketthuc,
      hienthibailam: hienthibailam ?? this.hienthibailam,
      xemdiemthi: xemdiemthi ?? this.xemdiemthi,
      xemdapan: xemdapan ?? this.xemdapan,
      troncauhoi: troncauhoi ?? this.troncauhoi,
      loaide: loaide ?? this.loaide,
      socaude: socaude ?? this.socaude,
      socautb: socautb ?? this.socautb,
      socaukho: socaukho ?? this.socaukho,
      malops: malops ?? this.malops,
      machuongs: machuongs ?? this.machuongs,
    );
  }
}

/// Request model for creating exam corresponding to DeThiCreateRequest
@JsonSerializable()
class DeThiCreateRequest {
  final String tende;
  final DateTime thoigianbatdau;
  final DateTime thoigianketthuc;
  final int thoigianthi;
  final int monthi;
  final List<int> malops;
  final bool xemdiemthi;
  final bool hienthibailam;
  final bool xemdapan;
  final bool troncauhoi;
  final int loaide;
  final List<int> machuongs;
  final int socaude;
  final int socautb;
  final int socaukho;

  const DeThiCreateRequest({
    required this.tende,
    required this.thoigianbatdau,
    required this.thoigianketthuc,
    required this.thoigianthi,
    required this.monthi,
    required this.malops,
    required this.xemdiemthi,
    required this.hienthibailam,
    required this.xemdapan,
    required this.troncauhoi,
    required this.loaide,
    required this.machuongs,
    required this.socaude,
    required this.socautb,
    required this.socaukho,
  });

  factory DeThiCreateRequest.fromJson(Map<String, dynamic> json) => _$DeThiCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DeThiCreateRequestToJson(this);
}

/// Request model for updating exam corresponding to DeThiUpdateRequest
@JsonSerializable()
class DeThiUpdateRequest extends DeThiCreateRequest {
  const DeThiUpdateRequest({
    required super.tende,
    required super.thoigianbatdau,
    required super.thoigianketthuc,
    required super.thoigianthi,
    required super.monthi,
    required super.malops,
    required super.xemdiemthi,
    required super.hienthibailam,
    required super.xemdapan,
    required super.troncauhoi,
    required super.loaide,
    required super.machuongs,
    required super.socaude,
    required super.socautb,
    required super.socaukho,
  });

  factory DeThiUpdateRequest.fromJson(Map<String, dynamic> json) => _$DeThiUpdateRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DeThiUpdateRequestToJson(this);
}

/// Model for exam questions in composer
@JsonSerializable()
class CauHoiSoanThaoModel {
  final int macauhoi;
  final String noiDung;
  final String doKho;

  const CauHoiSoanThaoModel({
    required this.macauhoi,
    required this.noiDung,
    required this.doKho,
  });

  factory CauHoiSoanThaoModel.fromJson(Map<String, dynamic> json) => _$CauHoiSoanThaoModelFromJson(json);
  Map<String, dynamic> toJson() => _$CauHoiSoanThaoModelToJson(this);
}

/// Request model for adding questions to exam
@JsonSerializable()
class DapAnSoanThaoRequest {
  final List<int> cauHoiIds;

  const DapAnSoanThaoRequest({
    required this.cauHoiIds,
  });

  factory DapAnSoanThaoRequest.fromJson(Map<String, dynamic> json) => _$DapAnSoanThaoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DapAnSoanThaoRequestToJson(this);
}

/// Model for exam for class (student view)
@JsonSerializable()
class ExamForClassModel {
  final int made;
  final String? tende;
  final String? tenMonHoc;
  final int tongSoCau;
  final int? thoigianthi;
  final DateTime? thoigiantbatdau;
  final DateTime? thoigianketthuc;
  final String trangthaiThi;
  final int? ketQuaId;

  const ExamForClassModel({
    required this.made,
    this.tende,
    this.tenMonHoc,
    required this.tongSoCau,
    this.thoigianthi,
    this.thoigiantbatdau,
    this.thoigianketthuc,
    required this.trangthaiThi,
    this.ketQuaId,
  });

  factory ExamForClassModel.fromJson(Map<String, dynamic> json) => _$ExamForClassModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamForClassModelToJson(this);
}

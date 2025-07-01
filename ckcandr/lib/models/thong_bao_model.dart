import 'package:json_annotation/json_annotation.dart';

part 'thong_bao_model.g.dart';

/// Loại thông báo cho sinh viên
enum NotificationType {
  general,      // thông báo chung
  examNew,      // đề thi mới
  examReminder, // nhắc nhở thi
  examUpdate,   // cập nhật đề thi
  examResult,   // kết quả thi
  classInfo,    // thông báo lớp học
  system,       // thông báo hệ thống
}

/// Model cho Thông báo dựa trên API structure - Enhanced for student notifications
@JsonSerializable()
class ThongBao {
  @JsonKey(name: 'matb')
  final int? maTb;

  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'mamonhoc')
  final int? maMonHoc;

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

  // thêm các trường mới cho tính năng sinh viên
  @JsonKey(name: 'nguoitao')
  final String? nguoiTao;

  @JsonKey(name: 'hoten')
  final String? hoTenNguoiTao;

  @JsonKey(name: 'avatar')
  final String? avatarNguoiTao;

  @JsonKey(name: 'tennhom')
  final String? tenLop;

  @JsonKey(name: 'manhom')
  final int? maLop;

  // thông tin đề thi nếu có
  @JsonKey(name: 'examId')
  final int? examId;

  @JsonKey(name: 'examStartTime')
  final DateTime? examStartTime;

  @JsonKey(name: 'examEndTime')
  final DateTime? examEndTime;

  @JsonKey(name: 'examName')
  final String? examName;

  // trạng thái đã đọc (local state)
  final bool isRead;

  // loại thông báo
  final NotificationType type;

  const ThongBao({
    this.maTb,
    required this.noiDung,
    this.maMonHoc,
    this.tenMonHoc,
    this.namHoc,
    this.hocKy,
    this.thoiGianTao,
    this.nhom,
    this.nguoiTao,
    this.hoTenNguoiTao,
    this.avatarNguoiTao,
    this.tenLop,
    this.maLop,
    this.examId,
    this.examStartTime,
    this.examEndTime,
    this.examName,
    this.isRead = false,
    this.type = NotificationType.general,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) => _$ThongBaoFromJson(json);
  Map<String, dynamic> toJson() => _$ThongBaoToJson(this);

  ThongBao copyWith({
    int? maTb,
    String? noiDung,
    int? maMonHoc,
    String? tenMonHoc,
    int? namHoc,
    int? hocKy,
    DateTime? thoiGianTao,
    List<String>? nhom,
    String? nguoiTao,
    String? hoTenNguoiTao,
    String? avatarNguoiTao,
    String? tenLop,
    int? maLop,
    int? examId,
    DateTime? examStartTime,
    DateTime? examEndTime,
    String? examName,
    bool? isRead,
    NotificationType? type,
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
      nguoiTao: nguoiTao ?? this.nguoiTao,
      hoTenNguoiTao: hoTenNguoiTao ?? this.hoTenNguoiTao,
      avatarNguoiTao: avatarNguoiTao ?? this.avatarNguoiTao,
      tenLop: tenLop ?? this.tenLop,
      maLop: maLop ?? this.maLop,
      examId: examId ?? this.examId,
      examStartTime: examStartTime ?? this.examStartTime,
      examEndTime: examEndTime ?? this.examEndTime,
      examName: examName ?? this.examName,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  /// kiểm tra xem có phải thông báo về đề thi không
  bool get isExamNotification {
    return examId != null ||
           type == NotificationType.examNew ||
           type == NotificationType.examReminder ||
           _containsExamKeywords();
  }

  /// kiểm tra xem có thể vào thi không (đúng thời gian)
  bool get canTakeExam {
    if (!isExamNotification || examStartTime == null || examEndTime == null) {
      return false;
    }
    final now = DateTime.now();
    return now.isAfter(examStartTime!) && now.isBefore(examEndTime!);
  }

  /// kiểm tra nội dung có chứa từ khóa liên quan đến bài thi không
  bool _containsExamKeywords() {
    final content = noiDung.toLowerCase();
    final examKeywords = [
      'bài thi', 'đề thi', 'kiểm tra', 'thi', 'exam', 'test', 'quiz',
      'bài kiểm tra', 'đề kiểm tra', 'thi trắc nghiệm'
    ];

    return examKeywords.any((keyword) => content.contains(keyword));
  }

  /// lấy action text cho thông báo bài thi
  String get examActionText {
    if (!isExamNotification) return '';

    if (canTakeExam) {
      return 'Vào thi ngay';
    } else if (examStartTime != null) {
      final now = DateTime.now();
      if (now.isBefore(examStartTime!)) {
        return 'Xem chi tiết';
      } else {
        return 'Xem kết quả';
      }
    }

    return 'Xem chi tiết';
  }

  /// kiểm tra xem có hiển thị action button không
  bool get shouldShowActionButton {
    return isExamNotification && (examId != null || _containsExamKeywords());
  }

  /// kiểm tra xem đề thi đã kết thúc chưa
  bool get isExamExpired {
    if (!isExamNotification || examEndTime == null) return false;
    return DateTime.now().isAfter(examEndTime!);
  }

  /// lấy thời gian còn lại đến khi thi (nếu chưa đến giờ)
  Duration? get timeUntilExam {
    if (!isExamNotification || examStartTime == null) return null;
    final now = DateTime.now();
    if (now.isBefore(examStartTime!)) {
      return examStartTime!.difference(now);
    }
    return null;
  }

  /// xác định loại thông báo dựa trên nội dung
  static NotificationType _determineType(String noiDung) {
    final content = noiDung.toLowerCase();
    if (content.contains('đề thi mới') || content.contains('đã được tạo')) {
      return NotificationType.examNew;
    } else if (content.contains('sắp có') || content.contains('nhắc nhở')) {
      return NotificationType.examReminder;
    } else if (content.contains('cập nhật') || content.contains('thay đổi')) {
      return NotificationType.examUpdate;
    } else if (content.contains('kết quả') || content.contains('điểm')) {
      return NotificationType.examResult;
    } else if (content.contains('lớp học') || content.contains('lịch học')) {
      return NotificationType.classInfo;
    } else if (content.contains('hệ thống')) {
      return NotificationType.system;
    }
    return NotificationType.general;
  }

  /// tạo từ API response với auto-detect type
  factory ThongBao.fromApiResponse(Map<String, dynamic> json) {
    final thongBao = _$ThongBaoFromJson(json);
    final type = _determineType(thongBao.noiDung);

    // cố gắng extract thông tin đề thi từ nội dung
    int? examId;
    DateTime? examStartTime;
    DateTime? examEndTime;
    String? examName;

    if (type == NotificationType.examNew || type == NotificationType.examReminder) {
      // logic để extract exam info từ nội dung thông báo
      // ví dụ: "Đề thi mới: "Kiểm tra giữa kỳ" đã được tạo. Thời gian thi: 01/01/2025 10:00 - 01/01/2025 12:00"
      final examNameMatch = RegExp(r'"([^"]+)"').firstMatch(thongBao.noiDung);
      if (examNameMatch != null) {
        examName = examNameMatch.group(1);
      }
    }

    return thongBao.copyWith(
      type: type,
      examId: examId,
      examStartTime: examStartTime,
      examEndTime: examEndTime,
      examName: examName,
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
    return 'ThongBao(maTb: $maTb, noiDung: $noiDung, type: $type, isRead: $isRead)';
  }
}

/// Model cho request tạo thông báo mới - Khớp với backend CreateThongBaoRequestDTO
@JsonSerializable()
class CreateThongBaoRequest {
  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'thoigiantao')
  final DateTime? thoigiantao;

  @JsonKey(name: 'nhomIds')
  final List<int> nhomIds;

  const CreateThongBaoRequest({
    required this.noiDung,
    this.thoigiantao,
    required this.nhomIds,
  });

  factory CreateThongBaoRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateThongBaoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateThongBaoRequestToJson(this);
}

/// Model cho request cập nhật thông báo - Khớp với backend UpdateThongBaoRequestDTO
@JsonSerializable()
class UpdateThongBaoRequest {
  @JsonKey(name: 'noidung')
  final String noiDung;

  @JsonKey(name: 'thoigiantao')
  final DateTime? thoigiantao;

  @JsonKey(name: 'nguoitao')
  final String nguoitao;

  @JsonKey(name: 'nhomIds')
  final List<int> nhomIds;

  const UpdateThongBaoRequest({
    required this.noiDung,
    this.thoigiantao,
    required this.nguoitao,
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
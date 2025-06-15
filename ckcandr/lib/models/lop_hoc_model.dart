import 'package:flutter/foundation.dart';

/// Trạng thái lớp học
enum TrangThaiLop {
  hoatDong,
  tamDung,
  ketThuc,
}

/// Model lớp học
class LopHoc {
  final String id;
  final String tenLop;
  final String maLop; // Mã lớp để sinh viên tham gia
  final String moTa;
  final String giangVienId;
  final String giangVienTen;
  final String monHocId;
  final String monHocTen;
  final int namHoc;
  final int hocKy;
  final int siSo;
  final int siSoHienTai;
  final TrangThaiLop trangThai;
  final DateTime ngayTao;
  final DateTime ngayCapNhat;
  final List<String> danhSachSinhVienIds;

  LopHoc({
    required this.id,
    required this.tenLop,
    required this.maLop,
    this.moTa = '',
    required this.giangVienId,
    required this.giangVienTen,
    required this.monHocId,
    required this.monHocTen,
    required this.namHoc,
    required this.hocKy,
    required this.siSo,
    this.siSoHienTai = 0,
    this.trangThai = TrangThaiLop.hoatDong,
    required this.ngayTao,
    required this.ngayCapNhat,
    this.danhSachSinhVienIds = const [],
  });

  LopHoc copyWith({
    String? id,
    String? tenLop,
    String? maLop,
    String? moTa,
    String? giangVienId,
    String? giangVienTen,
    String? monHocId,
    String? monHocTen,
    int? namHoc,
    int? hocKy,
    int? siSo,
    int? siSoHienTai,
    TrangThaiLop? trangThai,
    DateTime? ngayTao,
    DateTime? ngayCapNhat,
    List<String>? danhSachSinhVienIds,
  }) {
    return LopHoc(
      id: id ?? this.id,
      tenLop: tenLop ?? this.tenLop,
      maLop: maLop ?? this.maLop,
      moTa: moTa ?? this.moTa,
      giangVienId: giangVienId ?? this.giangVienId,
      giangVienTen: giangVienTen ?? this.giangVienTen,
      monHocId: monHocId ?? this.monHocId,
      monHocTen: monHocTen ?? this.monHocTen,
      namHoc: namHoc ?? this.namHoc,
      hocKy: hocKy ?? this.hocKy,
      siSo: siSo ?? this.siSo,
      siSoHienTai: siSoHienTai ?? this.siSoHienTai,
      trangThai: trangThai ?? this.trangThai,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      danhSachSinhVienIds: danhSachSinhVienIds ?? this.danhSachSinhVienIds,
    );
  }

  /// Tạo LopHoc từ JSON
  factory LopHoc.fromJson(Map<String, dynamic> json) {
    return LopHoc(
      id: json['id'] as String,
      tenLop: json['tenLop'] as String,
      maLop: json['maLop'] as String,
      moTa: json['moTa'] as String? ?? '',
      giangVienId: json['giangVienId'] as String,
      giangVienTen: json['giangVienTen'] as String,
      monHocId: json['monHocId'] as String,
      monHocTen: json['monHocTen'] as String,
      namHoc: json['namHoc'] as int,
      hocKy: json['hocKy'] as int,
      siSo: json['siSo'] as int,
      siSoHienTai: json['siSoHienTai'] as int? ?? 0,
      trangThai: _getTrangThaiFromString(json['trangThai'] as String),
      ngayTao: DateTime.parse(json['ngayTao'] as String),
      ngayCapNhat: DateTime.parse(json['ngayCapNhat'] as String),
      danhSachSinhVienIds: List<String>.from(json['danhSachSinhVienIds'] as List? ?? []),
    );
  }

  /// Chuyển LopHoc sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenLop': tenLop,
      'maLop': maLop,
      'moTa': moTa,
      'giangVienId': giangVienId,
      'giangVienTen': giangVienTen,
      'monHocId': monHocId,
      'monHocTen': monHocTen,
      'namHoc': namHoc,
      'hocKy': hocKy,
      'siSo': siSo,
      'siSoHienTai': siSoHienTai,
      'trangThai': describeEnum(trangThai),
      'ngayTao': ngayTao.toIso8601String(),
      'ngayCapNhat': ngayCapNhat.toIso8601String(),
      'danhSachSinhVienIds': danhSachSinhVienIds,
    };
  }

  /// Hàm phụ trợ để lấy trạng thái từ chuỗi
  static TrangThaiLop _getTrangThaiFromString(String trangThaiStr) {
    switch (trangThaiStr.toLowerCase()) {
      case 'hoatdong':
        return TrangThaiLop.hoatDong;
      case 'tamdung':
        return TrangThaiLop.tamDung;
      case 'ketthuc':
        return TrangThaiLop.ketThuc;
      default:
        return TrangThaiLop.hoatDong;
    }
  }

  // Hàm helper để hiển thị tên trạng thái
  String get tenTrangThai {
    switch (trangThai) {
      case TrangThaiLop.hoatDong:
        return 'Hoạt động';
      case TrangThaiLop.tamDung:
        return 'Tạm dừng';
      case TrangThaiLop.ketThuc:
        return 'Kết thúc';
    }
  }

  // Kiểm tra xem lớp có thể thêm sinh viên không
  bool get coTheThemSinhVien {
    return trangThai == TrangThaiLop.hoatDong && siSoHienTai < siSo;
  }

  // Tính phần trăm đầy lớp
  double get phanTramDayLop {
    if (siSo == 0) return 0.0;
    return (siSoHienTai / siSo) * 100;
  }
}

/// Model yêu cầu tham gia lớp
class YeuCauThamGiaLop {
  final String id;
  final String sinhVienId;
  final String sinhVienTen;
  final String sinhVienMSSV;
  final String lopHocId;
  final String lopHocTen;
  final String lyDo;
  final DateTime ngayYeuCau;
  final TrangThaiYeuCau trangThai;

  YeuCauThamGiaLop({
    required this.id,
    required this.sinhVienId,
    required this.sinhVienTen,
    required this.sinhVienMSSV,
    required this.lopHocId,
    required this.lopHocTen,
    this.lyDo = '',
    required this.ngayYeuCau,
    this.trangThai = TrangThaiYeuCau.choXuLy,
  });

  YeuCauThamGiaLop copyWith({
    String? id,
    String? sinhVienId,
    String? sinhVienTen,
    String? sinhVienMSSV,
    String? lopHocId,
    String? lopHocTen,
    String? lyDo,
    DateTime? ngayYeuCau,
    TrangThaiYeuCau? trangThai,
  }) {
    return YeuCauThamGiaLop(
      id: id ?? this.id,
      sinhVienId: sinhVienId ?? this.sinhVienId,
      sinhVienTen: sinhVienTen ?? this.sinhVienTen,
      sinhVienMSSV: sinhVienMSSV ?? this.sinhVienMSSV,
      lopHocId: lopHocId ?? this.lopHocId,
      lopHocTen: lopHocTen ?? this.lopHocTen,
      lyDo: lyDo ?? this.lyDo,
      ngayYeuCau: ngayYeuCau ?? this.ngayYeuCau,
      trangThai: trangThai ?? this.trangThai,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinhVienId': sinhVienId,
      'sinhVienTen': sinhVienTen,
      'sinhVienMSSV': sinhVienMSSV,
      'lopHocId': lopHocId,
      'lopHocTen': lopHocTen,
      'lyDo': lyDo,
      'ngayYeuCau': ngayYeuCau.toIso8601String(),
      'trangThai': describeEnum(trangThai),
    };
  }

  factory YeuCauThamGiaLop.fromJson(Map<String, dynamic> json) {
    return YeuCauThamGiaLop(
      id: json['id'] as String,
      sinhVienId: json['sinhVienId'] as String,
      sinhVienTen: json['sinhVienTen'] as String,
      sinhVienMSSV: json['sinhVienMSSV'] as String,
      lopHocId: json['lopHocId'] as String,
      lopHocTen: json['lopHocTen'] as String,
      lyDo: json['lyDo'] as String? ?? '',
      ngayYeuCau: DateTime.parse(json['ngayYeuCau'] as String),
      trangThai: _getTrangThaiYeuCauFromString(json['trangThai'] as String),
    );
  }

  static TrangThaiYeuCau _getTrangThaiYeuCauFromString(String trangThaiStr) {
    switch (trangThaiStr.toLowerCase()) {
      case 'choxuly':
        return TrangThaiYeuCau.choXuLy;
      case 'chapnhan':
        return TrangThaiYeuCau.chapNhan;
      case 'tuchoi':
        return TrangThaiYeuCau.tuChoi;
      default:
        return TrangThaiYeuCau.choXuLy;
    }
  }

  String get tenTrangThai {
    switch (trangThai) {
      case TrangThaiYeuCau.choXuLy:
        return 'Chờ xử lý';
      case TrangThaiYeuCau.chapNhan:
        return 'Chấp nhận';
      case TrangThaiYeuCau.tuChoi:
        return 'Từ chối';
    }
  }
}

/// Trạng thái yêu cầu tham gia lớp
enum TrangThaiYeuCau {
  choXuLy,
  chapNhan,
  tuChoi,
}

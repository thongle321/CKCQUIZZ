class MonHoc {
  final String id;
  final String tenMonHoc;
  final String maMonHoc;
  final int soTinChi;
  final int soGioLT;  // Số giờ lý thuyết
  final int soGioTH;  // Số giờ thực hành
  final bool trangThai; // true = hoạt động, false = không hoạt động
  final String? moTa;
  final bool isDeleted;

  MonHoc({
    required this.id,
    required this.tenMonHoc,
    required this.maMonHoc,
    required this.soTinChi,
    this.soGioLT = 0,
    this.soGioTH = 0,
    this.trangThai = true,
    this.moTa,
    this.isDeleted = false,
  });

  factory MonHoc.fromJson(Map<String, dynamic> json) {
    return MonHoc(
      id: json['id'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      maMonHoc: json['maMonHoc'] as String,
      soTinChi: json['soTinChi'] as int,
      soGioLT: json['soGioLT'] as int? ?? 0,
      soGioTH: json['soGioTH'] as int? ?? 0,
      trangThai: json['trangThai'] as bool? ?? true,
      moTa: json['moTa'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenMonHoc': tenMonHoc,
      'maMonHoc': maMonHoc,
      'soTinChi': soTinChi,
      'soGioLT': soGioLT,
      'soGioTH': soGioTH,
      'trangThai': trangThai,
      'moTa': moTa,
      'isDeleted': isDeleted,
    };
  }

  MonHoc copyWith({
    String? id,
    String? tenMonHoc,
    String? maMonHoc,
    int? soTinChi,
    int? soGioLT,
    int? soGioTH,
    bool? trangThai,
    String? moTa,
    bool? isDeleted,
  }) {
    return MonHoc(
      id: id ?? this.id,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      maMonHoc: maMonHoc ?? this.maMonHoc,
      soTinChi: soTinChi ?? this.soTinChi,
      soGioLT: soGioLT ?? this.soGioLT,
      soGioTH: soGioTH ?? this.soGioTH,
      trangThai: trangThai ?? this.trangThai,
      moTa: moTa ?? this.moTa,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

/// Model cho API môn học mới
class ApiMonHoc {
  final int maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final int soTietLyThuyet;
  final int soTietThucHanh;
  final bool trangThai;

  ApiMonHoc({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    required this.soTietLyThuyet,
    required this.soTietThucHanh,
    required this.trangThai,
  });

  /// Tạo ApiMonHoc từ JSON (API response format)
  factory ApiMonHoc.fromJson(Map<String, dynamic> json) {
    return ApiMonHoc(
      maMonHoc: json['mamonhoc'] as int,
      tenMonHoc: json['tenmonhoc'] as String,
      soTinChi: json['sotinchi'] as int,
      soTietLyThuyet: json['sotietlythuyet'] as int,
      soTietThucHanh: json['sotietthuchanh'] as int,
      trangThai: json['trangthai'] as bool,
    );
  }

  /// Chuyển ApiMonHoc sang JSON
  Map<String, dynamic> toJson() {
    return {
      'mamonhoc': maMonHoc,
      'tenmonhoc': tenMonHoc,
      'sotinchi': soTinChi,
      'sotietlythuyet': soTietLyThuyet,
      'sotietthuchanh': soTietThucHanh,
      'trangthai': trangThai,
    };
  }

  @override
  String toString() {
    return 'ApiMonHoc(maMonHoc: $maMonHoc, tenMonHoc: $tenMonHoc, soTinChi: $soTinChi, soTietLyThuyet: $soTietLyThuyet, soTietThucHanh: $soTietThucHanh, trangThai: $trangThai)';
  }
}

/// DTO cho tạo môn học mới
class CreateMonHocRequestDTO {
  final int maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final int soTietLyThuyet;
  final int soTietThucHanh;
  final bool trangThai;

  CreateMonHocRequestDTO({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    required this.soTietLyThuyet,
    required this.soTietThucHanh,
    this.trangThai = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'Mamonhoc': maMonHoc,           // PascalCase để match backend
      'Tenmonhoc': tenMonHoc,         // PascalCase để match backend
      'Sotinchi': soTinChi,           // PascalCase để match backend
      'Sotietlythuyet': soTietLyThuyet, // PascalCase để match backend
      'Sotietthuchanh': soTietThucHanh, // PascalCase để match backend
      'Trangthai': trangThai,         // PascalCase để match backend
    };
  }
}

/// DTO cho cập nhật môn học
class UpdateMonHocRequestDTO {
  final String tenMonHoc;
  final int soTinChi;
  final int soTietLyThuyet;
  final int soTietThucHanh;
  final bool trangThai;

  UpdateMonHocRequestDTO({
    required this.tenMonHoc,
    required this.soTinChi,
    required this.soTietLyThuyet,
    required this.soTietThucHanh,
    required this.trangThai,
  });

  Map<String, dynamic> toJson() {
    return {
      'Tenmonhoc': tenMonHoc,         // PascalCase để match backend
      'Sotinchi': soTinChi,           // PascalCase để match backend
      'Sotietlythuyet': soTietLyThuyet, // PascalCase để match backend
      'Sotietthuchanh': soTietThucHanh, // PascalCase để match backend
      'Trangthai': trangThai,         // PascalCase để match backend
    };
  }
}
/// Model lớp học khớp với API server
class LopHoc {
  final int malop;
  final String tenlop;
  final String? mamoi; // Mã mời để sinh viên tham gia
  final int? siso;
  final String? ghichu;
  final int? namhoc;
  final int? hocky;
  final bool? trangthai;
  final bool? hienthi;
  final List<String> monhocs; // Danh sách môn học
  final String? magiangvien; // Mã giảng viên được assign
  final String? tengiangvien; // Tên giảng viên để hiển thị

  LopHoc({
    required this.malop,
    required this.tenlop,
    this.mamoi,
    this.siso,
    this.ghichu,
    this.namhoc,
    this.hocky,
    this.trangthai,
    this.hienthi,
    this.monhocs = const [],
    this.magiangvien,
    this.tengiangvien,
  });

  LopHoc copyWith({
    int? malop,
    String? tenlop,
    String? mamoi,
    int? siso,
    String? ghichu,
    int? namhoc,
    int? hocky,
    bool? trangthai,
    bool? hienthi,
    List<String>? monhocs,
    String? magiangvien,
    String? tengiangvien,
  }) {
    return LopHoc(
      malop: malop ?? this.malop,
      tenlop: tenlop ?? this.tenlop,
      mamoi: mamoi ?? this.mamoi,
      siso: siso ?? this.siso,
      ghichu: ghichu ?? this.ghichu,
      namhoc: namhoc ?? this.namhoc,
      hocky: hocky ?? this.hocky,
      trangthai: trangthai ?? this.trangthai,
      hienthi: hienthi ?? this.hienthi,
      monhocs: monhocs ?? this.monhocs,
      magiangvien: magiangvien ?? this.magiangvien,
      tengiangvien: tengiangvien ?? this.tengiangvien,
    );
  }

  /// Tạo LopHoc từ JSON (API response)
  factory LopHoc.fromJson(Map<String, dynamic> json) {
    return LopHoc(
      malop: json['malop'] as int,
      tenlop: json['tenlop'] as String,
      mamoi: json['mamoi'] as String?,
      siso: json['siso'] as int?,
      ghichu: json['ghichu'] as String?,
      namhoc: json['namhoc'] as int?,
      hocky: json['hocky'] as int?,
      trangthai: json['trangthai'] as bool?,
      hienthi: json['hienthi'] as bool?,
      monhocs: List<String>.from(json['monHocs'] as List? ?? []),
      magiangvien: json['giangvien'] as String?, // Map từ 'giangvien' field trong API
      tengiangvien: json['tengiangvien'] as String?, // Tên giảng viên nếu có
    );
  }

  /// Chuyển LopHoc sang JSON
  Map<String, dynamic> toJson() {
    return {
      'malop': malop,
      'tenlop': tenlop,
      'mamoi': mamoi,
      'siso': siso,
      'ghichu': ghichu,
      'namhoc': namhoc,
      'hocky': hocky,
      'trangthai': trangthai,
      'hienthi': hienthi,
      'monHocs': monhocs,
      'giangvien': magiangvien, // Map to API field name
      'tengiangvien': tengiangvien,
    };
  }

  // Hàm helper để hiển thị tên trạng thái
  String get tenTrangThai {
    if (trangthai == true) {
      return 'Hoạt động';
    } else {
      return 'Tạm dừng';
    }
  }

  // Hàm helper để hiển thị trạng thái hiển thị
  String get tenHienThi {
    if (hienthi == true) {
      return 'Hiển thị';
    } else {
      return 'Ẩn';
    }
  }

  // Kiểm tra xem lớp có thể thêm sinh viên không
  bool get coTheThemSinhVien {
    return trangthai == true && (siso == null || siso! > 0);
  }
}

/// DTO cho tạo lớp học mới
class CreateLopRequestDTO {
  final String tenlop;
  final String? ghichu;
  final int? namhoc;
  final int? hocky;
  final bool? trangthai;
  final bool? hienthi;
  final int mamonhoc;
  final String? magiangvien; // Mã giảng viên được assign

  CreateLopRequestDTO({
    required this.tenlop,
    this.ghichu,
    this.namhoc,
    this.hocky,
    this.trangthai,
    this.hienthi,
    required this.mamonhoc,
    this.magiangvien,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenlop': tenlop,
      'ghichu': ghichu,
      'namhoc': namhoc,
      'hocky': hocky,
      'trangthai': trangthai,
      'hienthi': hienthi,
      'mamonhoc': mamonhoc,
      'giangvienId': magiangvien, // Map to API parameter name
    };
  }
}

/// DTO cho cập nhật lớp học
class UpdateLopRequestDTO {
  final String tenlop;
  final String? ghichu;
  final int? namhoc;
  final int? hocky;
  final bool? trangthai;
  final bool? hienthi;
  final int mamonhoc;
  final String? magiangvien; // Mã giảng viên được assign (chỉ Admin có thể thay đổi)

  UpdateLopRequestDTO({
    required this.tenlop,
    this.ghichu,
    this.namhoc,
    this.hocky,
    this.trangthai,
    this.hienthi,
    required this.mamonhoc,
    this.magiangvien,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenlop': tenlop,
      'ghichu': ghichu,
      'namhoc': namhoc,
      'hocky': hocky,
      'trangthai': trangthai,
      'hienthi': hienthi,
      'mamonhoc': mamonhoc,
      'giangvienId': magiangvien, // Map to API parameter name
    };
  }
}

/// DTO cho thêm sinh viên vào lớp
class AddSinhVienRequestDTO {
  final String manguoidungId;

  AddSinhVienRequestDTO({
    required this.manguoidungId,
  });

  Map<String, dynamic> toJson() {
    return {
      'manguoidungId': manguoidungId,
    };
  }
}

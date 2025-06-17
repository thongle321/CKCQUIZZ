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

  CreateLopRequestDTO({
    required this.tenlop,
    this.ghichu,
    this.namhoc,
    this.hocky,
    this.trangthai,
    this.hienthi,
    required this.mamonhoc,
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

  UpdateLopRequestDTO({
    required this.tenlop,
    this.ghichu,
    this.namhoc,
    this.hocky,
    this.trangthai,
    this.hienthi,
    required this.mamonhoc,
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

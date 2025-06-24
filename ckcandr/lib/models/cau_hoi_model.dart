enum LoaiCauHoi {
  tracNghiemChonMot, // single_choice
  tracNghiemChonNhieu, // multiple_choice
  dungSai, // True/False
  dienKhuyet, // Fill in the blank
  tuLuan, // essay
  hinhAnh, // image
}

enum DoKho {
  de, // 1
  trungBinh, // 2
  kho, // 3
}

class LuaChonDapAn {
  final String id; // Có thể là A, B, C, D hoặc một UUID
  final String noiDung;
  bool? laDapAnDung; // Dùng cho tracNghiemChonMot, dungSai
  final int? macautl; // ID từ backend

  LuaChonDapAn({
    required this.id,
    required this.noiDung,
    this.laDapAnDung,
    this.macautl,
  });

  LuaChonDapAn copyWith({
    String? id,
    String? noiDung,
    bool? laDapAnDung,
    int? macautl,
  }) {
    return LuaChonDapAn(
      id: id ?? this.id,
      noiDung: noiDung ?? this.noiDung,
      laDapAnDung: laDapAnDung ?? this.laDapAnDung,
      macautl: macautl ?? this.macautl,
    );
  }

  // Convert to backend DTO
  Map<String, dynamic> toCreateDto() {
    return {
      'noidungtl': noiDung,
      'dapan': laDapAnDung ?? false,
    };
  }

  Map<String, dynamic> toUpdateDto() {
    return {
      'macautl': macautl ?? 0,
      'noidungtl': noiDung,
      'dapan': laDapAnDung ?? false,
    };
  }

  // Create from backend response
  factory LuaChonDapAn.fromJson(Map<String, dynamic> json) {
    return LuaChonDapAn(
      id: json['macautl']?.toString() ?? '',
      noiDung: json['noidungtl'] ?? '',
      laDapAnDung: json['dapan'] ?? false,
      macautl: json['macautl'],
    );
  }
}

class CauHoi {
  final int? macauhoi; // ID từ backend
  final String id; // Local ID for UI
  final int monHocId; // Changed to int to match backend
  final int? chuongMucId; // Changed to int to match backend
  final String noiDung;
  final LoaiCauHoi loaiCauHoi;
  final DoKho doKho;
  final List<LuaChonDapAn> cacLuaChon; // Danh sách các lựa chọn (A,B,C,D...)
  final List<String> dapAnDungIds; // Danh sách ID của các lựa chọn đúng
  final String? giaiThich; // Giải thích đáp án (optional)
  final String? hinhanhUrl; // URL hình ảnh
  final bool trangthai; // Trạng thái hiển thị
  final DateTime ngayTao;
  final DateTime ngayCapNhat;

  CauHoi({
    this.macauhoi,
    required this.id,
    required this.monHocId,
    this.chuongMucId,
    required this.noiDung,
    required this.loaiCauHoi,
    required this.doKho,
    this.cacLuaChon = const [],
    this.dapAnDungIds = const [],
    this.giaiThich,
    this.hinhanhUrl,
    this.trangthai = true,
    required this.ngayTao,
    required this.ngayCapNhat,
  });

  // Helper để lấy tên loại câu hỏi
  String get tenLoaiCauHoi {
    switch (loaiCauHoi) {
      case LoaiCauHoi.tracNghiemChonMot:
        return 'Trắc nghiệm - Chọn một';
      case LoaiCauHoi.tracNghiemChonNhieu:
        return 'Trắc nghiệm - Chọn nhiều';
      case LoaiCauHoi.dungSai:
        return 'Đúng/Sai';
      case LoaiCauHoi.dienKhuyet:
        return 'Điền khuyết';
      case LoaiCauHoi.tuLuan:
        return 'Tự luận';
      case LoaiCauHoi.hinhAnh:
        return 'Hình ảnh';
    }
  }

  // Helper để lấy tên độ khó
  String get tenDoKho {
    switch (doKho) {
      case DoKho.de:
        return 'Dễ';
      case DoKho.trungBinh:
        return 'Trung bình';
      case DoKho.kho:
        return 'Khó';
    }
  }

  // Convert LoaiCauHoi to backend string
  String get loaiCauHoiBackend {
    switch (loaiCauHoi) {
      case LoaiCauHoi.tracNghiemChonMot:
        return 'single_choice';
      case LoaiCauHoi.tracNghiemChonNhieu:
        return 'multiple_choice';
      case LoaiCauHoi.tuLuan:
        return 'essay';
      case LoaiCauHoi.hinhAnh:
        return 'image';
      case LoaiCauHoi.dungSai:
        return 'single_choice'; // Treat as single choice
      case LoaiCauHoi.dienKhuyet:
        return 'essay'; // Treat as essay
    }
  }

  // Convert DoKho to backend int
  int get doKhoBackend {
    switch (doKho) {
      case DoKho.de:
        return 1;
      case DoKho.trungBinh:
        return 2;
      case DoKho.kho:
        return 3;
    }
  }

  // Convert to backend create DTO
  Map<String, dynamic> toCreateDto() {
    return {
      'noidung': noiDung,
      'dokho': doKhoBackend,
      'mamonhoc': monHocId,
      'machuong': chuongMucId,
      'loaicauhoi': loaiCauHoiBackend,
      'hinhanhurl': hinhanhUrl,
      'cauTraLois': cacLuaChon.map((e) => e.toCreateDto()).toList(),
    };
  }

  // Convert to backend update DTO
  Map<String, dynamic> toUpdateDto() {
    return {
      'noidung': noiDung,
      'dokho': doKhoBackend,
      'maMonHoc': monHocId,
      'machuong': chuongMucId,
      'trangthai': trangthai,
      'loaicauhoi': loaiCauHoiBackend,
      'hinhanhurl': hinhanhUrl,
      'cauTraLois': cacLuaChon.map((e) => e.toUpdateDto()).toList(),
    };
  }

  // Create from backend response
  factory CauHoi.fromJson(Map<String, dynamic> json) {
    // Parse loai cau hoi
    LoaiCauHoi loai = LoaiCauHoi.tracNghiemChonMot;
    switch (json['loaicauhoi']) {
      case 'single_choice':
        loai = LoaiCauHoi.tracNghiemChonMot;
        break;
      case 'multiple_choice':
        loai = LoaiCauHoi.tracNghiemChonNhieu;
        break;
      case 'essay':
        loai = LoaiCauHoi.tuLuan;
        break;
      case 'image':
        loai = LoaiCauHoi.hinhAnh;
        break;
    }

    // Parse do kho
    DoKho dokho = DoKho.de;
    switch (json['dokho'] ?? 1) {
      case 1:
        dokho = DoKho.de;
        break;
      case 2:
        dokho = DoKho.trungBinh;
        break;
      case 3:
        dokho = DoKho.kho;
        break;
    }

    // Parse cau tra loi
    List<LuaChonDapAn> cauTraLois = [];
    if (json['cauTraLois'] != null) {
      cauTraLois = (json['cauTraLois'] as List)
          .map((e) => LuaChonDapAn.fromJson(e))
          .toList();
    }

    // Parse dap an dung
    List<String> dapAnDungIds = [];
    for (int i = 0; i < cauTraLois.length; i++) {
      if (cauTraLois[i].laDapAnDung == true) {
        dapAnDungIds.add(cauTraLois[i].id);
      }
    }

    return CauHoi(
      macauhoi: json['macauhoi'],
      id: json['macauhoi']?.toString() ?? '',
      monHocId: json['mamonhoc'] ?? 0,
      chuongMucId: json['machuong'],
      noiDung: json['noidung'] ?? '',
      loaiCauHoi: loai,
      doKho: dokho,
      cacLuaChon: cauTraLois,
      dapAnDungIds: dapAnDungIds,
      hinhanhUrl: json['hinhanhurl'],
      trangthai: json['trangthai'] ?? true,
      ngayTao: DateTime.now(), // Backend doesn't provide this
      ngayCapNhat: DateTime.now(), // Backend doesn't provide this
    );
  }

  // Create from detailed backend response
  factory CauHoi.fromDetailJson(Map<String, dynamic> json) {
    // Parse loai cau hoi
    LoaiCauHoi loai = LoaiCauHoi.tracNghiemChonMot;
    switch (json['loaicauhoi']) {
      case 'single_choice':
        loai = LoaiCauHoi.tracNghiemChonMot;
        break;
      case 'multiple_choice':
        loai = LoaiCauHoi.tracNghiemChonNhieu;
        break;
      case 'essay':
        loai = LoaiCauHoi.tuLuan;
        break;
      case 'image':
        loai = LoaiCauHoi.hinhAnh;
        break;
    }

    // Parse do kho
    DoKho dokho = DoKho.de;
    switch (json['dokho'] ?? 1) {
      case 1:
        dokho = DoKho.de;
        break;
      case 2:
        dokho = DoKho.trungBinh;
        break;
      case 3:
        dokho = DoKho.kho;
        break;
    }

    // Parse cau tra loi
    List<LuaChonDapAn> cauTraLois = [];
    if (json['cauTraLois'] != null) {
      cauTraLois = (json['cauTraLois'] as List)
          .map((e) => LuaChonDapAn.fromJson(e))
          .toList();
    }

    // Parse dap an dung
    List<String> dapAnDungIds = [];
    for (int i = 0; i < cauTraLois.length; i++) {
      if (cauTraLois[i].laDapAnDung == true) {
        dapAnDungIds.add(cauTraLois[i].id);
      }
    }

    return CauHoi(
      macauhoi: json['macauhoi'],
      id: json['macauhoi']?.toString() ?? '',
      monHocId: json['mamonhoc'] ?? 0,
      chuongMucId: json['machuong'],
      noiDung: json['noidung'] ?? '',
      loaiCauHoi: loai,
      doKho: dokho,
      cacLuaChon: cauTraLois,
      dapAnDungIds: dapAnDungIds,
      giaiThich: json['giaiThich'],
      hinhanhUrl: json['hinhanhurl'],
      trangthai: json['trangthai'] ?? true,
      ngayTao: DateTime.now(), // Backend doesn't provide this
      ngayCapNhat: DateTime.now(), // Backend doesn't provide this
    );
  }
}
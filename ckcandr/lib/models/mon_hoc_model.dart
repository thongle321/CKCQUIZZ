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
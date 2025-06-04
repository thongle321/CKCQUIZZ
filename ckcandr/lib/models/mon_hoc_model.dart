class MonHoc {
  final String id;
  final String maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final bool isDeleted;

  MonHoc({
    required this.id,
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    this.isDeleted = false,
  });

  factory MonHoc.fromJson(Map<String, dynamic> json) {
    return MonHoc(
      id: json['id'] as String,
      maMonHoc: json['maMonHoc'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      soTinChi: json['soTinChi'] as int,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maMonHoc': maMonHoc,
      'tenMonHoc': tenMonHoc,
      'soTinChi': soTinChi,
      'isDeleted': isDeleted,
    };
  }

  MonHoc copyWith({
    String? id,
    String? maMonHoc,
    String? tenMonHoc,
    int? soTinChi,
    bool? isDeleted,
  }) {
    return MonHoc(
      id: id ?? this.id,
      maMonHoc: maMonHoc ?? this.maMonHoc,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      soTinChi: soTinChi ?? this.soTinChi,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
} 
class MonHoc {
  final String id;
  final String tenMonHoc;
  final String maMonHoc;
  final int soTinChi;
  final bool isDeleted;

  MonHoc({
    required this.id,
    required this.tenMonHoc,
    required this.maMonHoc,
    required this.soTinChi,
    this.isDeleted = false,
  });

  factory MonHoc.fromJson(Map<String, dynamic> json) {
    return MonHoc(
      id: json['id'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      maMonHoc: json['maMonHoc'] as String,
      soTinChi: json['soTinChi'] as int,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenMonHoc': tenMonHoc,
      'maMonHoc': maMonHoc,
      'soTinChi': soTinChi,
      'isDeleted': isDeleted,
    };
  }

  MonHoc copyWith({
    String? id,
    String? tenMonHoc,
    String? maMonHoc,
    int? soTinChi,
    bool? isDeleted,
  }) {
    return MonHoc(
      id: id ?? this.id,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      maMonHoc: maMonHoc ?? this.maMonHoc,
      soTinChi: soTinChi ?? this.soTinChi,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
} 
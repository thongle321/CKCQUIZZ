class ChuongMuc {
  final String id;
  final String monHocId; // ID của môn học mà chương này thuộc về
  final String tenChuongMuc;
  final int thuTu; // Để sắp xếp thứ tự các chương
  // final String? moTa; // Mô tả tùy chọn

  ChuongMuc({
    required this.id,
    required this.monHocId,
    required this.tenChuongMuc,
    this.thuTu = 0,
    // this.moTa,
  });

  ChuongMuc copyWith({
    String? id,
    String? monHocId,
    String? tenChuongMuc,
    int? thuTu,
    // String? moTa,
  }) {
    return ChuongMuc(
      id: id ?? this.id,
      monHocId: monHocId ?? this.monHocId,
      tenChuongMuc: tenChuongMuc ?? this.tenChuongMuc,
      thuTu: thuTu ?? this.thuTu,
      // moTa: moTa ?? this.moTa,
    );
  }
} 
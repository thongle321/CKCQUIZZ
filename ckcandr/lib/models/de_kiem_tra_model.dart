import 'package:flutter/foundation.dart';

enum TrangThaiDeThi {
  moiTao,
  dangDienRa,
  daKetThuc,
  tam
}

class DeKiemTra {
  final String id;
  final String tenDeThi;
  final DateTime thoiGianBatDau;
  final int thoiGianLamBai; // Tính theo phút
  final List<String> danhSachCauHoiIds;
  final List<String> danhSachNhomHPIds;
  final TrangThaiDeThi trangThai;
  final bool choPhepThi;
  final String? monHocId;
  final String? chuongMucId;
  final String nguoiTaoId;
  final DateTime ngayTao;
  final DateTime ngayCapNhat;
  final String? moTa;

  DeKiemTra({
    required this.id,
    required this.tenDeThi,
    required this.thoiGianBatDau,
    required this.thoiGianLamBai,
    required this.danhSachCauHoiIds,
    required this.danhSachNhomHPIds,
    this.trangThai = TrangThaiDeThi.moiTao,
    this.choPhepThi = false,
    this.monHocId,
    this.chuongMucId,
    required this.nguoiTaoId,
    required this.ngayTao,
    required this.ngayCapNhat,
    this.moTa,
  });

  DeKiemTra copyWith({
    String? id,
    String? tenDeThi,
    DateTime? thoiGianBatDau,
    int? thoiGianLamBai,
    List<String>? danhSachCauHoiIds,
    List<String>? danhSachNhomHPIds,
    TrangThaiDeThi? trangThai,
    bool? choPhepThi,
    String? monHocId,
    String? chuongMucId,
    String? nguoiTaoId,
    DateTime? ngayTao,
    DateTime? ngayCapNhat,
    String? moTa,
  }) {
    return DeKiemTra(
      id: id ?? this.id,
      tenDeThi: tenDeThi ?? this.tenDeThi,
      thoiGianBatDau: thoiGianBatDau ?? this.thoiGianBatDau,
      thoiGianLamBai: thoiGianLamBai ?? this.thoiGianLamBai,
      danhSachCauHoiIds: danhSachCauHoiIds ?? this.danhSachCauHoiIds,
      danhSachNhomHPIds: danhSachNhomHPIds ?? this.danhSachNhomHPIds,
      trangThai: trangThai ?? this.trangThai,
      choPhepThi: choPhepThi ?? this.choPhepThi,
      monHocId: monHocId ?? this.monHocId,
      chuongMucId: chuongMucId ?? this.chuongMucId,
      nguoiTaoId: nguoiTaoId ?? this.nguoiTaoId,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      moTa: moTa ?? this.moTa,
    );
  }

  // Hàm để kiểm tra trạng thái đề thi dựa trên thời gian hiện tại
  TrangThaiDeThi tinhTrangThai() {
    final now = DateTime.now();
    
    if (!choPhepThi) return TrangThaiDeThi.tam;
    
    if (now.isBefore(thoiGianBatDau)) {
      return TrangThaiDeThi.moiTao;
    }
    
    final thoiGianKetThuc = thoiGianBatDau.add(Duration(minutes: thoiGianLamBai));
    if (now.isAfter(thoiGianKetThuc)) {
      return TrangThaiDeThi.daKetThuc;
    }
    
    return TrangThaiDeThi.dangDienRa;
  }

  // Hàm hỗ trợ để hiển thị trạng thái
  static String getTenTrangThai(TrangThaiDeThi trangThai) {
    switch (trangThai) {
      case TrangThaiDeThi.moiTao:
        return 'Sắp diễn ra';
      case TrangThaiDeThi.dangDienRa:
        return 'Đang diễn ra';
      case TrangThaiDeThi.daKetThuc:
        return 'Đã kết thúc';
      case TrangThaiDeThi.tam:
        return 'Tạm';
    }
  }
} 
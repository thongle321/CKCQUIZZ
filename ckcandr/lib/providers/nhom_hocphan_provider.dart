import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart'; // Cần cho tenMonHoc trong NhomHocPhan

// Định nghĩa lớp NhomHocPhan
class NhomHocPhan {
  final String id;
  final String monHocId;
  final String tenMonHoc; // Lưu tên môn học để hiển thị dễ dàng
  final String tenNhomHocPhan;
  final String hocKy;
  final String namHoc;
  final DateTime ngayTao;
  int soLuongSV;

  NhomHocPhan({
    required this.id,
    required this.monHocId,
    required this.tenMonHoc,
    required this.tenNhomHocPhan,
    required this.hocKy,
    required this.namHoc,
    required this.ngayTao,
    this.soLuongSV = 0,
  });

  NhomHocPhan copyWith({
    String? id,
    String? monHocId,
    String? tenMonHoc,
    String? tenNhomHocPhan,
    String? hocKy,
    String? namHoc,
    DateTime? ngayTao,
    int? soLuongSV,
  }) {
    return NhomHocPhan(
      id: id ?? this.id,
      monHocId: monHocId ?? this.monHocId,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      tenNhomHocPhan: tenNhomHocPhan ?? this.tenNhomHocPhan,
      hocKy: hocKy ?? this.hocKy,
      namHoc: namHoc ?? this.namHoc,
      ngayTao: ngayTao ?? this.ngayTao,
      soLuongSV: soLuongSV ?? this.soLuongSV,
    );
  }
}

// Provider cho danh sách nhóm học phần
final nhomHocPhanListProvider = StateProvider<List<NhomHocPhan>>((ref) => []); 
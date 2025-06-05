import 'package:flutter/foundation.dart';

class ThongBao {
  final String id;
  final String tieuDe;
  final String noiDung;
  final DateTime ngayTao;
  final DateTime ngayCapNhat;
  final String nguoiTaoId; // ID của giảng viên
  final String phamViMoTa; // Mô tả phạm vi/đối tượng, ví dụ: "Nhóm NMLT - HK1", "Toàn khoa"
  final bool isPublished;
  final List<String>? nhomHocPhanIds; // Optional: Liên kết với nhóm học phần cụ thể
  final List<String>? monHocIds;      // Optional: Liên kết với môn học cụ thể

  ThongBao({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.ngayTao,
    required this.ngayCapNhat,
    required this.nguoiTaoId,
    required this.phamViMoTa,
    this.isPublished = true, // Mặc định là đã đăng
    this.nhomHocPhanIds,
    this.monHocIds,
  });

  ThongBao copyWith({
    String? id,
    String? tieuDe,
    String? noiDung,
    DateTime? ngayTao,
    DateTime? ngayCapNhat,
    String? nguoiTaoId,
    String? phamViMoTa,
    bool? isPublished,
    List<String>? nhomHocPhanIds,
    List<String>? monHocIds,
  }) {
    return ThongBao(
      id: id ?? this.id,
      tieuDe: tieuDe ?? this.tieuDe,
      noiDung: noiDung ?? this.noiDung,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      nguoiTaoId: nguoiTaoId ?? this.nguoiTaoId,
      phamViMoTa: phamViMoTa ?? this.phamViMoTa,
      isPublished: isPublished ?? this.isPublished,
      nhomHocPhanIds: nhomHocPhanIds ?? this.nhomHocPhanIds,
      monHocIds: monHocIds ?? this.monHocIds,
    );
  }
} 
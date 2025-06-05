import 'package:flutter/foundation.dart';

enum LoaiCauHoi {
  tracNghiemChonMot, // Multiple choice, single answer
  tracNghiemChonNhieu, // Multiple choice, multiple answers
  dungSai, // True/False
  dienKhuyet, // Fill in the blank (simple version)
  // traLoiNgan, // Short answer - More complex to auto-grade
}

enum DoKho {
  de,
  trungBinh,
  kho,
}

class LuaChonDapAn {
  final String id; // Có thể là A, B, C, D hoặc một UUID
  final String noiDung;
  bool? laDapAnDung; // Dùng cho tracNghiemChonMot, dungSai

  LuaChonDapAn({
    required this.id,
    required this.noiDung,
    this.laDapAnDung, 
  });

  LuaChonDapAn copyWith({
    String? id,
    String? noiDung,
    bool? laDapAnDung,
  }) {
    return LuaChonDapAn(
      id: id ?? this.id,
      noiDung: noiDung ?? this.noiDung,
      laDapAnDung: laDapAnDung ?? this.laDapAnDung,
    );
  }
}

class CauHoi {
  final String id;
  final String monHocId;
  final String? chuongMucId; // Có thể null nếu không phân chương
  final String noiDung;
  final LoaiCauHoi loaiCauHoi;
  final DoKho doKho;
  final List<LuaChonDapAn> cacLuaChon; // Danh sách các lựa chọn (A,B,C,D...)
  final List<String> dapAnDungIds; // Danh sách ID của các lựa chọn đúng (cho trắc nghiệm chọn nhiều)
                                  // Đối với chọn một hoặc đúng/sai, list này sẽ có 1 phần tử
  final String? giaiThich; // Giải thích đáp án (optional)
  final DateTime ngayTao;
  final DateTime ngayCapNhat;

  CauHoi({
    required this.id,
    required this.monHocId,
    this.chuongMucId,
    required this.noiDung,
    required this.loaiCauHoi,
    required this.doKho,
    this.cacLuaChon = const [],
    this.dapAnDungIds = const [],
    this.giaiThich,
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
      default:
        return 'Không xác định';
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
      default:
        return 'Không xác định';
    }
  }
} 
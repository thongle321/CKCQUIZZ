import 'package:flutter/foundation.dart';

class NhomHocPhan {
  final String id;
  final String tenNhom;
  final String monHocId;
  final String namHoc;
  final String hocKy;
  final String giangVienId;
  final int soSV; // Số sinh viên đã đăng ký
  final DateTime ngayTao;
  final bool isDeleted;

  NhomHocPhan({
    required this.id,
    required this.tenNhom,
    required this.monHocId,
    required this.namHoc,
    required this.hocKy,
    required this.giangVienId,
    this.soSV = 0,
    required this.ngayTao,
    this.isDeleted = false,
  });

  factory NhomHocPhan.fromJson(Map<String, dynamic> json) {
    return NhomHocPhan(
      id: json['id'] as String,
      tenNhom: json['tenNhom'] as String,
      monHocId: json['monHocId'] as String,
      namHoc: json['namHoc'] as String,
      hocKy: json['hocKy'] as String,
      giangVienId: json['giangVienId'] as String,
      soSV: json['soSV'] as int? ?? 0,
      ngayTao: json['ngayTao'] != null 
          ? DateTime.parse(json['ngayTao'] as String)
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenNhom': tenNhom,
      'monHocId': monHocId,
      'namHoc': namHoc,
      'hocKy': hocKy,
      'giangVienId': giangVienId,
      'soSV': soSV,
      'ngayTao': ngayTao.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  NhomHocPhan copyWith({
    String? id,
    String? tenNhom,
    String? monHocId,
    String? namHoc,
    String? hocKy,
    String? giangVienId,
    int? soSV,
    DateTime? ngayTao,
    bool? isDeleted,
  }) {
    return NhomHocPhan(
      id: id ?? this.id,
      tenNhom: tenNhom ?? this.tenNhom,
      monHocId: monHocId ?? this.monHocId,
      namHoc: namHoc ?? this.namHoc,
      hocKy: hocKy ?? this.hocKy,
      giangVienId: giangVienId ?? this.giangVienId,
      soSV: soSV ?? this.soSV,
      ngayTao: ngayTao ?? this.ngayTao,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
} 
import 'package:flutter/material.dart';

enum LoaiHoatDong {
  DANG_NHAP,
  CAU_HOI,
  DE_THI,
  MON_HOC,
  THEM_THONG_BAO,
  SUA_THONG_BAO,
  XOA_THONG_BAO,
  KHAC,
}

class HoatDongGanDay {
  final String id;
  final String noiDung;
  final LoaiHoatDong loaiHoatDong;
  final DateTime thoiGian;
  final String? nguoiThucHienId;
  final String? idDoiTuongLienQuan;
  final IconData? icon;

  HoatDongGanDay({
    required this.id,
    required this.noiDung,
    required this.loaiHoatDong,
    required this.thoiGian,
    this.nguoiThucHienId,
    this.idDoiTuongLienQuan,
    this.icon,
  });

  HoatDongGanDay copyWith({
    String? id,
    String? noiDung,
    LoaiHoatDong? loaiHoatDong,
    DateTime? thoiGian,
    String? nguoiThucHienId,
    String? idDoiTuongLienQuan,
    IconData? icon,
  }) {
    return HoatDongGanDay(
      id: id ?? this.id,
      noiDung: noiDung ?? this.noiDung,
      loaiHoatDong: loaiHoatDong ?? this.loaiHoatDong,
      thoiGian: thoiGian ?? this.thoiGian,
      nguoiThucHienId: nguoiThucHienId ?? this.nguoiThucHienId,
      idDoiTuongLienQuan: idDoiTuongLienQuan ?? this.idDoiTuongLienQuan,
      icon: icon ?? this.icon,
    );
  }
} 
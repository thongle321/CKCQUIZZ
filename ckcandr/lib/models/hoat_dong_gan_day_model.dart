import 'package:flutter/material.dart';

enum LoaiHoatDong {
  THEM_MON_HOC,
  SUA_MON_HOC,
  XOA_MON_HOC,
  THEM_CHUONG_MUC,
  SUA_CHUONG_MUC,
  XOA_CHUONG_MUC,
  THEM_CAU_HOI,
  SUA_CAU_HOI,
  XOA_CAU_HOI,
  THEM_NHOM_HP,
  SUA_NHOM_HP,
  XOA_NHOM_HP,
  THEM_DE_KIEM_TRA, // Future use
  SUA_DE_KIEM_TRA, // Future use
  XOA_DE_KIEM_TRA, // Future use
  THEM_THONG_BAO,
  SUA_THONG_BAO,
  XOA_THONG_BAO,
  KHAC
}

class HoatDongGanDay {
  final String id;
  final String noiDung;
  final DateTime thoiGian;
  final LoaiHoatDong loaiHoatDong;
  final IconData icon;
  final String? idDoiTuongLienQuan; // Optional: ID of the created/modified object
  // final String? routeLienQuan; // Optional: Route to navigate to, if needed

  HoatDongGanDay({
    required this.id,
    required this.noiDung,
    required this.thoiGian,
    required this.loaiHoatDong,
    required this.icon,
    this.idDoiTuongLienQuan,
    // this.routeLienQuan,
  });
} 
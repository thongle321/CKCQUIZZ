import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/nhom_hocphan_model.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:flutter/material.dart';

// Provider cho danh sách nhóm học phần
final nhomHocPhanListProvider = StateProvider<List<NhomHocPhan>>((ref) {
  // Khởi tạo với một số nhóm học phần mẫu
  return [
    NhomHocPhan(
      id: '1',
      tenNhom: 'Nhóm 1 - NMLT',
      monHocId: '3',
      namHoc: '2024',
      hocKy: 'HK1',
      giangVienId: 'GV001',
      soSV: 25,
      ngayTao: DateTime.now().subtract(const Duration(days: 30)),
    ),
    NhomHocPhan(
      id: '2',
      tenNhom: 'Nhóm 2 - NMLT',
      monHocId: '3',
      namHoc: '2024',
      hocKy: 'HK1',
      giangVienId: 'GV001',
      soSV: 28,
      ngayTao: DateTime.now().subtract(const Duration(days: 25)),
    ),
    NhomHocPhan(
      id: '3',
      tenNhom: 'Nhóm 1 - Web',
      monHocId: '1',
      namHoc: '2024',
      hocKy: 'HK1',
      giangVienId: 'GV002',
      soSV: 22,
      ngayTao: DateTime.now().subtract(const Duration(days: 20)),
    ),
    NhomHocPhan(
      id: '4',
      tenNhom: 'Nhóm 1 - Mobile',
      monHocId: '2',
      namHoc: '2024',
      hocKy: 'HK1',
      giangVienId: 'GV002',
      soSV: 20,
      ngayTao: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
});

// Provider để lọc nhóm học phần theo môn học
final filteredNhomHocPhanProvider = Provider.family<List<NhomHocPhan>, String?>((ref, monHocId) {
  final nhomHocPhanList = ref.watch(nhomHocPhanListProvider);

  if (monHocId == null) {
    return nhomHocPhanList;
  }

  return nhomHocPhanList.where((nhom) => nhom.monHocId == monHocId).toList();
});

// Notifier để quản lý thao tác với nhóm học phần
class NhomHocPhanNotifier extends StateNotifier<List<NhomHocPhan>> {
  final Ref ref;

  NhomHocPhanNotifier(this.ref, List<NhomHocPhan> nhomHocPhans) : super(nhomHocPhans);

  // Thêm nhóm học phần mới
  void themNhomHocPhan(NhomHocPhan nhomHocPhan) {
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    state = [...state, nhomHocPhan];

    hoatDongNotifier.addHoatDong(
      'Đã tạo nhóm học phần: ${nhomHocPhan.tenNhom}',
      LoaiHoatDong.KHAC,
      Icons.group_add,
      idDoiTuongLienQuan: nhomHocPhan.id,
    );
  }

  // Cập nhật nhóm học phần
  void capNhatNhomHocPhan(NhomHocPhan nhomHocPhan) {
    state = state.map((nhom) =>
      nhom.id == nhomHocPhan.id ? nhomHocPhan : nhom
    ).toList();

    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã cập nhật nhóm học phần: ${nhomHocPhan.tenNhom}',
      LoaiHoatDong.KHAC,
      Icons.group_work,
      idDoiTuongLienQuan: nhomHocPhan.id,
    );
  }

  // Xóa nhóm học phần (soft delete)
  void xoaNhomHocPhan(NhomHocPhan nhomHocPhan) {
    final updatedNhom = nhomHocPhan.copyWith(isDeleted: true);
    state = state.map((nhom) =>
      nhom.id == nhomHocPhan.id ? updatedNhom : nhom
    ).toList();

    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã xóa nhóm học phần: ${nhomHocPhan.tenNhom}',
      LoaiHoatDong.KHAC,
      Icons.group_remove,
      idDoiTuongLienQuan: nhomHocPhan.id,
    );
  }

  // Lấy nhóm học phần theo ID
  NhomHocPhan? getNhomHocPhanById(String id) {
    try {
      return state.firstWhere((nhom) => nhom.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider để quản lý nhóm học phần với notifier
final nhomHocPhanNotifierProvider = StateNotifierProvider<NhomHocPhanNotifier, List<NhomHocPhan>>((ref) {
  final nhomHocPhans = ref.watch(nhomHocPhanListProvider);
  return NhomHocPhanNotifier(ref, nhomHocPhans);
});
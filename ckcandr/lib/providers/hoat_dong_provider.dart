import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:flutter/material.dart'; // Required for IconData

const int _maxRecentActivities = 20;

final hoatDongGanDayListProvider = StateNotifierProvider<HoatDongNotifier, List<HoatDongGanDay>>((ref) {
  return HoatDongNotifier([
    HoatDongGanDay(
      id: '1',
      noiDung: 'Đăng nhập vào hệ thống',
      loaiHoatDong: LoaiHoatDong.DANG_NHAP,
      thoiGian: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.login,
    ),
    HoatDongGanDay(
      id: '2',
      noiDung: 'Thêm môn học "Lập trình Web"',
      loaiHoatDong: LoaiHoatDong.MON_HOC,
      thoiGian: DateTime.now().subtract(const Duration(hours: 2)),
      idDoiTuongLienQuan: 'mh1',
      icon: Icons.book,
    ),
    HoatDongGanDay(
      id: '3',
      noiDung: 'Thêm câu hỏi mới cho môn Lập trình Web',
      loaiHoatDong: LoaiHoatDong.CAU_HOI,
      thoiGian: DateTime.now().subtract(const Duration(hours: 3)),
      idDoiTuongLienQuan: 'ch1',
      icon: Icons.question_answer,
    ),
    HoatDongGanDay(
      id: '4',
      noiDung: 'Tạo đề thi kiểm tra giữa kỳ',
      loaiHoatDong: LoaiHoatDong.DE_THI,
      thoiGian: DateTime.now().subtract(const Duration(days: 1)),
      idDoiTuongLienQuan: 'dt1',
      icon: Icons.assignment,
    ),
  ]);
});

class HoatDongNotifier extends StateNotifier<List<HoatDongGanDay>> {
  HoatDongNotifier(List<HoatDongGanDay> hoatDongs) : super(hoatDongs);

  void addHoatDong(
    String noiDung,
    LoaiHoatDong loai,
    IconData icon, {
    String? idDoiTuongLienQuan,
    String? nguoiThucHienId,
  }) {
    final newActivity = HoatDongGanDay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      noiDung: noiDung,
      thoiGian: DateTime.now(),
      loaiHoatDong: loai,
      icon: icon,
      idDoiTuongLienQuan: idDoiTuongLienQuan,
      nguoiThucHienId: nguoiThucHienId,
    );

    state = [newActivity, ...state];
    if (state.length > _maxRecentActivities) {
      state = state.sublist(0, _maxRecentActivities);
    }
  }

  // Helper function to get default icon based on activity type
  static IconData getIconForLoai(LoaiHoatDong loai, {bool isDeletion = false}) {
    if (isDeletion) return Icons.delete_sweep_outlined;
    switch (loai) {
      case LoaiHoatDong.MON_HOC:
        return Icons.book;
      case LoaiHoatDong.CAU_HOI:
        return Icons.question_answer;
      case LoaiHoatDong.DE_THI:
        return Icons.assignment;
      case LoaiHoatDong.DANG_NHAP:
        return Icons.login;
      case LoaiHoatDong.THEM_THONG_BAO:
        return Icons.add_alert;
      case LoaiHoatDong.SUA_THONG_BAO:
        return Icons.edit_notifications;
      case LoaiHoatDong.XOA_THONG_BAO:
        return Icons.notifications_off;
      case LoaiHoatDong.KHAC:
      default:
        return Icons.info_outline;
    }
  }

  // Xóa một hoạt động
  void deleteHoatDong(String id) {
    state = state.where((hoatDong) => hoatDong.id != id).toList();
  }
  
  // Xóa tất cả hoạt động
  void clearAll() {
    state = [];
  }
  
  // Lấy hoạt động trong một khoảng thời gian
  List<HoatDongGanDay> getHoatDongTrongKhoang(DateTime tuNgay, DateTime denNgay) {
    return state.where((hoatDong) {
      return hoatDong.thoiGian.isAfter(tuNgay) && 
             hoatDong.thoiGian.isBefore(denNgay);
    }).toList();
  }
}

// Tiện ích để log hoạt động từ bất kỳ đâu có Ref
void logHoatDong(
  Ref ref,  // Changed from WidgetRef to Ref
  String noiDung,
  LoaiHoatDong loai,
  IconData? icon, // Cho phép null để dùng icon mặc định
  {
  String? idDoiTuongLienQuan,
  String? nguoiThucHienId,
  bool isDeletion = false, // Thêm flag này để getIconForLoai có thể xử lý icon xóa chung
}) {
  final actualIcon = icon ?? HoatDongNotifier.getIconForLoai(loai, isDeletion: isDeletion);
  ref.read(hoatDongGanDayListProvider.notifier).addHoatDong(
        noiDung,
        loai,
        actualIcon,
        idDoiTuongLienQuan: idDoiTuongLienQuan,
        nguoiThucHienId: nguoiThucHienId,
      );
} 
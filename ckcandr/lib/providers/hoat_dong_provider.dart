import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:flutter/material.dart'; // Required for IconData

const int _maxRecentActivities = 20;

final hoatDongGanDayListProvider = StateNotifierProvider<HoatDongNotifier, List<HoatDongGanDay>>((ref) {
  return HoatDongNotifier();
});

class HoatDongNotifier extends StateNotifier<List<HoatDongGanDay>> {
  HoatDongNotifier() : super([]);

  void addHoatDong(
    String noiDung,
    LoaiHoatDong loai,
    IconData icon, {
    String? idDoiTuongLienQuan,
  }) {
    final newActivity = HoatDongGanDay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      noiDung: noiDung,
      thoiGian: DateTime.now(),
      loaiHoatDong: loai,
      icon: icon,
      idDoiTuongLienQuan: idDoiTuongLienQuan,
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
      case LoaiHoatDong.THEM_MON_HOC:
        return Icons.add_box_outlined;
      case LoaiHoatDong.SUA_MON_HOC:
        return Icons.edit_outlined;
      case LoaiHoatDong.XOA_MON_HOC:
        return Icons.delete_outline; // Should be caught by isDeletion
      case LoaiHoatDong.THEM_CHUONG_MUC:
        return Icons.add_link_outlined;
      case LoaiHoatDong.SUA_CHUONG_MUC:
        return Icons.edit_attributes_outlined;
      case LoaiHoatDong.XOA_CHUONG_MUC:
        return Icons.link_off_outlined; // Should be caught by isDeletion
      case LoaiHoatDong.THEM_CAU_HOI:
        return Icons.playlist_add_outlined;
      case LoaiHoatDong.SUA_CAU_HOI:
        return Icons.edit_note_outlined;
      case LoaiHoatDong.XOA_CAU_HOI:
        return Icons.playlist_remove_outlined; // Should be caught by isDeletion
      case LoaiHoatDong.THEM_NHOM_HP:
        return Icons.group_add_outlined;
      case LoaiHoatDong.SUA_NHOM_HP:
        return Icons.manage_accounts_outlined;
      case LoaiHoatDong.XOA_NHOM_HP:
        return Icons.folder_delete_outlined; // Should be caught by isDeletion
      case LoaiHoatDong.THEM_THONG_BAO: // Added
        return Icons.add_alert_outlined;
      case LoaiHoatDong.SUA_THONG_BAO:  // Added
        return Icons.edit_notifications_outlined;
      case LoaiHoatDong.XOA_THONG_BAO:   // Added
        return Icons.notification_important_outlined; // Should be caught by isDeletion if using consistent deletion icon
      // TODO: Add icons for DE_KIEM_TRA
      default:
        return Icons.info_outline;
    }
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
  bool isDeletion = false, // Thêm flag này để getIconForLoai có thể xử lý icon xóa chung
}) {
  final actualIcon = icon ?? HoatDongNotifier.getIconForLoai(loai, isDeletion: isDeletion);
  ref.read(hoatDongGanDayListProvider.notifier).addHoatDong(
        noiDung,
        loai,
        actualIcon,
        idDoiTuongLienQuan: idDoiTuongLienQuan,
      );
} 
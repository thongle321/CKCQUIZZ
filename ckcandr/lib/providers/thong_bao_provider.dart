import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart'; // Import model HoatDong
import 'package:ckcandr/providers/hoat_dong_provider.dart'; // Import provider HoatDong và hàm logHoatDong
import 'package:flutter/material.dart'; // For Icons

// Provider cho danh sách thông báo
final thongBaoListProvider = StateNotifierProvider<ThongBaoNotifier, List<ThongBao>>((ref) {
  return ThongBaoNotifier(ref);
});

class ThongBaoNotifier extends StateNotifier<List<ThongBao>> {
  final Ref _ref;
  ThongBaoNotifier(this._ref) : super([]);

  // Thêm thông báo mới
  void addThongBao({
    required String tieuDe,
    required String noiDung,
    required String nguoiTaoId, // Sẽ lấy từ auth state sau này
    required String phamViMoTa,
    bool isPublished = true,
    List<String>? nhomHocPhanIds,
    List<String>? monHocIds,
  }) {
    final newThongBao = ThongBao(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tieuDe: tieuDe,
      noiDung: noiDung,
      ngayTao: DateTime.now(),
      ngayCapNhat: DateTime.now(),
      nguoiTaoId: nguoiTaoId,
      phamViMoTa: phamViMoTa,
      isPublished: isPublished,
      nhomHocPhanIds: nhomHocPhanIds,
      monHocIds: monHocIds,
    );
    state = [newThongBao, ...state];
    logHoatDong(
      _ref, 
      'Đã tạo thông báo: ${newThongBao.tieuDe.length > 50 ? '${newThongBao.tieuDe.substring(0,47)}...' : newThongBao.tieuDe}',
      LoaiHoatDong.THEM_THONG_BAO, 
      null, // Sẽ dùng icon mặc định từ getIconForLoai
      idDoiTuongLienQuan: newThongBao.id
    );
  }

  // Sửa thông báo
  void editThongBao(ThongBao updatedThongBao) {
    state = [
      for (final thongBao in state)
        if (thongBao.id == updatedThongBao.id)
          updatedThongBao.copyWith(ngayCapNhat: DateTime.now())
        else
          thongBao,
    ];
    logHoatDong(
      _ref, 
      'Đã sửa thông báo: ${updatedThongBao.tieuDe.length > 50 ? '${updatedThongBao.tieuDe.substring(0,47)}...' : updatedThongBao.tieuDe}',
      LoaiHoatDong.SUA_THONG_BAO, 
      null, // Sẽ dùng icon mặc định
      idDoiTuongLienQuan: updatedThongBao.id
    );
  }

  // Xóa thông báo
  void deleteThongBao(String thongBaoId) {
    ThongBao? thongBaoToDelete;
    try {
        thongBaoToDelete = state.firstWhere((tb) => tb.id == thongBaoId);
    } catch (e) {
        // Không tìm thấy, có thể đã bị xóa bởi một hành động khác
    }
    
    state = state.where((thongBao) => thongBao.id != thongBaoId).toList();

    if (thongBaoToDelete != null) {
      logHoatDong(
        _ref, 
        'Đã xóa thông báo: ${thongBaoToDelete.tieuDe.length > 50 ? '${thongBaoToDelete.tieuDe.substring(0,47)}...' : thongBaoToDelete.tieuDe}',
        LoaiHoatDong.XOA_THONG_BAO, 
        null, // Sẽ dùng icon mặc định
        idDoiTuongLienQuan: thongBaoId,
        isDeletion: true
      );
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/de_kiem_tra_provider.dart';
import 'package:ckcandr/providers/thong_bao_provider.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/providers/sinh_vien_lop_provider.dart';
// import 'package:ckcandr/providers/lop_hoc_provider.dart'; // Temporarily disabled

/// File này chứa tất cả các providers của ứng dụng
/// để đảm bảo chúng được khởi tạo đúng cách

class AppProviders {
  static List<Override> get overrides => [
    // Có thể thêm các override cần thiết ở đây
  ];

  /// Khởi tạo tất cả providers cần thiết
  static void initializeProviders(WidgetRef ref) {
    try {
      // Khởi tạo user providers
      ref.read(userListProvider);
      ref.read(currentUserProvider);
      
      // Khởi tạo môn học providers
      ref.read(monHocListProvider);
      
      // Khởi tạo nhóm học phần providers
      ref.read(nhomHocPhanListProvider);
      
      // Khởi tạo đề kiểm tra providers
      ref.read(deKiemTraListProvider);
      
      // Khởi tạo thông báo providers
      ref.read(thongBaoListProvider);
      
      // Khởi tạo hoạt động providers
      ref.read(hoatDongGanDayListProvider);
      
      // Khởi tạo theme provider
      ref.read(themeProvider);

      // Khởi tạo sinh viên lop providers
      ref.read(sinhVienLopServiceProvider);

      debugPrint('All providers initialized successfully');
    } catch (e) {
      debugPrint('Error initializing providers: $e');
    }
  }
}

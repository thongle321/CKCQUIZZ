import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';

/// Provider cho danh sách môn học
final monHocListProvider = StateNotifierProvider<MonHocNotifier, List<MonHoc>>((ref) {
  return MonHocNotifier();
});

/// Notifier quản lý danh sách môn học
class MonHocNotifier extends StateNotifier<List<MonHoc>> {
  MonHocNotifier() : super(_generateSampleData());

  /// Tạo dữ liệu mẫu
  static List<MonHoc> _generateSampleData() {
    return [
      MonHoc(
        id: '1',
        tenMonHoc: 'Lập trình di động',
        maMonHoc: 'IT4785',
        moTa: 'Môn học về phát triển ứng dụng di động với Flutter và React Native',
        soTinChi: 3,
        soGioLT: 30,
        soGioTH: 30,
        trangThai: true,
      ),
      MonHoc(
        id: '2',
        tenMonHoc: 'Cơ sở dữ liệu',
        maMonHoc: 'IT3090',
        moTa: 'Môn học về thiết kế và quản lý cơ sở dữ liệu',
        soTinChi: 3,
        soGioLT: 45,
        soGioTH: 15,
        trangThai: true,
      ),
      MonHoc(
        id: '3',
        tenMonHoc: 'Lập trình web',
        maMonHoc: 'IT4409',
        moTa: 'Môn học về phát triển ứng dụng web với HTML, CSS, JavaScript',
        soTinChi: 3,
        soGioLT: 30,
        soGioTH: 30,
        trangThai: true,
      ),
      MonHoc(
        id: '4',
        tenMonHoc: 'Trí tuệ nhân tạo',
        maMonHoc: 'IT3160',
        moTa: 'Môn học về các thuật toán và ứng dụng trí tuệ nhân tạo',
        soTinChi: 3,
        soGioLT: 45,
        soGioTH: 15,
        trangThai: true,
      ),
      MonHoc(
        id: '5',
        tenMonHoc: 'Mạng máy tính',
        maMonHoc: 'IT4062',
        moTa: 'Môn học về kiến trúc và giao thức mạng máy tính',
        soTinChi: 3,
        soGioLT: 45,
        soGioTH: 15,
        trangThai: true,
      ),
    ];
  }

  /// Thêm môn học mới
  void addMonHoc(MonHoc monHoc) {
    state = [...state, monHoc];
  }

  /// Cập nhật môn học
  void updateMonHoc(MonHoc monHoc) {
    state = [
      for (final item in state)
        if (item.id == monHoc.id) monHoc else item,
    ];
  }

  /// Xóa môn học
  void deleteMonHoc(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Lấy môn học theo ID
  MonHoc? getMonHocById(String id) {
    try {
      return state.firstWhere((monHoc) => monHoc.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lấy danh sách môn học đang hoạt động
  List<MonHoc> getMonHocHoatDong() {
    return state.where((monHoc) => monHoc.trangThai).toList();
  }
}
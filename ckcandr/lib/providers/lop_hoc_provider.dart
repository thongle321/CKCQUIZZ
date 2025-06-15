import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'dart:math';

/// Provider cho danh sách lớp học
final lopHocListProvider = StateNotifierProvider<LopHocNotifier, List<LopHoc>>((ref) {
  return LopHocNotifier();
});

/// Provider cho danh sách yêu cầu tham gia lớp
final yeuCauThamGiaLopProvider = StateNotifierProvider<YeuCauThamGiaLopNotifier, List<YeuCauThamGiaLop>>((ref) {
  return YeuCauThamGiaLopNotifier();
});

/// Notifier quản lý danh sách lớp học
class LopHocNotifier extends StateNotifier<List<LopHoc>> {
  LopHocNotifier() : super(_generateSampleData());

  /// Tạo dữ liệu mẫu
  static List<LopHoc> _generateSampleData() {
    final now = DateTime.now();
    return [
      LopHoc(
        id: '1',
        tenLop: 'Lập trình Flutter - Lớp 1',
        maLop: 'FLUTTER001',
        moTa: 'Lớp học lập trình Flutter cơ bản',
        giangVienId: 'teacher001',
        giangVienTen: 'Thầy Nguyễn Văn A',
        monHocId: '1',
        monHocTen: 'Lập trình di động',
        namHoc: 2024,
        hocKy: 1,
        siSo: 30,
        siSoHienTai: 25,
        trangThai: TrangThaiLop.hoatDong,
        ngayTao: now.subtract(const Duration(days: 30)),
        ngayCapNhat: now.subtract(const Duration(days: 1)),
        danhSachSinhVienIds: ['student001', 'student002', 'student003'],
      ),
      LopHoc(
        id: '2',
        tenLop: 'Cơ sở dữ liệu - Lớp A',
        maLop: 'DATABASE01',
        moTa: 'Lớp học cơ sở dữ liệu nâng cao',
        giangVienId: 'teacher002',
        giangVienTen: 'Thầy Nguyễn Văn B',
        monHocId: '2',
        monHocTen: 'Cơ sở dữ liệu',
        namHoc: 2024,
        hocKy: 1,
        siSo: 35,
        siSoHienTai: 30,
        trangThai: TrangThaiLop.hoatDong,
        ngayTao: now.subtract(const Duration(days: 25)),
        ngayCapNhat: now.subtract(const Duration(days: 2)),
        danhSachSinhVienIds: ['student001', 'student004', 'student005'],
      ),
    ];
  }

  /// Thêm lớp học mới
  void addLopHoc(LopHoc lopHoc) {
    state = [...state, lopHoc];
  }

  /// Cập nhật lớp học
  void updateLopHoc(LopHoc lopHoc) {
    state = [
      for (final item in state)
        if (item.id == lopHoc.id) lopHoc else item,
    ];
  }

  /// Xóa lớp học
  void deleteLopHoc(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Thêm sinh viên vào lớp
  void addSinhVienToLop(String lopHocId, String sinhVienId) {
    state = [
      for (final lopHoc in state)
        if (lopHoc.id == lopHocId)
          lopHoc.copyWith(
            danhSachSinhVienIds: [...lopHoc.danhSachSinhVienIds, sinhVienId],
            siSoHienTai: lopHoc.siSoHienTai + 1,
            ngayCapNhat: DateTime.now(),
          )
        else
          lopHoc,
    ];
  }

  /// Xóa sinh viên khỏi lớp
  void removeSinhVienFromLop(String lopHocId, String sinhVienId) {
    state = [
      for (final lopHoc in state)
        if (lopHoc.id == lopHocId)
          lopHoc.copyWith(
            danhSachSinhVienIds: lopHoc.danhSachSinhVienIds
                .where((id) => id != sinhVienId)
                .toList(),
            siSoHienTai: lopHoc.siSoHienTai - 1,
            ngayCapNhat: DateTime.now(),
          )
        else
          lopHoc,
    ];
  }

  /// Thay đổi giảng viên dạy
  void changeGiangVien(String lopHocId, String giangVienId, String giangVienTen) {
    state = [
      for (final lopHoc in state)
        if (lopHoc.id == lopHocId)
          lopHoc.copyWith(
            giangVienId: giangVienId,
            giangVienTen: giangVienTen,
            ngayCapNhat: DateTime.now(),
          )
        else
          lopHoc,
    ];
  }

  /// Lấy danh sách lớp theo giảng viên
  List<LopHoc> getLopHocByGiangVien(String giangVienId) {
    return state.where((lopHoc) => lopHoc.giangVienId == giangVienId).toList();
  }

  /// Lấy danh sách lớp mà sinh viên tham gia
  List<LopHoc> getLopHocBySinhVien(String sinhVienId) {
    return state
        .where((lopHoc) => lopHoc.danhSachSinhVienIds.contains(sinhVienId))
        .toList();
  }

  /// Tạo mã lớp ngẫu nhiên
  String generateMaLop() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}

/// Notifier quản lý yêu cầu tham gia lớp
class YeuCauThamGiaLopNotifier extends StateNotifier<List<YeuCauThamGiaLop>> {
  YeuCauThamGiaLopNotifier() : super(_generateSampleRequests());

  /// Tạo dữ liệu mẫu yêu cầu
  static List<YeuCauThamGiaLop> _generateSampleRequests() {
    final now = DateTime.now();
    return [
      YeuCauThamGiaLop(
        id: '1',
        sinhVienId: 'student006',
        sinhVienTen: 'Trần Văn F',
        sinhVienMSSV: 'SV006',
        lopHocId: '1',
        lopHocTen: 'Lập trình Flutter - Lớp 1',
        lyDo: 'Muốn học thêm về Flutter',
        ngayYeuCau: now.subtract(const Duration(hours: 2)),
        trangThai: TrangThaiYeuCau.choXuLy,
      ),
      YeuCauThamGiaLop(
        id: '2',
        sinhVienId: 'student007',
        sinhVienTen: 'Lê Thị G',
        sinhVienMSSV: 'SV007',
        lopHocId: '2',
        lopHocTen: 'Cơ sở dữ liệu - Lớp A',
        lyDo: 'Cần bổ sung kiến thức database',
        ngayYeuCau: now.subtract(const Duration(hours: 5)),
        trangThai: TrangThaiYeuCau.choXuLy,
      ),
    ];
  }

  /// Thêm yêu cầu tham gia lớp
  void addYeuCau(YeuCauThamGiaLop yeuCau) {
    state = [...state, yeuCau];
  }

  /// Cập nhật trạng thái yêu cầu
  void updateTrangThaiYeuCau(String yeuCauId, TrangThaiYeuCau trangThai) {
    state = [
      for (final yeuCau in state)
        if (yeuCau.id == yeuCauId)
          yeuCau.copyWith(trangThai: trangThai)
        else
          yeuCau,
    ];
  }

  /// Lấy yêu cầu theo lớp học
  List<YeuCauThamGiaLop> getYeuCauByLopHoc(String lopHocId) {
    return state.where((yeuCau) => yeuCau.lopHocId == lopHocId).toList();
  }

  /// Lấy yêu cầu theo giảng viên (thông qua lớp học)
  List<YeuCauThamGiaLop> getYeuCauByGiangVien(String giangVienId, List<LopHoc> danhSachLop) {
    final lopHocIds = danhSachLop
        .where((lop) => lop.giangVienId == giangVienId)
        .map((lop) => lop.id)
        .toList();
    
    return state
        .where((yeuCau) => lopHocIds.contains(yeuCau.lopHocId))
        .toList();
  }

  /// Lấy yêu cầu chờ xử lý
  List<YeuCauThamGiaLop> getYeuCauChoXuLy() {
    return state
        .where((yeuCau) => yeuCau.trangThai == TrangThaiYeuCau.choXuLy)
        .toList();
  }
}

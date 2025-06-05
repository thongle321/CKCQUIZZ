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
  ThongBaoNotifier(this._ref) : super(_mockThongBao);

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

// Dữ liệu mẫu để có nội dung hiển thị ban đầu
final List<ThongBao> _mockThongBao = [
  ThongBao(
    id: "1",
    tieuDe: "Làm đề kiểm tra NMLT",
    noiDung: "Gửi cho chỉ cho nhóm học phần NMLT - HK1. Các em chuẩn bị cho kỳ thi cuối kỳ vào ngày 20/12/2023. Danh sách đề thi sẽ được thông báo sau.",
    ngayTao: DateTime.now().subtract(const Duration(days: 2)),
    ngayCapNhat: DateTime.now().subtract(const Duration(days: 1)),
    nguoiTaoId: "gv001",
    phamViMoTa: "Gửi cho nhóm học phần NMLT - HK1",
  ),
  ThongBao(
    id: "2",
    tieuDe: "Thông báo về lịch học bù Lập Trình Hướng Đối Tượng",
    noiDung: "Thông báo đến các sinh viên lớp Lập Trình Hướng Đối Tượng về việc học bù buổi học ngày 15/11/2023. Lịch học bù sẽ vào ngày 18/11/2023, từ 7h30-11h30 tại phòng A1.02.",
    ngayTao: DateTime.now().subtract(const Duration(days: 5)),
    ngayCapNhat: DateTime.now().subtract(const Duration(days: 5)),
    nguoiTaoId: "gv001",
    phamViMoTa: "Sinh viên lớp Lập Trình Hướng Đối Tượng",
  ),
  ThongBao(
    id: "3",
    tieuDe: "Đổi phòng học môn Cấu trúc dữ liệu và giải thuật",
    noiDung: "Từ tuần sau (21/11/2023), lớp Cấu trúc dữ liệu và giải thuật sẽ chuyển sang học tại phòng B2.05 thay vì phòng A3.01 như trước đây.",
    ngayTao: DateTime.now().subtract(const Duration(days: 7)),
    ngayCapNhat: DateTime.now().subtract(const Duration(days: 7)),
    nguoiTaoId: "gv001",
    phamViMoTa: "Lớp Cấu trúc dữ liệu và giải thuật",
  ),
  ThongBao(
    id: "4",
    tieuDe: "Hướng dẫn đăng ký đồ án cuối kỳ",
    noiDung: "Các sinh viên vui lòng đăng ký đề tài đồ án cuối kỳ trước ngày 30/11/2023. Mẫu đăng ký đã được tải lên hệ thống LMS của trường. Mỗi nhóm không quá 3 sinh viên.",
    ngayTao: DateTime.now().subtract(const Duration(days: 10)),
    ngayCapNhat: DateTime.now().subtract(const Duration(days: 10)),
    nguoiTaoId: "gv001",
    phamViMoTa: "Toàn bộ sinh viên khoa CNTT",
    isPublished: false,
  ),
  ThongBao(
    id: "5",
    tieuDe: "Kết quả kiểm tra giữa kỳ môn Phát triển ứng dụng Web",
    noiDung: "Kết quả kiểm tra giữa kỳ môn Phát triển ứng dụng Web đã được công bố trên hệ thống. Sinh viên có thắc mắc về điểm số vui lòng liên hệ giảng viên trước ngày 25/11/2023.",
    ngayTao: DateTime.now().subtract(const Duration(days: 14)),
    ngayCapNhat: DateTime.now().subtract(const Duration(days: 14)),
    nguoiTaoId: "gv001",
    phamViMoTa: "Sinh viên môn Phát triển ứng dụng Web",
  ),
  ThongBao(
    id: "6",
    tieuDe: "Thông báo nghỉ học ngày 20/11/2023",
    noiDung: "Thông báo đến toàn thể sinh viên về việc nghỉ học ngày 20/11/2023 nhân ngày Nhà giáo Việt Nam. Các lớp học vào ngày này sẽ được dời lại theo thông báo cụ thể từ giảng viên phụ trách.",
    ngayTao: DateTime.now().subtract(const Duration(days: 20)),
    ngayCapNhat: DateTime.now().subtract(const Duration(days: 20)),
    nguoiTaoId: "gv001",
    phamViMoTa: "Toàn bộ sinh viên",
  ),
]; 
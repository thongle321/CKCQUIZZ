import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_kiem_tra_model.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:flutter/material.dart';

// Provider để quản lý danh sách đề kiểm tra
final deKiemTraListProvider = StateProvider<List<DeKiemTra>>((ref) {
  // Khởi tạo với một số đề kiểm tra mẫu
  return [
    DeKiemTra(
      id: '1',
      tenDeThi: 'Kiểm tra giữa kỳ NMLT',
      thoiGianBatDau: DateTime.now().add(const Duration(days: 1)),
      thoiGianLamBai: 60,
      danhSachCauHoiIds: ['1', '2', '3'],
      danhSachNhomHPIds: ['1'],
      nguoiTaoId: 'GV001',
      ngayTao: DateTime.now(),
      ngayCapNhat: DateTime.now(),
      monHocId: '1',
      choPhepThi: true,
    ),
    DeKiemTra(
      id: '2',
      tenDeThi: 'Bài kiểm tra cuối kỳ OOP',
      thoiGianBatDau: DateTime.now().subtract(const Duration(days: 1)),
      thoiGianLamBai: 90,
      danhSachCauHoiIds: ['4', '5', '6', '7'],
      danhSachNhomHPIds: ['2'],
      nguoiTaoId: 'GV001',
      ngayTao: DateTime.now().subtract(const Duration(days: 7)),
      ngayCapNhat: DateTime.now().subtract(const Duration(days: 7)),
      monHocId: '2',
      choPhepThi: true,
    ),
  ];
});

// Provider để lọc đề kiểm tra theo môn học
final filteredDeKiemTraProvider = Provider.family<List<DeKiemTra>, String?>((ref, monHocId) {
  final deKiemTraList = ref.watch(deKiemTraListProvider);
  
  if (monHocId == null) {
    return deKiemTraList;
  }
  
  return deKiemTraList.where((deThi) => deThi.monHocId == monHocId).toList();
});

// Notifier để quản lý thao tác với đề kiểm tra
class DeKiemTraNotifier extends StateNotifier<List<DeKiemTra>> {
  final Ref ref;

  DeKiemTraNotifier(this.ref, List<DeKiemTra> deKiemTras) : super(deKiemTras);

  // Thêm đề kiểm tra mới
  void themDeKiemTra(DeKiemTra deKiemTra) {
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    state = [...state, deKiemTra];
    
    hoatDongNotifier.addHoatDong(
      'Đã tạo đề kiểm tra: ${deKiemTra.tenDeThi}',
      LoaiHoatDong.DE_THI,
      Icons.assignment_add,
      idDoiTuongLienQuan: deKiemTra.id,
    );
  }

  // Cập nhật đề kiểm tra
  void capNhatDeKiemTra(DeKiemTra deKiemTra) {
    state = state.map((deThi) =>
      deThi.id == deKiemTra.id ? deKiemTra : deThi
    ).toList();
    
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã cập nhật đề kiểm tra: ${deKiemTra.tenDeThi}',
      LoaiHoatDong.DE_THI,
      Icons.assignment_turned_in,
      idDoiTuongLienQuan: deKiemTra.id,
    );
  }

  // Xóa đề kiểm tra
  void xoaDeKiemTra(DeKiemTra deKiemTra) {
    final tenDeThiLog = deKiemTra.tenDeThi;
    state = state.where((deThi) => deThi.id != deKiemTra.id).toList();
    
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã xóa đề kiểm tra: $tenDeThiLog',
      LoaiHoatDong.DE_THI,
      Icons.assignment_late,
      idDoiTuongLienQuan: deKiemTra.id,
    );
  }

  // Cập nhật trạng thái cho phép thi
  void capNhatTrangThaiChoPhepThi(String deKiemTraId, bool choPhepThi) {
    state = state.map((deThi) {
      if (deThi.id == deKiemTraId) {
        final updatedDeThi = deThi.copyWith(
          choPhepThi: choPhepThi,
          ngayCapNhat: DateTime.now(),
        );
        
        final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
        hoatDongNotifier.addHoatDong(
          '${choPhepThi ? "Đã bật" : "Đã tắt"} cho phép thi: "${deThi.tenDeThi}"',
          LoaiHoatDong.DE_THI,
          Icons.toggle_on_outlined,
          idDoiTuongLienQuan: deThi.id,
        );
        
        return updatedDeThi;
      }
      return deThi;
    }).toList();
  }

  // Lấy đề kiểm tra theo ID
  DeKiemTra? getDeKiemTraById(String id) {
    try {
      return state.firstWhere((deThi) => deThi.id == id);
    } catch (e) {
      return null;
    }
  }
} 
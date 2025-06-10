import 'dart:convert';
import 'package:ckcandr/models/nhom_hocphan_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NhomHocPhanService {
  final Ref _ref;

  NhomHocPhanService(this._ref);

  // Mock data - trong thực tế sẽ gọi API
  Future<List<NhomHocPhan>> getNhomHocPhanList() async {
    // Giả lập delay như API thực
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dữ liệu mẫu
    final currentUser = _ref.read(currentUserProvider);
    final giangVienId = currentUser?.id ?? '';
    
    final List<NhomHocPhan> mockData = [
      NhomHocPhan(
        id: '1',
        tenNhom: 'Nhóm 1',
        monHocId: 'CT101',
        namHoc: '2023-2024',
        hocKy: 'HK1',
        giangVienId: giangVienId,
        soSV: 35,
        ngayTao: DateTime.now().subtract(const Duration(days: 30)),
      ),
      NhomHocPhan(
        id: '2',
        tenNhom: 'Nhóm 2',
        monHocId: 'CT101',
        namHoc: '2023-2024',
        hocKy: 'HK1',
        giangVienId: giangVienId,
        soSV: 42,
        ngayTao: DateTime.now().subtract(const Duration(days: 28)),
      ),
    ];
    
    return mockData;
  }

  Future<NhomHocPhan> createNhomHocPhan(NhomHocPhan nhomHocPhan) async {
    // Giả lập delay như API thực
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế sẽ gửi dữ liệu đến server và nhận kết quả trả về
    return nhomHocPhan.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ngayTao: DateTime.now(),
    );
  }

  Future<NhomHocPhan> updateNhomHocPhan(NhomHocPhan nhomHocPhan) async {
    // Giả lập delay như API thực
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế sẽ gửi dữ liệu đến server và nhận kết quả trả về
    return nhomHocPhan;
  }

  Future<bool> deleteNhomHocPhan(String id) async {
    // Giả lập delay như API thực
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế sẽ gửi request xóa đến server
    return true;
  }
}

final nhomHocPhanServiceProvider = Provider<NhomHocPhanService>((ref) {
  return NhomHocPhanService(ref);
});

final nhomHocPhanListProvider = FutureProvider.autoDispose<List<NhomHocPhan>>((ref) async {
  final nhomHocPhanService = ref.watch(nhomHocPhanServiceProvider);
  return nhomHocPhanService.getNhomHocPhanList();
}); 
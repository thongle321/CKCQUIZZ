import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonHocService {
  // Mock data - trong thực tế sẽ gọi API
  Future<List<MonHoc>> getMonHocList() async {
    // Giả lập delay như API thực
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dữ liệu mẫu
    final List<MonHoc> mockData = [
      MonHoc(
        id: 'CT101',
        maMonHoc: 'CT101',
        tenMonHoc: 'Lập trình căn bản',
        soTinChi: 3,
        soGioLT: 30,
        soGioTH: 15,
        trangThai: true,
      ),
      MonHoc(
        id: 'CT103',
        maMonHoc: 'CT103',
        tenMonHoc: 'Cấu trúc dữ liệu',
        soTinChi: 4,
        soGioLT: 45,
        soGioTH: 15,
        trangThai: true,
      ),
      MonHoc(
        id: 'CT299',
        maMonHoc: 'CT299',
        tenMonHoc: 'Lập trình di động',
        soTinChi: 3,
        soGioLT: 30,
        soGioTH: 30,
        trangThai: true,
      ),
    ];
    
    return mockData;
  }

  Future<MonHoc?> getMonHocById(String id) async {
    final List<MonHoc> monHocList = await getMonHocList();
    try {
      return monHocList.firstWhere((monHoc) => monHoc.id == id);
    } catch (e) {
      return null;
    }
  }
}

final monHocServiceProvider = Provider<MonHocService>((ref) {
  return MonHocService();
});

final monHocListProvider = FutureProvider.autoDispose<List<MonHoc>>((ref) async {
  final monHocService = ref.watch(monHocServiceProvider);
  return monHocService.getMonHocList();
});

final monHocByIdProvider = FutureProvider.family<MonHoc?, String>((ref, id) async {
  final monHocService = ref.watch(monHocServiceProvider);
  return monHocService.getMonHocById(id);
});
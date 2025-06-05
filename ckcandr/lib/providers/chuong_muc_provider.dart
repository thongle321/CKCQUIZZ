import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';

// Provider để quản lý danh sách các chương mục.
// Sẽ được khởi tạo với danh sách rỗng để người dùng tự thêm.
final chuongMucListProvider = StateProvider<List<ChuongMuc>>((ref) => []);

// Provider để lấy danh sách chương mục đã lọc theo monHocId
final filteredChuongMucListProvider = Provider.family<List<ChuongMuc>, String>((ref, monHocId) {
  final allChuongMuc = ref.watch(chuongMucListProvider);
  return allChuongMuc.where((cm) => cm.monHocId == monHocId).toList()..sort((a,b) => a.thuTu.compareTo(b.thuTu));
}); 
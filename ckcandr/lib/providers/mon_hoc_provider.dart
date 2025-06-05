import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';

// Provider để quản lý danh sách các môn học.
// Sẽ được khởi tạo với danh sách rỗng để người dùng tự thêm.
final monHocListProvider = StateProvider<List<MonHoc>>((ref) => []); 
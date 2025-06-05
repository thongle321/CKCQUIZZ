import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';

// Provider để quản lý danh sách các câu hỏi.
// Sẽ được khởi tạo với danh sách rỗng để người dùng tự thêm.
final cauHoiListProvider = StateProvider<List<CauHoi>>((ref) => []); 
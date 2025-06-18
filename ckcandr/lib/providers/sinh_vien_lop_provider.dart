/// Provider để quản lý danh sách lớp học (nhóm học phần) mà sinh viên đã tham gia
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/services/sinh_vien_lop_service.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:flutter/foundation.dart';

// Provider cho SinhVienLopService
final sinhVienLopServiceProvider = Provider<SinhVienLopService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SinhVienLopService(apiService);
});

// Provider cho danh sách lớp học mà sinh viên đã tham gia (sử dụng API)
final sinhVienLopHocListProvider = FutureProvider<List<LopHoc>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final sinhVienLopService = ref.watch(sinhVienLopServiceProvider);
  
  if (currentUser == null) {
    debugPrint('⚠️ Chưa có thông tin user, trả về danh sách rỗng');
    return [];
  }
  
  try {
    debugPrint('🔄 Đang tải danh sách lớp học cho sinh viên: ${currentUser.hoVaTen}');
    final lopHocList = await sinhVienLopService.getLopHocDaThamGia();

    // API server đã tự động lọc theo role sinh viên
    // Chỉ trả về các lớp mà sinh viên đã tham gia
    debugPrint('✅ Tải được ${lopHocList.length} lớp học mà sinh viên đã tham gia');
    return lopHocList;
  } catch (e) {
    debugPrint('❌ Lỗi khi tải danh sách lớp học: $e');
    throw Exception('Không thể tải danh sách lớp học: $e');
  }
});

// Provider cho lớp học được lọc theo tìm kiếm và bộ lọc
final filteredSinhVienLopHocProvider = Provider.family<List<LopHoc>, Map<String, String>>((ref, filters) {
  final lopHocAsyncValue = ref.watch(sinhVienLopHocListProvider);
  
  return lopHocAsyncValue.when(
    data: (lopHocList) {
      final searchQuery = filters['search']?.toLowerCase() ?? '';
      final hocKyFilter = filters['hocKy'] ?? 'all';
      
      return lopHocList.where((lop) {
        // Lọc theo tìm kiếm
        final searchMatches = searchQuery.isEmpty ||
            lop.tenlop.toLowerCase().contains(searchQuery);
        
        // Lọc theo học kỳ
        final hocKyMatches = hocKyFilter == 'all' ||
            (lop.hocky != null && 'HK${lop.hocky}' == hocKyFilter);
        
        return searchMatches && hocKyMatches && (lop.hienthi ?? false);
      }).toList();
    },
    loading: () => [],
    error: (error, stack) {
      debugPrint('❌ Lỗi trong filteredSinhVienLopHocProvider: $error');
      return [];
    },
  );
});

// Provider cho chi tiết lớp học
final lopHocDetailProvider = FutureProvider.family<LopHoc?, int>((ref, lopId) async {
  final sinhVienLopService = ref.watch(sinhVienLopServiceProvider);
  
  try {
    debugPrint('🔄 Đang tải chi tiết lớp học ID: $lopId');
    final lopHoc = await sinhVienLopService.getLopHocById(lopId);
    debugPrint('✅ Tải chi tiết lớp học thành công');
    return lopHoc;
  } catch (e) {
    debugPrint('❌ Lỗi khi tải chi tiết lớp học: $e');
    throw Exception('Không thể tải chi tiết lớp học: $e');
  }
});

// TODO: Provider cho danh sách sinh viên trong lớp (sẽ implement sau)

// TODO: Notifier để quản lý các thao tác với lớp học (sẽ implement sau khi cần)

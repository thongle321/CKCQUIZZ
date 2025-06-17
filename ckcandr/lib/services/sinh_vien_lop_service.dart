/// Service để gọi API lấy danh sách lớp học (nhóm học phần) mà sinh viên đã tham gia
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:flutter/foundation.dart';

class SinhVienLopService {
  final ApiService _apiService;

  SinhVienLopService(this._apiService);

  /// Lấy danh sách lớp học mà sinh viên đã tham gia
  Future<List<LopHoc>> getLopHocDaThamGia() async {
    try {
      debugPrint('🔄 Đang gọi API lấy danh sách lớp học sinh viên đã tham gia...');

      // Gọi API lấy tất cả lớp học với filter hienthi=true
      final lopHocList = await _apiService.getClasses(hienthi: true);
      debugPrint('✅ Lấy được ${lopHocList.length} lớp học từ API');

      // TODO: Thêm logic lọc dựa trên ChiTietLop khi có API riêng
      // Hiện tại trả về tất cả lớp học có hienthi=true
      return lopHocList;
    } catch (e) {
      debugPrint('❌ Lỗi khi gọi API lấy lớp học: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết lớp học theo ID
  Future<LopHoc?> getLopHocById(int lopId) async {
    try {
      debugPrint('🔄 Đang lấy chi tiết lớp học ID: $lopId');

      final lopHoc = await _apiService.getClassById(lopId);
      debugPrint('✅ Lấy được chi tiết lớp học: ${lopHoc.tenlop}');
      return lopHoc;
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy chi tiết lớp học: $e');
      // Nếu không tìm thấy, trả về null thay vì throw exception
      return null;
    }
  }

  /// Tham gia lớp học bằng mã mời (TODO: Implement khi có API)
  Future<bool> thamGiaLopHoc(String maLop) async {
    try {
      debugPrint('🔄 Đang tham gia lớp học với mã: $maLop');

      // TODO: Implement khi có API endpoint cho việc tham gia lớp
      // Hiện tại chỉ giả lập thành công
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('✅ Tham gia lớp học thành công (giả lập)');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi khi tham gia lớp học: $e');
      return false;
    }
  }
}

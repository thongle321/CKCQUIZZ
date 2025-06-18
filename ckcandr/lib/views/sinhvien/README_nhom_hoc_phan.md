# Giao diện Lớp học cho Sinh viên (API Integration)

## Tổng quan
File `nhom_hoc_phan_screen.dart` cung cấp giao diện hiển thị danh sách lớp học mà sinh viên đã tham gia, sử dụng API thực tế từ server.

## Tính năng chính

### 1. **Hiển thị danh sách lớp học từ API**
- ✅ Tích hợp API thực tế từ server `/api/Lop?hienthi=true`
- ✅ Server tự động lọc theo role sinh viên (chỉ trả về lớp đã tham gia)
- ✅ Hiển thị thông tin: tên lớp, môn học, học kỳ, năm học, sĩ số, mã mời, ghi chú

### 2. **Tìm kiếm và lọc động**
- ✅ Tìm kiếm theo tên lớp học (real-time)
- ✅ Lọc theo học kỳ (HK1, HK2, HK3)
- ✅ Giao diện responsive cho mobile và desktop

### 3. **Refresh dữ liệu từ API**
- ✅ Nút refresh trên AppBar gọi API mới
- ✅ Pull-to-refresh trên danh sách
- ✅ Loading states và error handling

### 4. **Chi tiết lớp học**
- ✅ Tap vào card để xem chi tiết đầy đủ
- ✅ Hiển thị thông tin từ API: mã lớp, môn học, sĩ số, mã mời, ghi chú
- ✅ Trạng thái tham gia và trạng thái lớp học

## Cấu trúc code (API Integration)

### API Service Layer
```dart
// SinhVienLopService - Gọi API thực tế
class SinhVienLopService {
  final ApiService _apiService;

  Future<List<LopHoc>> getLopHocDaThamGia() async {
    // Gọi API /api/Lop?hienthi=true
    // Server tự động lọc theo role sinh viên
    return await _apiService.getClasses(hienthi: true);
  }
}
```

### Providers với API
```dart
// Provider gọi API thực tế
final sinhVienLopHocListProvider = FutureProvider<List<LopHoc>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final sinhVienLopService = ref.watch(sinhVienLopServiceProvider);

  // API server tự động lọc theo role sinh viên
  return await sinhVienLopService.getLopHocDaThamGia();
});
```

### Widgets chính
- `SinhVienNhomHocPhanScreen`: Main widget với API integration
- `_buildSearchAndFilters()`: Thanh tìm kiếm và bộ lọc real-time
- `_buildHeader()`: Tiêu đề và thống kê từ API
- `_buildNhomHocPhanList()`: Danh sách với AsyncValue handling
- `_buildLopHocCard()`: Card hiển thị thông tin lớp học từ API
- `_showLopHocDetail()`: Dialog chi tiết với dữ liệu đầy đủ

## Role-based Access
- Sử dụng `RoleThemedWidget` với role sinh viên
- Theme và màu sắc phù hợp với role
- Chỉ hiển thị dữ liệu của sinh viên hiện tại

## ✅ API Integration (COMPLETED)
Đã tích hợp hoàn toàn với API thực tế:

1. **✅ Endpoint đã sử dụng**
   ```
   GET /api/Lop?hienthi=true
   ```
   - Server tự động lọc theo role sinh viên
   - Chỉ trả về lớp học mà sinh viên đã tham gia (qua bảng ChiTietLops)

2. **✅ Service layer hoàn chỉnh**
   - `SinhVienLopService` - Gọi API thực tế
   - `ApiService.getClasses()` - HTTP client wrapper
   - Error handling và logging đầy đủ

3. **✅ Provider đã cập nhật**
   - `sinhVienLopHocListProvider` - FutureProvider gọi API
   - `filteredSinhVienLopHocProvider` - Lọc và tìm kiếm
   - Loading states, error handling, refresh functionality

## Cách sử dụng

### 1. Import trong dashboard
```dart
import 'package:ckcandr/views/sinhvien/nhom_hoc_phan_screen.dart';

// Sử dụng trong dashboard
case 2:
  return const SinhVienNhomHocPhanScreen();
```

### 2. Cấu hình provider
Provider đã được tự động cấu hình và sử dụng dữ liệu từ:
- `currentUserProvider`: Thông tin sinh viên hiện tại
- `nhomHocPhanListProvider`: Danh sách tất cả nhóm học phần
- `monHocListProvider`: Thông tin môn học

## Responsive Design
- Mobile: ListView với cards dọc
- Desktop: Tương tự nhưng với layout rộng hơn
- Adaptive UI components

## Error Handling
- Try-catch trong tất cả operations
- Fallback UI khi không có dữ liệu
- Debug logging cho development

## Testing
Để test giao diện:
1. Đăng nhập với tài khoản sinh viên
2. Navigate đến tab "Nhóm học phần"
3. Kiểm tra hiển thị danh sách
4. Test tìm kiếm và lọc
5. Test refresh functionality
6. Test chi tiết nhóm học phần

## Cải tiến trong tương lai
1. Thêm chức năng đăng ký/hủy đăng ký nhóm
2. Hiển thị lịch học của nhóm
3. Thông báo từ giảng viên
4. Danh sách bài tập/kiểm tra của nhóm
5. Tích hợp với calendar app

# Giao diện Nhóm học phần cho Sinh viên

## Tổng quan
File `nhom_hoc_phan_screen.dart` cung cấp giao diện hiển thị danh sách nhóm học phần mà sinh viên đã đăng ký.

## Tính năng chính

### 1. **Hiển thị danh sách nhóm học phần**
- Chỉ hiển thị các nhóm học phần mà sinh viên hiện tại đã đăng ký
- Sử dụng provider `sinhVienNhomHocPhanProvider` để lọc dữ liệu
- Hiển thị thông tin: tên nhóm, môn học, học kỳ, năm học, sĩ số

### 2. **Tìm kiếm và lọc**
- Tìm kiếm theo tên nhóm học phần
- Lọc theo học kỳ (HK1, HK2, HK3)
- Giao diện responsive cho mobile và desktop

### 3. **Refresh dữ liệu**
- Nút refresh trên AppBar
- Pull-to-refresh trên danh sách
- Tự động invalidate providers liên quan

### 4. **Chi tiết nhóm học phần**
- Tap vào card để xem chi tiết
- Hiển thị đầy đủ thông tin trong dialog
- Trạng thái đăng ký của sinh viên

## Cấu trúc code

### Providers
```dart
// Provider lọc nhóm học phần cho sinh viên
final sinhVienNhomHocPhanProvider = Provider<List<NhomHocPhan>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final allNhomHocPhan = ref.watch(nhomHocPhanListProvider);
  
  // Logic lọc nhóm đã đăng ký
  return filteredList;
});
```

### Widgets chính
- `SinhVienNhomHocPhanScreen`: Main widget
- `_buildSearchAndFilters()`: Thanh tìm kiếm và bộ lọc
- `_buildHeader()`: Tiêu đề và thống kê
- `_buildNhomHocPhanList()`: Danh sách với RefreshIndicator
- `_buildNhomHocPhanCard()`: Card hiển thị thông tin nhóm
- `_showNhomHocPhanDetail()`: Dialog chi tiết

## Role-based Access
- Sử dụng `RoleThemedWidget` với role sinh viên
- Theme và màu sắc phù hợp với role
- Chỉ hiển thị dữ liệu của sinh viên hiện tại

## API Integration (TODO)
Hiện tại sử dụng dữ liệu mock. Cần tích hợp với API:

1. **Endpoint lấy nhóm học phần của sinh viên**
   ```
   GET /api/sinhvien/{id}/nhom-hoc-phan
   ```

2. **Service layer**
   - Tạo `SinhVienNhomHocPhanService`
   - Implement methods: `getNhomHocPhanBySinhVien()`

3. **Provider cập nhật**
   - Thay thế logic mock bằng API calls
   - Thêm error handling và loading states

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

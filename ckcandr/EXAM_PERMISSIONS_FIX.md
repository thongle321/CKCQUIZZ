# Exam Permissions Fix - Student Result Viewing

## Vấn đề ban đầu

Khi giảng viên tạo đề thi với các quyền hạn chế (không cho phép sinh viên xem kết quả/đáp án), sinh viên vẫn có thể truy cập vào màn hình xem kết quả và ứng dụng bị crash hoặc hiển thị lỗi vì không có dữ liệu.

## Root Cause

- Backend API `ExamForClassDto` không trả về các permission fields (`Hienthibailam`, `Xemdiemthi`, `Xemdapan`) từ DeThi model
- Flutter app không biết được quyền của giảng viên đã cài đặt
- UI không có logic conditional rendering dựa trên permissions

## Giải pháp đã implement

### 1. Tạo ExamPermissions Model

**File:** `ckcandr/lib/models/exam_permissions_model.dart`

```dart
class ExamPermissions {
  final bool showExamPaper;  // Hienthibailam
  final bool showScore;      // Xemdiemthi  
  final bool showAnswers;    // Xemdapan
  
  // Helper methods
  bool get canViewAnyResults;
  bool get canViewCompleteResults;
  String get permissionDescription;
}
```

### 2. Thêm API Service để lấy permissions

**File:** `ckcandr/lib/services/api_service.dart`

```dart
Future<Map<String, dynamic>?> getExamPermissions(int examId) async {
  // Gọi API /api/DeThi/{examId} để lấy thông tin permissions
  // Trả về default permissions nếu API fail (backward compatibility)
}
```

### 3. Cập nhật ExamForStudent Model

**File:** `ckcandr/lib/models/exam_taking_model.dart`

- Thêm field `ExamPermissions? permissions`
- Thêm helper methods: `canViewResult`, `canViewScore`, `canViewExamPaper`, `canViewAnswers`
- Thêm method `copyWithPermissions()` để tạo copy với permissions mới

### 4. Cập nhật Student Exam Result Screen

**File:** `ckcandr/lib/views/sinhvien/exam_result_screen.dart`

**Thay đổi chính:**
- Load permissions trước khi hiển thị kết quả
- Kiểm tra `permissions.canViewAnyResults` - nếu false thì hiển thị thông báo lỗi
- Conditional rendering dựa trên permissions:
  - `showScore`: Hiển thị điểm số và thống kê
  - `showExamPaper`: Hiển thị chi tiết bài làm của sinh viên
  - `showAnswers`: Hiển thị đáp án đúng
- Thêm `_buildPermissionInfoCard()` để thông báo quyền hạn chế

### 5. Cập nhật Class Exams Screen

**File:** `ckcandr/lib/views/sinhvien/class_exams_screen.dart`

**Thay đổi chính:**
- Kiểm tra permissions trong `_reviewExam()` trước khi navigate
- Hiển thị thông báo lỗi nếu không có quyền xem kết quả
- Sử dụng `mounted` check để tránh lỗi async context

## Các Scenarios được handle

### 1. Instructor disable tất cả permissions
- **Behavior:** Sinh viên không thể xem kết quả, hiển thị thông báo "Giảng viên không cho phép xem kết quả bài thi này"
- **UI:** Nút "Xem kết quả" vẫn hiển thị nhưng khi click sẽ show error dialog

### 2. Instructor enable một phần permissions

#### Chỉ cho phép xem điểm số (`showScore: true`)
- **Behavior:** Hiển thị điểm số và thống kê, ẩn chi tiết bài làm và đáp án
- **UI:** Card điểm số + performance stats, không có detailed answers

#### Chỉ cho phép xem bài làm (`showExamPaper: true`)
- **Behavior:** Hiển thị chi tiết câu trả lời của sinh viên, ẩn điểm số và đáp án đúng
- **UI:** Detailed answers nhưng không có correct answers section

#### Chỉ cho phép xem đáp án (`showAnswers: true`)
- **Behavior:** Hiển thị đáp án đúng, ẩn điểm số và bài làm sinh viên
- **UI:** Chỉ hiển thị correct answers trong detailed view

### 3. Instructor enable tất cả permissions
- **Behavior:** Hiển thị đầy đủ như trước đây
- **UI:** Tất cả sections đều hiển thị

## Backward Compatibility

- Nếu API `getExamPermissions()` fail, sử dụng default permissions (all true)
- Nếu `permissions` field là null, mặc định cho phép xem tất cả
- Không breaking changes với existing code

## Testing

### Unit Tests
**File:** `ckcandr/test/exam_permissions_test.dart`
- Test ExamPermissions model logic
- Test ExamForStudent integration với permissions
- Test các permission combinations

### Demo Screen
**File:** `ckcandr/lib/demo/exam_permissions_demo.dart`
- Interactive demo để test các scenarios
- Toggle permissions và xem kết quả real-time

## Files Modified

1. `ckcandr/lib/models/exam_permissions_model.dart` - **NEW**
2. `ckcandr/lib/models/exam_permissions_model.g.dart` - **NEW**
3. `ckcandr/lib/models/exam_taking_model.dart` - **MODIFIED**
4. `ckcandr/lib/models/exam_taking_model.g.dart` - **MODIFIED**
5. `ckcandr/lib/services/api_service.dart` - **MODIFIED**
6. `ckcandr/lib/views/sinhvien/exam_result_screen.dart` - **MODIFIED**
7. `ckcandr/lib/views/sinhvien/class_exams_screen.dart` - **MODIFIED**
8. `ckcandr/test/exam_permissions_test.dart` - **NEW**
9. `ckcandr/lib/demo/exam_permissions_demo.dart` - **NEW**

## Kết quả

✅ **Không còn crash** khi sinh viên cố gắng xem kết quả bị hạn chế
✅ **UI hiển thị đúng** dựa trên permissions của giảng viên  
✅ **Thông báo rõ ràng** về quyền hạn chế
✅ **Backward compatibility** với code cũ
✅ **Graceful error handling** khi API fail

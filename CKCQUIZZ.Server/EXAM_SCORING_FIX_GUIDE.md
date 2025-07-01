# Hướng dẫn Fix Bug Chấm Điểm Bài Thi

## Vấn đề
2 bài thi giống nhau (cùng không trả lời gì) nhưng có số câu đúng khác nhau.

## Nguyên nhân
- Logic chấm điểm không nhất quán
- Dữ liệu không đồng bộ trong database
- Bug trong xử lý single choice questions

## Giải pháp đã implement

### 1. Debug Endpoints (Chỉ Admin/Teacher)

#### Kiểm tra dữ liệu bài thi
```
GET /api/Exam/debug-exam-data/{examId}
```
Trả về chi tiết dữ liệu của tất cả bài thi đã submit cho đề thi cụ thể.

#### Tính lại điểm số
```
POST /api/Exam/recalculate-scores
Content-Type: application/json

{
  "examId": 1  // null để tính lại tất cả bài thi
}
```

### 2. Cách sử dụng

#### Bước 1: Kiểm tra dữ liệu
1. Đăng nhập với tài khoản Admin/Teacher
2. Gọi API debug để xem dữ liệu:
```bash
curl -X GET "https://localhost:7254/api/Exam/debug-exam-data/1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Bước 2: Tính lại điểm số
```bash
curl -X POST "https://localhost:7254/api/Exam/recalculate-scores" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"examId": 1}'
```

### 3. Debug Logs

Server sẽ in ra console logs chi tiết:
- `[DEBUG]` - Thông tin debug chung
- `[VALIDATION]` - Quá trình validate dữ liệu
- `[FIX]` - Các fix được áp dụng
- `[WARNING]` - Cảnh báo về dữ liệu không hợp lệ
- `[RECALCULATE]` - Quá trình tính lại điểm

### 4. Kiểm tra kết quả

Sau khi chạy recalculate, kiểm tra:
1. Console logs để xem có fix được gì không
2. Database để xác nhận điểm số đã được cập nhật
3. Flutter app để xem kết quả hiển thị đúng chưa

### 5. SQL Scripts

File `Scripts/FixExamScoringBug.sql` chứa các query để:
- Kiểm tra dữ liệu có vấn đề
- Tìm các trường hợp single choice có nhiều đáp án được chọn
- Recalculate scores thủ công

## Lưu ý

1. **Backup database** trước khi chạy fix
2. **Test trên môi trường dev** trước
3. **Chỉ Admin/Teacher** mới có quyền gọi debug endpoints
4. **Monitor logs** khi chạy để đảm bảo không có lỗi

## Troubleshooting

### Nếu vẫn có vấn đề:
1. Kiểm tra logs chi tiết
2. Chạy SQL scripts để kiểm tra dữ liệu thủ công
3. Kiểm tra logic chấm điểm trong ExamScoringService
4. Đảm bảo stored procedure `KhoiTaoCauTraLoiSinhVien` hoạt động đúng

### Các trường hợp thường gặp:
- **Multiple answers for single choice**: Sẽ được tự động fix
- **Missing answer records**: Cần kiểm tra stored procedure
- **Incorrect answer validation**: Kiểm tra logic trong ExamScoringService

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/models/thong_bao_model.dart';

/// Helper class để test tính năng thông báo sinh viên
/// Cung cấp các method để tạo mock data và test các tình huống khác nhau
class NotificationTestHelper {
  
  /// tạo mock notifications cho test
  static List<ThongBao> createMockNotifications() {
    final now = DateTime.now();
    
    return [
      // thông báo đề thi mới - có thể vào thi
      ThongBao(
        maTb: 1,
        noiDung: '📝 Đề thi mới: "Kiểm tra giữa kỳ Lập trình C++" đã được tạo. Thời gian thi: ${_formatDateTime(now.add(const Duration(minutes: 5)))} - ${_formatDateTime(now.add(const Duration(hours: 2)))}',
        maMonHoc: 101,
        tenMonHoc: 'Lập trình C++',
        namHoc: 2024,
        hocKy: 1,
        thoiGianTao: now.subtract(const Duration(hours: 1)),
        nguoiTao: 'teacher1',
        hoTenNguoiTao: 'Thầy Nguyễn Văn A',
        tenLop: 'Lớp C++ Nâng cao',
        maLop: 1,
        examId: 123,
        examStartTime: now.add(const Duration(minutes: 5)),
        examEndTime: now.add(const Duration(hours: 2)),
        examName: 'Kiểm tra giữa kỳ Lập trình C++',
        isRead: false,
        type: NotificationType.examNew,
      ),
      
      // thông báo nhắc nhở thi - chưa đến giờ
      ThongBao(
        maTb: 2,
        noiDung: '⏰ Sắp có bài kiểm tra: "Kiểm tra cuối kỳ Java" sẽ bắt đầu trong 2 giờ.',
        maMonHoc: 102,
        tenMonHoc: 'Lập trình Java',
        namHoc: 2024,
        hocKy: 1,
        thoiGianTao: now.subtract(const Duration(minutes: 30)),
        nguoiTao: 'teacher2',
        hoTenNguoiTao: 'Cô Trần Thị B',
        tenLop: 'Lớp Java Cơ bản',
        maLop: 2,
        examId: 124,
        examStartTime: now.add(const Duration(hours: 2)),
        examEndTime: now.add(const Duration(hours: 4)),
        examName: 'Kiểm tra cuối kỳ Java',
        isRead: false,
        type: NotificationType.examReminder,
      ),
      
      // thông báo đề thi đã hết hạn
      ThongBao(
        maTb: 3,
        noiDung: '📝 Đề thi "Kiểm tra Python" đã kết thúc. Kết quả sẽ được công bố sớm.',
        maMonHoc: 103,
        tenMonHoc: 'Lập trình Python',
        namHoc: 2024,
        hocKy: 1,
        thoiGianTao: now.subtract(const Duration(days: 1)),
        nguoiTao: 'teacher3',
        hoTenNguoiTao: 'Thầy Lê Văn C',
        tenLop: 'Lớp Python',
        maLop: 3,
        examId: 125,
        examStartTime: now.subtract(const Duration(days: 1, hours: 2)),
        examEndTime: now.subtract(const Duration(days: 1)),
        examName: 'Kiểm tra Python',
        isRead: true,
        type: NotificationType.examResult,
      ),
      
      // thông báo cập nhật đề thi
      ThongBao(
        maTb: 4,
        noiDung: '✏️ Đề thi "Kiểm tra Database" đã được cập nhật thời gian. Vui lòng kiểm tra lại.',
        maMonHoc: 104,
        tenMonHoc: 'Cơ sở dữ liệu',
        namHoc: 2024,
        hocKy: 1,
        thoiGianTao: now.subtract(const Duration(hours: 3)),
        nguoiTao: 'teacher4',
        hoTenNguoiTao: 'Cô Phạm Thị D',
        tenLop: 'Lớp Database',
        maLop: 4,
        examId: 126,
        examStartTime: now.add(const Duration(days: 1)),
        examEndTime: now.add(const Duration(days: 1, hours: 2)),
        examName: 'Kiểm tra Database',
        isRead: false,
        type: NotificationType.examUpdate,
      ),
      
      // thông báo lớp học thường
      ThongBao(
        maTb: 5,
        noiDung: '📢 Lịch học tuần tới sẽ thay đổi. Lớp sẽ học vào thứ 3 thay vì thứ 2.',
        maMonHoc: 105,
        tenMonHoc: 'Thuật toán',
        namHoc: 2024,
        hocKy: 1,
        thoiGianTao: now.subtract(const Duration(hours: 6)),
        nguoiTao: 'teacher5',
        hoTenNguoiTao: 'Thầy Hoàng Văn E',
        tenLop: 'Lớp Thuật toán',
        maLop: 5,
        isRead: true,
        type: NotificationType.classInfo,
      ),
      
      // thông báo hệ thống
      ThongBao(
        maTb: 6,
        noiDung: '🔧 Hệ thống sẽ bảo trì từ 23:00 - 01:00 đêm nay. Vui lòng hoàn thành bài thi trước thời gian này.',
        thoiGianTao: now.subtract(const Duration(hours: 12)),
        isRead: false,
        type: NotificationType.system,
      ),
    ];
  }

  /// test các trường hợp khác nhau của nút "Vào thi"
  static void testExamButtonStates() {
    final notifications = createMockNotifications();
    
    debugPrint('=== TEST EXAM BUTTON STATES ===');
    
    for (final notification in notifications) {
      if (notification.isExamNotification) {
        debugPrint('\n📝 Thông báo: ${notification.noiDung.substring(0, 50)}...');
        debugPrint('   - Có thể vào thi: ${notification.canTakeExam}');
        debugPrint('   - Đã hết hạn: ${notification.isExamExpired}');
        debugPrint('   - Thời gian còn lại: ${notification.timeUntilExam?.inMinutes ?? 0} phút');
        
        String buttonState;
        if (notification.isExamExpired) {
          buttonState = 'Đã hết hạn (disabled)';
        } else if (notification.canTakeExam) {
          buttonState = 'Vào thi ngay (enabled)';
        } else if (notification.timeUntilExam != null) {
          final hours = notification.timeUntilExam!.inHours;
          final minutes = notification.timeUntilExam!.inMinutes % 60;
          buttonState = 'Còn ${hours}h ${minutes}m (disabled)';
        } else {
          buttonState = 'Xem chi tiết (enabled)';
        }
        
        debugPrint('   - Trạng thái nút: $buttonState');
      }
    }
    
    debugPrint('\n=== END TEST ===');
  }

  /// test trạng thái đã đọc/chưa đọc
  static void testReadUnreadStates() {
    final notifications = createMockNotifications();
    
    debugPrint('=== TEST READ/UNREAD STATES ===');
    
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final totalCount = notifications.length;
    
    debugPrint('Tổng số thông báo: $totalCount');
    debugPrint('Số thông báo chưa đọc: $unreadCount');
    debugPrint('Số thông báo đã đọc: ${totalCount - unreadCount}');
    
    debugPrint('\nChi tiết:');
    for (final notification in notifications) {
      final status = notification.isRead ? '✅ Đã đọc' : '🔴 Chưa đọc';
      debugPrint('   - ID ${notification.maTb}: $status');
    }
    
    debugPrint('\n=== END TEST ===');
  }

  /// test notification types và icons
  static void testNotificationTypes() {
    final notifications = createMockNotifications();
    
    debugPrint('=== TEST NOTIFICATION TYPES ===');
    
    for (final notification in notifications) {
      String icon;
      String color;
      
      switch (notification.type) {
        case NotificationType.examNew:
          icon = '📝';
          color = 'Blue';
          break;
        case NotificationType.examReminder:
          icon = '⏰';
          color = 'Orange';
          break;
        case NotificationType.examUpdate:
          icon = '✏️';
          color = 'Purple';
          break;
        case NotificationType.examResult:
          icon = '🎯';
          color = 'Green';
          break;
        case NotificationType.classInfo:
          icon = '📢';
          color = 'Teal';
          break;
        case NotificationType.system:
          icon = '🔧';
          color = 'Grey';
          break;
        case NotificationType.general:
          icon = '📄';
          color = 'Indigo';
          break;
      }
      
      debugPrint('ID ${notification.maTb}: $icon ${notification.type.name} ($color)');
    }
    
    debugPrint('\n=== END TEST ===');
  }

  /// reset tất cả trạng thái test
  static Future<void> resetTestState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // xóa tất cả keys liên quan đến notification
      await prefs.remove('read_notifications');
      await prefs.remove('notification_reminder_shown_today');
      await prefs.remove('notification_reminder_last_date');
      
      debugPrint('✅ Reset test state thành công');
    } catch (e) {
      debugPrint('❌ Lỗi khi reset test state: $e');
    }
  }

  /// chạy tất cả tests
  static void runAllTests() {
    debugPrint('🧪 BẮT ĐẦU CHẠY TẤT CẢ TESTS');
    debugPrint('=====================================');
    
    testNotificationTypes();
    testReadUnreadStates();
    testExamButtonStates();
    
    debugPrint('=====================================');
    debugPrint('🎉 HOÀN THÀNH TẤT CẢ TESTS');
  }

  /// helper method để format datetime
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// tạo notification với thời gian tùy chỉnh để test
  static ThongBao createTestExamNotification({
    required int id,
    required String examName,
    required DateTime examStartTime,
    required DateTime examEndTime,
    bool isRead = false,
  }) {
    return ThongBao(
      maTb: id,
      noiDung: '📝 Đề thi mới: "$examName" đã được tạo. Thời gian thi: ${_formatDateTime(examStartTime)} - ${_formatDateTime(examEndTime)}',
      maMonHoc: 999,
      tenMonHoc: 'Test Subject',
      namHoc: 2024,
      hocKy: 1,
      thoiGianTao: DateTime.now().subtract(const Duration(hours: 1)),
      nguoiTao: 'test_teacher',
      hoTenNguoiTao: 'Test Teacher',
      tenLop: 'Test Class',
      maLop: 999,
      examId: id,
      examStartTime: examStartTime,
      examEndTime: examEndTime,
      examName: examName,
      isRead: isRead,
      type: NotificationType.examNew,
    );
  }
}

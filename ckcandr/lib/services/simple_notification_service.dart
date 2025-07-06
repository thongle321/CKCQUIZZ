import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple notification service chỉ dùng local data
class SimpleNotificationService {
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  Timer? _examReminderTimer;
  final List<LocalNotification> _notifications = [];

  /// Khởi tạo service
  Future<void> initialize() async {
    await _loadNotifications();
    _startExamReminder();
  }

  /// Lấy danh sách thông báo
  List<LocalNotification> getNotifications() {
    return List.from(_notifications);
  }

  /// Thêm thông báo mới
  Future<void> addNotification(LocalNotification notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Xóa thông báo
  Future<void> removeNotification(int notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  /// Lấy số thông báo chưa đọc
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Tạo thông báo tự động khi đến giờ thi
  void _startExamReminder() {
    _examReminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkExamReminders();
    });
  }

  /// Kiểm tra và tạo thông báo nhắc nhở thi
  void _checkExamReminders() {
    final now = DateTime.now();
    
    // Giả lập đề thi sắp diễn ra (trong thực tế sẽ lấy từ API)
    final upcomingExam = DateTime(2025, 6, 27, 1, 0); // 01:00 ngày 27/6/2025
    final timeUntilExam = upcomingExam.difference(now);
    
    // Thông báo 30 phút trước
    if (timeUntilExam.inMinutes <= 30 && timeUntilExam.inMinutes > 25) {
      _createExamReminder('30 phút', 'kt');
    }
    // Thông báo 10 phút trước
    else if (timeUntilExam.inMinutes <= 10 && timeUntilExam.inMinutes > 5) {
      _createExamReminder('10 phút', 'kt');
    }
    // Thông báo 5 phút trước
    else if (timeUntilExam.inMinutes <= 5 && timeUntilExam.inMinutes > 0) {
      _createExamReminder('5 phút', 'kt');
    }
    // Thông báo khi đến giờ
    else if (timeUntilExam.inMinutes <= 0 && timeUntilExam.inMinutes > -5) {
      _createExamStartNotification('kt');
    }
  }

  /// Tạo thông báo nhắc nhở
  void _createExamReminder(String timeRemaining, String examName) {
    final notification = LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '⏰ Sắp đến giờ thi',
      content: 'Đề thi "$examName" sẽ bắt đầu trong $timeRemaining. Hãy chuẩn bị sẵn sàng!',
      type: NotificationType.examReminder,
      time: DateTime.now(),
      teacherName: 'Hệ thống',
      isRead: false,
    );
    
    addNotification(notification);
  }

  /// Tạo thông báo khi đến giờ thi
  void _createExamStartNotification(String examName) {
    final notification = LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🚨 Đã đến giờ thi!',
      content: 'Đề thi "$examName" đã bắt đầu. Nhấn để vào thi ngay!',
      type: NotificationType.examReminder,
      time: DateTime.now(),
      teacherName: 'Hệ thống',
      isRead: false,
    );
    
    addNotification(notification);
  }

  /// Load thông báo từ SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      _notifications.clear();
      for (final json in notificationsJson) {
        // Trong thực tế sẽ parse JSON, ở đây dùng mock data
      }
      
      // Thêm mock data nếu chưa có
      if (_notifications.isEmpty) {
        _addMockNotifications();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _addMockNotifications();
    }
  }

  /// Lưu thông báo vào SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((n) => n.toString()).toList();
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Thêm mock data
  void _addMockNotifications() {
    final mockNotifications = [
      LocalNotification(
        id: 1,
        title: '📝 Đề thi mới',
        content: 'Giảng viên đã tạo đề thi "Kiểm tra giữa kỳ Lập trình C++" cho lớp Lớp C++',
        type: NotificationType.examNew,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        teacherName: 'Thầy Nguyễn Văn A',
        isRead: false,
      ),
      LocalNotification(
        id: 2,
        title: '⏰ Nhắc nhở thi',
        content: 'Đề thi "kt" sẽ bắt đầu vào lúc 01:00 ngày mai. Hãy chuẩn bị sẵn sàng!',
        type: NotificationType.examReminder,
        time: DateTime.now().subtract(const Duration(hours: 5)),
        teacherName: 'Hệ thống',
        isRead: false,
      ),
      LocalNotification(
        id: 3,
        title: '✏️ Cập nhật đề thi',
        content: 'Đề thi "kt" đã được cập nhật thời gian. Vui lòng kiểm tra lại.',
        type: NotificationType.examUpdate,
        time: DateTime.now().subtract(const Duration(days: 1)),
        teacherName: 'Thầy Nguyễn Văn A',
        isRead: true,
      ),
      LocalNotification(
        id: 4,
        title: '🎯 Kết quả thi',
        content: 'Kết quả đề thi "Kiểm tra cuối kỳ" đã có. Điểm của bạn: 8.5/10',
        type: NotificationType.examResult,
        time: DateTime.now().subtract(const Duration(days: 2)),
        teacherName: 'Thầy Nguyễn Văn A',
        isRead: true,
      ),
      LocalNotification(
        id: 5,
        title: '📢 Thông báo lớp học',
        content: 'Lịch học tuần tới sẽ thay đổi. Vui lòng xem thông tin chi tiết trong lớp học.',
        type: NotificationType.classInfo,
        time: DateTime.now().subtract(const Duration(days: 3)),
        teacherName: 'Thầy Nguyễn Văn A',
        isRead: true,
      ),
    ];
    
    _notifications.addAll(mockNotifications);
  }

  /// Dọn dẹp khi dispose
  void dispose() {
    _examReminderTimer?.cancel();
  }
}

/// Model cho thông báo local
class LocalNotification {
  final int id;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime time;
  final String teacherName;
  final bool isRead;

  LocalNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.time,
    required this.teacherName,
    required this.isRead,
  });

  LocalNotification copyWith({
    int? id,
    String? title,
    String? content,
    NotificationType? type,
    DateTime? time,
    String? teacherName,
    bool? isRead,
  }) {
    return LocalNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      time: time ?? this.time,
      teacherName: teacherName ?? this.teacherName,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Loại thông báo
enum NotificationType {
  examNew,      // Đề thi mới
  examReminder, // Nhắc nhở thi
  examUpdate,   // Cập nhật đề thi
  examResult,   // Kết quả thi
  classInfo,    // Thông báo lớp học
  system,       // Thông báo hệ thống
}

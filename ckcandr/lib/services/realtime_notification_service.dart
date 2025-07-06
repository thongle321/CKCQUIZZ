import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/views/sinhvien/widgets/realtime_notification_popup.dart';
import 'system_notification_service.dart';
import 'package:ckcandr/core/utils/timezone_helper.dart';

/// Service xử lý thông báo real-time cho sinh viên
/// Sử dụng system notifications thay vì popup trong app
class RealtimeNotificationService {
  final ApiService _apiService;
  final Ref _ref;
  Timer? _pollingTimer;
  DateTime? _lastCheckTime;
  final List<ThongBao> _pendingNotifications = [];

  // System notification service
  final SystemNotificationService _systemNotificationService = SystemNotificationService();

  RealtimeNotificationService(this._apiService, this._ref);

  /// Khởi tạo service
  Future<void> initialize() async {
    _lastCheckTime = TimezoneHelper.nowLocal();

    // Khởi tạo system notification service
    await _systemNotificationService.initialize();

    _startPolling();
    debugPrint('🔔 RealtimeNotificationService initialized');
  }

  /// Bắt đầu polling để kiểm tra thông báo mới
  void _startPolling() {
    // Server đã hoạt động trên HTTPS port 7254 - enable real polling
    debugPrint('🔔 Starting real-time notification polling (server available on HTTPS:7254)');

    // Kiểm tra ngay lập tức
    _checkForNewNotifications();

    // Polling mỗi 30 giây
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkForNewNotifications();
    });

  }

  /// Kiểm tra thông báo mới từ server
  Future<void> _checkForNewNotifications() async {
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser?.id == null) return;

      // Lấy thông báo mới từ API
      final result = await _apiService.getStudentNotifications(
        userId: currentUser!.id,
        page: 1,
        pageSize: 10,
        search: '',
      );

      // Safely extract notifications from result
      final notificationsData = result['items'];
      if (notificationsData != null && notificationsData is List) {
        final notifications = notificationsData.cast<ThongBao>();
        if (notifications.isNotEmpty) {
          final newNotifications = _filterNewNotifications(notifications);

          if (newNotifications.isNotEmpty) {
            debugPrint('🔔 Found ${newNotifications.length} new notifications');

            // Cập nhật provider
            _ref.read(studentNotificationProvider.notifier).refresh();

            // Hiển thị system notification cho thông báo mới nhất
            if (newNotifications.isNotEmpty) {
              debugPrint('🔔 Showing system notification for: ${newNotifications.first.noiDung}');
              await _systemNotificationService.showNotification(newNotifications.first);
            }

            // Cập nhật thời gian check cuối cùng
            _lastCheckTime = TimezoneHelper.nowLocal();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking for new notifications: $e');
    }
  }

  /// Lọc ra các thông báo mới
  List<ThongBao> _filterNewNotifications(List<ThongBao> notifications) {
    if (_lastCheckTime == null) {
      // Lần đầu tiên chạy, không hiển thị thông báo cũ
      return [];
    }

    return notifications.where((notification) {
      // Kiểm tra thông báo có thời gian tạo và mới hơn lần check cuối
      if (notification.thoiGianTao == null) return false;

      // Convert UTC time từ database sang local time để so sánh
      final localNotificationTime = TimezoneHelper.toLocal(notification.thoiGianTao!);
      final now = TimezoneHelper.nowLocal();

      final isNewer = localNotificationTime.isAfter(_lastCheckTime!);
      final isNotTooOld = now.difference(localNotificationTime).inHours < 24; // Chỉ thông báo trong 24h

      return isNewer && isNotTooOld;
    }).toList();
  }

  /// Hiển thị notification popup
  void showNotificationPopup(BuildContext context, ThongBao notification) {
    if (!context.mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => RealtimeNotificationPopup(
          notification: notification,
          onActionPressed: () => _handleNotificationAction(context, notification),
          onDismiss: () => _markNotificationAsShown(notification),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing notification popup: $e');
    }
  }

  /// Đánh dấu thông báo đã được hiển thị
  void _markNotificationAsShown(ThongBao notification) {
    if (notification.maTb != null) {
      markAsRead(notification.maTb!);
    }
  }

  /// Xử lý khi người dùng click vào action button
  void _handleNotificationAction(BuildContext context, ThongBao notification) {
    try {
      // Đóng popup trước
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Đánh dấu thông báo đã đọc
      if (notification.maTb != null) {
        markAsRead(notification.maTb!);
      }

      // Điều hướng dựa trên loại thông báo
      if (notification.isExamNotification && notification.examId != null) {
        // Điều hướng đến bài thi cụ thể
        _navigateToExam(context, notification.examId!);
      } else if (notification.isExamNotification) {
        // Thông báo bài thi nhưng không có examId -> đến tab bài kiểm tra
        _navigateToExamsList(context);
      } else {
        // Thông báo thường -> đến tab thông báo
        _navigateToNotifications(context);
      }
    } catch (e) {
      debugPrint('❌ Error handling notification action: $e');
    }
  }

  /// Điều hướng đến bài thi
  void _navigateToExam(BuildContext context, int examId) {
    try {
      // Điều hướng đến route bài thi cụ thể nếu có
      context.go('/sinhvien/exam/$examId');
      debugPrint('🎯 Navigate to exam: $examId');
    } catch (e) {
      // Fallback: điều hướng đến tab bài kiểm tra
      debugPrint('⚠️ Failed to navigate to specific exam, fallback to exams tab');
      _navigateToExamsList(context);
    }
  }

  /// Điều hướng đến danh sách bài thi
  void _navigateToExamsList(BuildContext context) {
    try {
      // Điều hướng đến tab bài kiểm tra trong dashboard (tab index 2)
      context.go('/sinhvien/dashboard?tab=2');
      debugPrint('🎯 Navigate to exams list');
    } catch (e) {
      debugPrint('❌ Error navigating to exams list: $e');
    }
  }

  /// Điều hướng đến màn hình thông báo
  void _navigateToNotifications(BuildContext context) {
    try {
      // Điều hướng đến tab thông báo trong dashboard (tab index 3)
      context.go('/sinhvien/dashboard?tab=3');
      debugPrint('🎯 Navigate to notifications');
    } catch (e) {
      debugPrint('❌ Error navigating to notifications: $e');
    }
  }

  /// Tạm dừng service
  void pause() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('⏸️ RealtimeNotificationService paused');
  }

  /// Tiếp tục service
  void resume() {
    if (_pollingTimer == null) {
      _startPolling();
      debugPrint('▶️ RealtimeNotificationService resumed');
    }
  }

  /// Dừng service hoàn toàn
  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pendingNotifications.clear();
    _systemNotificationService.dispose();
    debugPrint('🔔 RealtimeNotificationService disposed');
  }

  /// Force check for new notifications
  Future<void> forceCheck() async {
    await _checkForNewNotifications();
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(int notificationId) async {
    try {
      await _ref.read(studentNotificationProvider.notifier).markAsRead(notificationId);
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }
}

/// Provider cho RealtimeNotificationService
final realtimeNotificationServiceProvider = Provider<RealtimeNotificationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final service = RealtimeNotificationService(apiService, ref);

  // Tự động dispose khi provider bị hủy
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider để quản lý trạng thái notification badge
final notificationBadgeProvider = StateProvider<int>((ref) => 0);

/// Provider để quản lý việc hiển thị notification popup
final showNotificationPopupProvider = StateProvider<ThongBao?>((ref) => null);

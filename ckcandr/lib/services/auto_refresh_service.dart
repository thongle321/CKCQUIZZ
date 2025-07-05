import 'dart:async';
import 'package:flutter/material.dart';

/// Service quản lý auto-refresh cho các màn hình khác nhau
/// - Giáo viên: Refresh câu hỏi và đề thi mỗi 30s
/// - Học sinh: Refresh bài thi mỗi 30s (trừ khi đang làm bài)
/// - Admin: Refresh quyền và phân công mỗi 30s
class AutoRefreshService {
  static final AutoRefreshService _instance = AutoRefreshService._internal();
  factory AutoRefreshService() => _instance;
  AutoRefreshService._internal();

  final Map<String, Timer> _timers = {};
  final Map<String, VoidCallback> _callbacks = {};

  /// Bắt đầu auto-refresh cho một màn hình
  /// [key] - Unique key cho màn hình (vd: 'teacher_questions', 'student_exams')
  /// [callback] - Function sẽ được gọi mỗi 30s
  /// [intervalSeconds] - Khoảng thời gian refresh (mặc định 30s)
  void startAutoRefresh({
    required String key,
    required VoidCallback callback,
    int intervalSeconds = 30,
  }) {
    // Dừng timer cũ nếu có
    stopAutoRefresh(key);

    debugPrint('🔄 Starting auto-refresh for $key (every ${intervalSeconds}s)');
    
    // Lưu callback
    _callbacks[key] = callback;
    
    // Tạo timer mới
    _timers[key] = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) {
        debugPrint('🔄 Auto-refreshing $key');
        callback();
      },
    );
  }

  /// Dừng auto-refresh cho một màn hình
  void stopAutoRefresh(String key) {
    final timer = _timers[key];
    if (timer != null) {
      debugPrint('⏹️ Stopping auto-refresh for $key');
      timer.cancel();
      _timers.remove(key);
      _callbacks.remove(key);
    }
  }

  /// Tạm dừng auto-refresh cho một màn hình
  void pauseAutoRefresh(String key) {
    final timer = _timers[key];
    if (timer != null) {
      debugPrint('⏸️ Pausing auto-refresh for $key');
      timer.cancel();
      _timers.remove(key);
      // Giữ callback để có thể resume
    }
  }

  /// Tiếp tục auto-refresh cho một màn hình đã bị pause
  void resumeAutoRefresh(String key, {int intervalSeconds = 30}) {
    final callback = _callbacks[key];
    if (callback != null && !_timers.containsKey(key)) {
      debugPrint('▶️ Resuming auto-refresh for $key');
      _timers[key] = Timer.periodic(
        Duration(seconds: intervalSeconds),
        (timer) {
          debugPrint('🔄 Auto-refreshing $key');
          callback();
        },
      );
    }
  }

  /// Kiểm tra xem một màn hình có đang auto-refresh không
  bool isAutoRefreshing(String key) {
    return _timers.containsKey(key) && _timers[key]!.isActive;
  }

  /// Dừng tất cả auto-refresh
  void stopAllAutoRefresh() {
    debugPrint('⏹️ Stopping all auto-refresh');
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _callbacks.clear();
  }

  /// Lấy danh sách các màn hình đang auto-refresh
  List<String> getActiveRefreshKeys() {
    return _timers.keys.where((key) => _timers[key]!.isActive).toList();
  }

  /// Dispose service
  void dispose() {
    stopAllAutoRefresh();
  }
}

/// Mixin để dễ dàng sử dụng auto-refresh trong các widget
mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  final AutoRefreshService _autoRefreshService = AutoRefreshService();
  
  /// Key unique cho màn hình này
  String get autoRefreshKey;
  
  /// Callback sẽ được gọi khi auto-refresh
  void onAutoRefresh();
  
  /// Có nên auto-refresh không (mặc định true)
  bool get shouldAutoRefresh => true;
  
  /// Khoảng thời gian refresh (mặc định 30s)
  int get refreshIntervalSeconds => 30;

  @override
  void initState() {
    super.initState();
    if (shouldAutoRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startAutoRefresh();
      });
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  /// Bắt đầu auto-refresh
  void startAutoRefresh() {
    if (shouldAutoRefresh) {
      _autoRefreshService.startAutoRefresh(
        key: autoRefreshKey,
        callback: onAutoRefresh,
        intervalSeconds: refreshIntervalSeconds,
      );
    }
  }

  /// Dừng auto-refresh
  void stopAutoRefresh() {
    _autoRefreshService.stopAutoRefresh(autoRefreshKey);
  }

  /// Tạm dừng auto-refresh
  void pauseAutoRefresh() {
    _autoRefreshService.pauseAutoRefresh(autoRefreshKey);
  }

  /// Tiếp tục auto-refresh
  void resumeAutoRefresh() {
    if (shouldAutoRefresh) {
      _autoRefreshService.resumeAutoRefresh(
        autoRefreshKey,
        intervalSeconds: refreshIntervalSeconds,
      );
    }
  }

  /// Kiểm tra xem có đang auto-refresh không
  bool get isAutoRefreshing => _autoRefreshService.isAutoRefreshing(autoRefreshKey);
}

/// Constants cho các auto-refresh keys
class AutoRefreshKeys {
  // Giáo viên
  static const String teacherQuestions = 'teacher_questions';
  static const String teacherExams = 'teacher_exams';
  static const String teacherExamResults = 'teacher_exam_results';
  
  // Học sinh
  static const String studentExams = 'student_exams';
  static const String studentNotifications = 'student_notifications';
  
  // Admin
  static const String adminPermissions = 'admin_permissions';
  static const String adminAssignments = 'admin_assignments';
  static const String adminUsers = 'admin_users';
  static const String adminSubjects = 'admin_subjects';
}

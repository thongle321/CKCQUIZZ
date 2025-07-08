import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';

/// Service quản lý auto-refresh cho các màn hình khác nhau với ngoại lệ theo role
/// - Admin: Refresh user, phân công, lớp, môn học
/// - Giáo viên: Refresh lớp, câu hỏi, đề thi
/// - Sinh viên: Refresh lớp và bài kiểm tra
class AutoRefreshService {
  static final AutoRefreshService _instance = AutoRefreshService._internal();
  factory AutoRefreshService() => _instance;
  AutoRefreshService._internal();

  final Map<String, Timer> _timers = {};
  final Map<String, VoidCallback> _callbacks = {};

  // Ngoại lệ refresh theo role và màn hình
  static final Map<UserRole, Set<String>> _roleRefreshExceptions = {
    UserRole.admin: {
      AutoRefreshKeys.adminUsers,
      AutoRefreshKeys.adminAssignments,
      AutoRefreshKeys.adminClasses,
      AutoRefreshKeys.adminSubjects,
      AutoRefreshKeys.adminPermissions,
    },
    UserRole.giangVien: {
      AutoRefreshKeys.teacherClasses,
      AutoRefreshKeys.teacherQuestions,
      AutoRefreshKeys.teacherExams,
      AutoRefreshKeys.teacherExamResults,
    },
    UserRole.sinhVien: {
      AutoRefreshKeys.studentClasses,
      AutoRefreshKeys.studentExams,
      AutoRefreshKeys.studentNotifications,
    },
  };

  // Màn hình bị cấm auto-refresh (ví dụ: đang làm bài thi)
  static final Set<String> _globalBlacklist = {
    AutoRefreshKeys.examTaking,
    AutoRefreshKeys.examSubmitting,
  };

  /// Kiểm tra xem có được phép auto-refresh không theo role và màn hình
  bool _canAutoRefresh(String key, UserRole? userRole) {
    // Kiểm tra blacklist toàn cục trước
    if (_globalBlacklist.contains(key)) {
      debugPrint('🚫 Auto-refresh blocked (global blacklist): $key');
      return false;
    }

    // Nếu không có role, cho phép refresh
    if (userRole == null) return true;

    // Kiểm tra ngoại lệ theo role
    final allowedKeys = _roleRefreshExceptions[userRole] ?? <String>{};

    if (allowedKeys.isEmpty) {
      debugPrint('🚫 No refresh permissions for role: $userRole');
      return false;
    }

    final canRefresh = allowedKeys.contains(key);
    if (!canRefresh) {
      debugPrint('🚫 Auto-refresh not allowed for $userRole: $key');
      debugPrint('   Allowed keys: ${allowedKeys.join(', ')}');
    }

    return canRefresh;
  }

  /// Bắt đầu auto-refresh cho một màn hình với kiểm tra ngoại lệ
  /// [key] - Unique key cho màn hình
  /// [callback] - Function sẽ được gọi mỗi 30s
  /// [userRole] - Role của user hiện tại để kiểm tra quyền
  /// [intervalSeconds] - Khoảng thời gian refresh (mặc định 30s)
  void startAutoRefresh({
    required String key,
    required VoidCallback callback,
    UserRole? userRole,
    int intervalSeconds = 30,
  }) {
    // Kiểm tra quyền refresh trước
    if (!_canAutoRefresh(key, userRole)) {
      return;
    }

    // Dừng timer cũ nếu có
    stopAutoRefresh(key);

    debugPrint('✅ Starting auto-refresh for $key (role: $userRole, every ${intervalSeconds}s)');

    // Lưu callback
    _callbacks[key] = callback;

    // Tạo timer mới
    _timers[key] = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) {
        // Kiểm tra lại quyền trước khi refresh (có thể role đã thay đổi)
        if (_canAutoRefresh(key, userRole)) {
          debugPrint('🔄 Auto-refreshing $key');
          callback();
        } else {
          debugPrint('🚫 Auto-refresh permission revoked for $key, stopping...');
          stopAutoRefresh(key);
        }
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

  /// Thêm key vào blacklist toàn cục
  static void addToGlobalBlacklist(String key) {
    _globalBlacklist.add(key);
    debugPrint('🚫 Added to global blacklist: $key');
  }

  /// Xóa key khỏi blacklist toàn cục
  static void removeFromGlobalBlacklist(String key) {
    _globalBlacklist.remove(key);
    debugPrint('✅ Removed from global blacklist: $key');
  }

  /// Kiểm tra key có trong blacklist không
  static bool isInGlobalBlacklist(String key) {
    return _globalBlacklist.contains(key);
  }

  /// Lấy danh sách key được phép refresh theo role
  static Set<String> getAllowedKeysForRole(UserRole role) {
    return _roleRefreshExceptions[role] ?? <String>{};
  }

  /// Kiểm tra xem role có được phép refresh key này không
  static bool isKeyAllowedForRole(String key, UserRole role) {
    final allowedKeys = _roleRefreshExceptions[role] ?? <String>{};
    return allowedKeys.contains(key);
  }

  /// In thông tin debug về quyền refresh
  void printRefreshPermissions(UserRole? role) {
    debugPrint('🔍 Auto-refresh permissions:');
    debugPrint('   Current role: $role');
    debugPrint('   Global blacklist: ${_globalBlacklist.join(', ')}');
    if (role != null) {
      final allowed = _roleRefreshExceptions[role] ?? <String>{};
      debugPrint('   Allowed for $role: ${allowed.join(', ')}');
    }
    debugPrint('   Currently active: ${getActiveRefreshKeys().join(', ')}');
  }

  /// Dispose service
  void dispose() {
    stopAllAutoRefresh();
  }
}

/// Mixin để dễ dàng sử dụng auto-refresh trong các widget với role checking
mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  final AutoRefreshService _autoRefreshService = AutoRefreshService();

  /// Key unique cho màn hình này
  String get autoRefreshKey;

  /// Callback sẽ được gọi khi auto-refresh
  void onAutoRefresh();

  /// Role của user hiện tại (cần implement trong widget)
  UserRole? get currentUserRole => null;

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

  /// Bắt đầu auto-refresh với role checking
  void startAutoRefresh() {
    if (shouldAutoRefresh) {
      _autoRefreshService.startAutoRefresh(
        key: autoRefreshKey,
        callback: onAutoRefresh,
        userRole: currentUserRole,
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

/// Constants cho các auto-refresh keys theo role và chức năng
class AutoRefreshKeys {
  // Admin - Quản lý hệ thống
  static const String adminUsers = 'admin_users';              // Quản lý người dùng
  static const String adminAssignments = 'admin_assignments';  // Phân công giảng dạy
  static const String adminClasses = 'admin_classes';          // Quản lý lớp học
  static const String adminSubjects = 'admin_subjects';        // Quản lý môn học
  static const String adminPermissions = 'admin_permissions';  // Quản lý quyền
  static const String adminNotifications = 'admin_notifications'; // Thông báo admin

  // Giảng viên - Giảng dạy và thi cử
  static const String teacherClasses = 'teacher_classes';      // Lớp học được phân công
  static const String teacherQuestions = 'teacher_questions';  // Ngân hàng câu hỏi
  static const String teacherExams = 'teacher_exams';          // Đề thi đã tạo
  static const String teacherExamResults = 'teacher_exam_results'; // Kết quả thi
  static const String teacherSubjects = 'teacher_subjects';    // Môn học được phân công

  // Sinh viên - Học tập và thi cử
  static const String studentClasses = 'student_classes';      // Lớp học đã đăng ký
  static const String studentExams = 'student_exams';          // Bài kiểm tra khả dụng
  static const String studentNotifications = 'student_notifications'; // Thông báo sinh viên
  static const String studentResults = 'student_results';      // Kết quả thi của sinh viên

  // Màn hình đặc biệt - Bị cấm auto-refresh
  static const String examTaking = 'exam_taking';              // Đang làm bài thi
  static const String examSubmitting = 'exam_submitting';      // Đang nộp bài
  static const String formEditing = 'form_editing';            // Đang chỉnh sửa form
  static const String settingsScreen = 'settings_screen';     // Màn hình cài đặt
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/user_provider.dart';

/// Provider cho quản lý thông báo sinh viên với state management chuyên nghiệp
/// Hỗ trợ auto-refresh, local storage cho trạng thái đã đọc, và real-time updates

/// State class cho notifications với pagination support như Vue.js
@immutable
class NotificationState {
  final List<ThongBao> notifications;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final int unreadCount;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final String? searchQuery;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalCount = 0,
    this.searchQuery,
  });

  NotificationState copyWith({
    List<ThongBao>? notifications,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    int? unreadCount,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    String? searchQuery,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationState &&
        other.notifications == notifications &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.lastUpdated == lastUpdated &&
        other.unreadCount == unreadCount &&
        other.currentPage == currentPage &&
        other.pageSize == pageSize &&
        other.totalCount == totalCount &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return Object.hash(
      notifications,
      isLoading,
      error,
      lastUpdated,
      unreadCount,
      currentPage,
      pageSize,
      totalCount,
      searchQuery,
    );
  }
}

/// Notifier cho quản lý thông báo sinh viên
class StudentNotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _apiService;
  final Ref _ref;
  Timer? _refreshTimer;
  static const String _readNotificationsKey = 'read_notifications';

  StudentNotificationNotifier(this._apiService, this._ref) : super(const NotificationState()) {
    _initializeNotifications();
    _startAutoRefresh();
  }

  /// khởi tạo và load thông báo lần đầu
  Future<void> _initializeNotifications() async {
    await loadNotifications();
  }

  /// bắt đầu auto-refresh mỗi 30 giây
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!state.isLoading) {
        loadNotifications(showLoading: false);
      }
    });
  }

  /// load thông báo từ API
  Future<void> loadNotifications({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // lấy user ID từ current user
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser?.id == null) {
        state = state.copyWith(
          notifications: [],
          isLoading: false,
          error: null,
          lastUpdated: DateTime.now(),
          unreadCount: 0,
        );
        return;
      }

      // lấy thông báo từ API với pagination như Vue.js
      final result = await _apiService.getStudentNotifications(
        userId: currentUser!.id,
        page: state.currentPage,
        pageSize: state.pageSize,
        search: state.searchQuery,
      );

      final notifications = result['items'] as List<ThongBao>;
      final totalCount = result['totalCount'] as int;

      // load trạng thái đã đọc từ local storage
      final readNotificationIds = await _getReadNotificationIds();

      // cập nhật trạng thái đã đọc cho từng thông báo
      final updatedNotifications = notifications.map((notification) {
        final isRead = readNotificationIds.contains(notification.maTb);
        return notification.copyWith(isRead: isRead);
      }).toList();

      // sắp xếp theo thời gian tạo (mới nhất trước)
      updatedNotifications.sort((a, b) {
        if (a.thoiGianTao == null && b.thoiGianTao == null) return 0;
        if (a.thoiGianTao == null) return 1;
        if (b.thoiGianTao == null) return -1;
        return b.thoiGianTao!.compareTo(a.thoiGianTao!);
      });

      // tính số thông báo chưa đọc
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
        unreadCount: unreadCount,
        totalCount: totalCount,
      );

    } catch (e) {

      // xử lý lỗi chi tiết
      String errorMessage;
      if (e.toString().contains('User not authenticated')) {
        errorMessage = 'Vui lòng đăng nhập lại';
      } else if (e.toString().contains('No internet connection')) {
        errorMessage = 'Không có kết nối internet';
      } else if (e.toString().contains('Failed to get student notifications')) {
        errorMessage = 'Không thể tải thông báo từ server';
      } else {
        errorMessage = 'Có lỗi xảy ra khi tải thông báo';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// đánh dấu thông báo đã đọc
  Future<void> markAsRead(int notificationId) async {
    try {
      // cập nhật local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.maTb == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      // tính lại số chưa đọc
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );

      // lưu vào local storage
      await _saveReadNotificationId(notificationId);

      // gọi API để đánh dấu đã đọc (nếu backend hỗ trợ)
      await _apiService.markNotificationAsRead(notificationId);

      debugPrint('✅ Marked notification $notificationId as read');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    try {
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // lưu tất cả ID vào local storage
      final allIds = state.notifications
          .where((n) => n.maTb != null)
          .map((n) => n.maTb!)
          .toList();
      
      for (final id in allIds) {
        await _saveReadNotificationId(id);
      }

      debugPrint('✅ Marked all notifications as read');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// refresh thông báo thủ công với retry
  Future<void> refresh() async {
    await loadNotifications();
  }

  /// search thông báo như Vue.js
  Future<void> searchNotifications(String? query) async {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1, // reset về trang đầu khi search
    );
    await loadNotifications(showLoading: true);
  }

  /// chuyển trang như Vue.js
  Future<void> changePage(int page, {int? pageSize}) async {
    state = state.copyWith(
      currentPage: page,
      pageSize: pageSize ?? state.pageSize,
    );
    await loadNotifications(showLoading: true);
  }

  /// clear search
  Future<void> clearSearch() async {
    if (state.searchQuery != null) {
      await searchNotifications(null);
    }
  }

  /// retry load notifications với exponential backoff
  Future<void> retryLoadNotifications({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await loadNotifications();
        return; // thành công, thoát khỏi loop
      } catch (e) {
        if (attempt == maxRetries) {
          // đã hết số lần retry
          rethrow;
        }

        // đợi trước khi retry (exponential backoff)
        final delaySeconds = attempt * 2;
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
  }

  /// lấy danh sách ID thông báo đã đọc từ local storage
  Future<Set<int>> _getReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(_readNotificationsKey) ?? [];
      return readIds.map((id) => int.parse(id)).toSet();
    } catch (e) {
      debugPrint('❌ Error getting read notification IDs: $e');
      return <int>{};
    }
  }

  /// lưu ID thông báo đã đọc vào local storage
  Future<void> _saveReadNotificationId(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(_readNotificationsKey) ?? [];
      if (!readIds.contains(notificationId.toString())) {
        readIds.add(notificationId.toString());
        await prefs.setStringList(_readNotificationsKey, readIds);
      }
    } catch (e) {
      // Silently handle error
    }
  }

  /// lấy thông báo theo ID
  ThongBao? getNotificationById(int id) {
    try {
      return state.notifications.firstWhere((n) => n.maTb == id);
    } catch (e) {
      return null;
    }
  }

  /// lấy thông báo có thể vào thi
  List<ThongBao> get examNotifications {
    return state.notifications.where((n) => n.isExamNotification).toList();
  }

  /// lấy thông báo có thể vào thi ngay bây giờ
  List<ThongBao> get availableExams {
    return state.notifications.where((n) => n.canTakeExam).toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Provider chính cho thông báo sinh viên
final studentNotificationProvider = StateNotifierProvider<StudentNotificationNotifier, NotificationState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return StudentNotificationNotifier(apiService, ref);
});

/// Provider cho số lượng thông báo chưa đọc
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(studentNotificationProvider);
  return notificationState.unreadCount;
});

/// Provider cho thông báo có thể vào thi
final availableExamsProvider = Provider<List<ThongBao>>((ref) {
  final notifier = ref.watch(studentNotificationProvider.notifier);
  return notifier.availableExams;
});

/// Provider cho việc kiểm tra có thông báo mới không
final hasNewNotificationsProvider = Provider<bool>((ref) {
  final notificationState = ref.watch(studentNotificationProvider);
  return notificationState.unreadCount > 0;
});

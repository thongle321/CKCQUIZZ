import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/de_thi_provider.dart';
import 'package:ckcandr/providers/student_notification_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/de_kiem_tra_provider.dart';
import 'package:ckcandr/providers/api_user_provider.dart';
import 'package:ckcandr/providers/dashboard_provider.dart';

/// Service quản lý auto-refresh toàn bộ app sau khi login
/// Refresh tất cả data mỗi 30 giây
class GlobalAutoRefreshService {
  static final GlobalAutoRefreshService _instance = GlobalAutoRefreshService._internal();
  factory GlobalAutoRefreshService() => _instance;
  GlobalAutoRefreshService._internal();

  Timer? _globalRefreshTimer;
  WidgetRef? _ref;
  bool _isLoggedIn = false;

  /// Khởi tạo service với ref
  void initialize(WidgetRef ref) {
    if (_ref != null) {
      debugPrint('🌐 GlobalAutoRefreshService already initialized, skipping...');
      return;
    }
    _ref = ref;
    debugPrint('🌐 GlobalAutoRefreshService initialized');
  }

  /// Bắt đầu auto-refresh sau khi login thành công
  void startGlobalAutoRefresh() {
    if (_globalRefreshTimer != null) {
      _globalRefreshTimer!.cancel();
    }

    _isLoggedIn = true;
    debugPrint('🌐 Starting global auto-refresh every 30 seconds');

    // Refresh ngay lập tức
    _refreshAllData();

    // Sau đó refresh mỗi 30 giây
    _globalRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isLoggedIn && _ref != null) {
        _refreshAllData();
      }
    });
  }

  /// Dừng auto-refresh khi logout
  void stopGlobalAutoRefresh() {
    _globalRefreshTimer?.cancel();
    _globalRefreshTimer = null;
    _isLoggedIn = false;
    _ref = null; // Reset ref để tránh lỗi type cast
    debugPrint('🌐 Global auto-refresh stopped');
  }

  /// Refresh tất cả data trong app
  void _refreshAllData() {
    if (_ref == null) return;

    try {
      debugPrint('🔄 Global auto-refresh: Refreshing all data...');

      // Refresh user data
      _ref!.invalidate(currentUserProvider);
      _ref!.invalidate(apiUserProvider);

      // Refresh class data
      _ref!.invalidate(lopHocListProvider);

      // Refresh exam data
      _ref!.invalidate(deThiListProvider);

      // Refresh notification data
      _ref!.read(studentNotificationProvider.notifier).refresh();

      // Refresh subject data
      _ref!.invalidate(monHocListProvider);
      _ref!.invalidate(monHocProvider);

      // Refresh group data
      _ref!.invalidate(nhomHocPhanListProvider);

      // Refresh test data
      _ref!.invalidate(deKiemTraListProvider);

      // Refresh dashboard data
      refreshDashboard(_ref!);

      debugPrint('✅ Global auto-refresh completed');
    } catch (e) {
      debugPrint('❌ Error during global auto-refresh: $e');
    }
  }

  /// Force refresh ngay lập tức
  void forceRefresh() {
    if (_ref != null && _isLoggedIn) {
      _refreshAllData();
    }
  }

  /// Kiểm tra trạng thái auto-refresh
  bool get isActive => _globalRefreshTimer != null && _globalRefreshTimer!.isActive;

  /// Dispose service
  void dispose() {
    stopGlobalAutoRefresh();
    _ref = null;
    debugPrint('🌐 GlobalAutoRefreshService disposed');
  }
}

/// Provider cho GlobalAutoRefreshService
final globalAutoRefreshServiceProvider = Provider<GlobalAutoRefreshService>((ref) {
  final service = GlobalAutoRefreshService();
  // KHÔNG INITIALIZE REF Ở ĐÂY VÌ SẼ GÂY LỖI TYPE CAST
  // service.initialize(ref as WidgetRef);

  // Auto dispose khi provider bị hủy
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider để theo dõi trạng thái auto-refresh
final globalAutoRefreshStateProvider = StateProvider<bool>((ref) => false);

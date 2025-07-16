/// SignalR Service for real-time exam monitoring
/// Matches Vue.js signalRDeThiService.js implementation exactly
///
/// NOTE: This is a mock implementation until SignalR package is properly configured

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Match Vue.js ExamStatusUpdate event
class ExamStatusUpdate {
  final int examId;
  final String newStatus;

  ExamStatusUpdate({required this.examId, required this.newStatus});
}

/// Match Vue.js ExamNotification event
class ExamNotification {
  final String message;
  final List<int> classIds;

  ExamNotification({required this.message, required this.classIds});
}

class SignalRService {
  static SignalRService? _instance;
  static SignalRService get instance => _instance ??= SignalRService._();

  SignalRService._();

  // Match Vue.js connection state
  bool _isConnected = false;

  // Match Vue.js signalRConnection
  dynamic _signalRConnection; // Mock connection object

  // Stream controllers for real-time events - Match Vue.js events
  final _tabSwitchWarningController = StreamController<TabSwitchWarning>.broadcast();
  final _autoSubmitCommandController = StreamController<String>.broadcast();
  final _examStatusUpdateController = StreamController<ExamStatusUpdate>.broadcast();
  final _examNotificationController = StreamController<ExamNotification>.broadcast();

  // Public streams - Match Vue.js event listeners
  Stream<TabSwitchWarning> get tabSwitchWarningStream => _tabSwitchWarningController.stream;
  Stream<String> get autoSubmitCommandStream => _autoSubmitCommandController.stream;
  Stream<ExamStatusUpdate> get examStatusUpdateStream => _examStatusUpdateController.stream;
  Stream<ExamNotification> get examNotificationStream => _examNotificationController.stream;

  /// Initialize SignalR connections - Match Vue.js startConnection
  Future<void> initialize(String accessToken) async {
    if (accessToken.isEmpty) {
      debugPrint('❌ SignalR: Cannot initialize - no access token');
      return;
    }

    try {
      // Mock initialization - Match Vue.js startConnection
      await Future.delayed(const Duration(milliseconds: 100));
      _isConnected = true;
      debugPrint('✅ SignalR: Mock initialization successful');

      // Setup mock event listeners - Match Vue.js setupSignalRListeners
      _setupMockEventListeners();

      // Start mock events for testing
      _startMockEvents();
    } catch (e) {
      debugPrint('❌ SignalR: Mock initialization failed: $e');
    }
  }

  /// Send tab switch warning to server - Match Vue.js canhBaoChuyenTab
  Future<void> sendTabSwitchWarning(int ketQuaId) async {
    if (!_isConnected) {
      debugPrint('❌ SignalR: Cannot send tab switch warning - not connected');
      return;
    }

    try {
      // Mock sending - in real implementation this would call SignalR hub
      debugPrint('📤 SignalR: Mock tab switch warning sent for ketQuaId: $ketQuaId');

      // Simulate server response after a delay
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock response - this would normally come from server
      // For now, we'll just log that it was sent
      debugPrint('✅ SignalR: Mock tab switch warning processed');
    } catch (e) {
      debugPrint('❌ SignalR: Failed to send tab switch warning: $e');
    }
  }

  /// Setup mock event listeners - Match Vue.js setupSignalRListeners
  void _setupMockEventListeners() {
    // Mock Vue.js: signalRConnection.on('ReceiveTabSwitchWarning', handleCanhBaoChuyenTab);
    // Mock Vue.js: signalRConnection.on('ReceiveAutoSubmitCommand', handleAutoSubmitCommand);
    debugPrint('📡 SignalR: Mock event listeners setup completed');
  }

  /// Start mock events for testing - Simulate real SignalR events
  void _startMockEvents() {
    // Mock exam notification every 2 minutes for testing
    Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isConnected) {
        _examNotificationController.add(ExamNotification(
          message: 'Có đề thi mới: Kiểm tra giữa kỳ Toán học',
          classIds: [1, 2, 3],
        ));
        debugPrint('📨 Mock: Sent exam notification');
      } else {
        timer.cancel();
      }
    });

    // Mock exam status update every 3 minutes for testing
    Timer.periodic(const Duration(minutes: 3), (timer) {
      if (_isConnected) {
        _examStatusUpdateController.add(ExamStatusUpdate(
          examId: 123,
          newStatus: 'DangDienRa',
        ));
        debugPrint('📨 Mock: Sent exam status update');
      } else {
        timer.cancel();
      }
    });
  }

  /// Check if connected - Match Vue.js signalRConnection state
  bool get isConnected => _isConnected;

  /// Dispose resources - Match Vue.js cleanupSignalRListeners
  Future<void> dispose() async {
    try {
      await _tabSwitchWarningController.close();
      await _autoSubmitCommandController.close();
      await _examStatusUpdateController.close();
      await _examNotificationController.close();

      _isConnected = false;

      debugPrint('✅ SignalR: Mock disposal completed');
    } catch (e) {
      debugPrint('❌ SignalR: Error during disposal: $e');
    }
  }
}

/// Model for tab switch warning
class TabSwitchWarning {
  final int soLanHienTai;
  final int gioiHan;
  final bool nopBai;
  final String thongBao;

  TabSwitchWarning({
    required this.soLanHienTai,
    required this.gioiHan,
    required this.nopBai,
    required this.thongBao,
  });

  factory TabSwitchWarning.fromJson(Map<String, dynamic> json) {
    return TabSwitchWarning(
      soLanHienTai: json['soLanHienTai'] ?? 0,
      gioiHan: json['gioiHan'] ?? 5,
      nopBai: json['nopBai'] ?? false,
      thongBao: json['thongBao'] ?? '',
    );
  }
}

/// Model for exam monitoring events
class ExamMonitoringEvent {
  final String type;
  final Map<String, dynamic> data;

  ExamMonitoringEvent({
    required this.type,
    required this.data,
  });
}

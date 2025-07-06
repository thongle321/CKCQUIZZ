import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../models/thong_bao_model.dart';

/// Service để hiển thị system notifications thay vì popup trong app
class SystemNotificationService {
  static final SystemNotificationService _instance = SystemNotificationService._internal();
  factory SystemNotificationService() => _instance;
  SystemNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Navigation context để có thể navigate khi tap notification
  static BuildContext? _navigationContext;

  /// Set navigation context
  static void setNavigationContext(BuildContext context) {
    _navigationContext = context;
  }

  /// Khởi tạo service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for Android 13+
      final bool permissionGranted = await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ System notification service initialized. Permission granted: $permissionGranted');
    } catch (e) {
      debugPrint('❌ Error initializing system notifications: $e');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      debugPrint('📱 Android notification permission granted: $granted');

      // Tạo notification channel cho Android
      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'exam_notifications',
          'Thông báo bài thi',
          description: 'Thông báo về bài thi và hoạt động học tập',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      // Tạo notification channel cho thông báo chung
      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'general_notifications',
          'Thông báo chung',
          description: 'Thông báo chung từ hệ thống',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final bool? granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('📱 iOS notification permission granted: $granted');
      return granted ?? false;
    }
    return false;
  }

  /// Hiển thị notification cho thông báo từ server
  Future<void> showNotification(ThongBao notification) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final String channelId = notification.isExamNotification
          ? 'exam_notifications'
          : 'general_notifications';
      final String channelName = notification.isExamNotification
          ? 'Thông báo bài thi'
          : 'Thông báo chung';

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: notification.isExamNotification
            ? 'Thông báo về bài thi và hoạt động học tập'
            : 'Thông báo chung từ hệ thống',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: const Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
        autoCancel: false, // Không tự động ẩn
        ongoing: false,
        when: notification.thoiGianTao?.millisecondsSinceEpoch,
        styleInformation: BigTextStyleInformation(
          notification.noiDung,
          contentTitle: _getNotificationTitle(notification),
        ),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.maTb ?? DateTime.now().millisecondsSinceEpoch,
        _getNotificationTitle(notification),
        notification.noiDung,
        platformChannelSpecifics,
        payload: notification.maTb?.toString(),
      );

      debugPrint('📱 System notification shown: ${notification.noiDung}');
    } catch (e) {
      debugPrint('❌ Error showing system notification: $e');
    }
  }

  /// Hiển thị notification cho exam reminder
  Future<void> showExamReminder({
    required String examName,
    required String timeRemaining,
    int? examId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'exam_reminders',
        'Nhắc nhở bài thi',
        channelDescription: 'Nhắc nhở về thời gian bài thi sắp diễn ra',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF2196F3),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        examId ?? DateTime.now().millisecondsSinceEpoch,
        '⏰ Sắp đến giờ thi',
        'Đề thi "$examName" sẽ bắt đầu trong $timeRemaining',
        platformChannelSpecifics,
        payload: examId?.toString(),
      );

      debugPrint('📱 Exam reminder notification shown: $examName - $timeRemaining');
    } catch (e) {
      debugPrint('❌ Error showing exam reminder notification: $e');
    }
  }

  /// Hiển thị notification khi đến giờ thi
  Future<void> showExamStartNotification({
    required String examName,
    int? examId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'exam_start',
        'Bắt đầu bài thi',
        channelDescription: 'Thông báo khi bài thi bắt đầu',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFF5722),
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        examId ?? DateTime.now().millisecondsSinceEpoch,
        '🚨 Đã đến giờ thi!',
        'Đề thi "$examName" đã bắt đầu. Nhấn để vào thi ngay!',
        platformChannelSpecifics,
        payload: examId?.toString(),
      );

      debugPrint('📱 Exam start notification shown: $examName');
    } catch (e) {
      debugPrint('❌ Error showing exam start notification: $e');
    }
  }

  /// Hiển thị notification đơn giản
  Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general_notifications',
    String channelName = 'Thông báo chung',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Thông báo chung từ hệ thống',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: const Color(0xFF2196F3),
        autoCancel: false,
        ongoing: false,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      debugPrint('✅ Simple notification displayed: $title');
    } catch (e) {
      debugPrint('❌ Error showing simple notification: $e');
    }
  }

  /// Test notification để kiểm tra hoạt động
  Future<void> showTestNotification() async {
    await showSimpleNotification(
      title: '🧪 Test Notification',
      body: 'Đây là thông báo test để kiểm tra hệ thống notification có hoạt động không. Tap để mở app.',
      payload: 'test',
    );
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    debugPrint('📱 Notification tapped with payload: $payload');

    // Navigate to notifications screen
    if (_navigationContext != null && _navigationContext!.mounted) {
      try {
        // Navigate to student notifications screen
        _navigationContext!.go('/sinhvien/dashboard?tab=3');
        debugPrint('✅ Navigated to notifications screen from system notification');
      } catch (e) {
        debugPrint('❌ Error navigating from system notification: $e');
      }
    } else {
      debugPrint('❌ Navigation context not available for system notification');
    }
  }

  /// Get notification title based on type
  String _getNotificationTitle(ThongBao notification) {
    if (notification.isExamNotification) {
      return '📝 Thông báo bài thi';
    }
    return '📢 Thông báo mới';
  }

  /// Dispose service
  void dispose() {
    // Clean up if needed
  }
}

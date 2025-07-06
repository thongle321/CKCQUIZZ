import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/services/system_notification_service.dart';
import 'package:ckcandr/firebase_options.dart';

/// Background message handler - PHẢI ở top level, không được trong class
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khởi tạo Firebase nếu chưa có
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  debugPrint('🔥 Background message received: ${message.messageId}');
  debugPrint('🔥 Background message data: ${message.data}');
  
  // Hiển thị notification ngay cả khi app bị kill
  await _showBackgroundNotification(message);
}

/// Hiển thị notification trong background
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
        FlutterLocalNotificationsPlugin();
    
    // Khởi tạo plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Tạo notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.createNotificationChannel(channel);
    
    // Hiển thị notification
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Thông báo mới',
      message.notification?.body ?? 'Bạn có thông báo mới',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
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
            message.notification?.body ?? 'Bạn có thông báo mới',
            contentTitle: message.notification?.title ?? 'Thông báo mới',
          ),
        ),
      ),
      payload: jsonEncode(message.data),
    );
    
    debugPrint('✅ Background notification displayed successfully');
  } catch (e) {
    debugPrint('❌ Error showing background notification: $e');
  }
}

/// Service quản lý Firebase Cloud Messaging
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SystemNotificationService _systemNotificationService = SystemNotificationService();
  
  bool _isInitialized = false;
  String? _fcmToken;

  /// Khởi tạo Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Khởi tạo Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Request permissions
      await _requestPermissions();
      
      // Đăng ký background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Lấy FCM token
      await _getFCMToken();
      
      // Lắng nghe messages khi app đang mở
      _setupForegroundMessageListener();
      
      // Lắng nghe khi tap vào notification
      _setupNotificationTapListener();
      
      // Lắng nghe token refresh
      _setupTokenRefreshListener();
      
      _isInitialized = true;
      debugPrint('✅ Firebase Messaging Service initialized');
      debugPrint('📱 FCM Token: $_fcmToken');
      
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📱 FCM Permission status: ${settings.authorizationStatus}');
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  /// Lấy FCM token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Lắng nghe messages khi app đang mở (foreground)
  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('🔥 Foreground message received: ${message.messageId}');
      debugPrint('🔥 Message data: ${message.data}');
      
      // Hiển thị notification khi app đang mở
      if (message.notification != null) {
        await _showForegroundNotification(message);
      }
    });
  }

  /// Hiển thị notification khi app đang mở
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      // Tạo ThongBao object từ message data nếu có
      ThongBao? notification;
      if (message.data.isNotEmpty) {
        try {
          notification = ThongBao.fromJson(message.data);
        } catch (e) {
          debugPrint('⚠️ Could not parse notification data: $e');
        }
      }

      // Nếu có notification object, sử dụng SystemNotificationService
      if (notification != null) {
        await _systemNotificationService.showNotification(notification);
      } else {
        // Fallback: hiển thị notification đơn giản
        await _systemNotificationService.showSimpleNotification(
          title: message.notification?.title ?? 'Thông báo mới',
          body: message.notification?.body ?? 'Bạn có thông báo mới',
          payload: jsonEncode(message.data),
        );
      }
    } catch (e) {
      debugPrint('❌ Error showing foreground notification: $e');
    }
  }

  /// Lắng nghe khi user tap vào notification
  void _setupNotificationTapListener() {
    // Khi app được mở từ notification (terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🔥 App opened from notification: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });

    // Khi app được mở từ notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔥 App opened from background notification: ${message.messageId}');
      _handleNotificationTap(message);
    });
  }

  /// Xử lý khi user tap vào notification
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔥 Handling notification tap: ${message.data}');
    
    // TODO: Navigate to appropriate screen based on notification data
    // Ví dụ: navigate to notifications screen
    // if (message.data['type'] == 'notification') {
    //   // Navigate to notifications screen
    // }
  }

  /// Lắng nghe token refresh
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      debugPrint('🔄 FCM Token refreshed: $token');
      _fcmToken = token;
      // TODO: Send new token to server
    });
  }

  /// Lấy FCM token hiện tại
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Dispose service
  void dispose() {
    _isInitialized = false;
  }
}

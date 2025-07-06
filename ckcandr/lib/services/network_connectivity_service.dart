/// Network Connectivity Service
///
/// Service để kiểm tra và quản lý kết nối mạng
/// Xử lý các lỗi kết nối khi app thoát hoặc mất internet
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ckcandr/core/config/api_config.dart';

/// Exception cho các lỗi kết nối mạng
class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;

  NetworkException(this.message, this.type);

  @override
  String toString() => 'NetworkException: $message';
}

/// Các loại lỗi mạng
enum NetworkErrorType {
  noInternet,
  serverUnreachable,
  timeout,
  sslError,
  unknown
}

/// Trạng thái kết nối mạng
enum NetworkStatus {
  connected,
  disconnected,
  checking
}

/// Service quản lý kết nối mạng
class NetworkConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // Stream controller để broadcast trạng thái kết nối
  final StreamController<NetworkStatus> _statusController = 
      StreamController<NetworkStatus>.broadcast();
  
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  
  NetworkStatus _currentStatus = NetworkStatus.checking;
  NetworkStatus get currentStatus => _currentStatus;
  
  bool _isInitialized = false;
  Timer? _periodicCheckTimer;

  /// Khởi tạo service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Kiểm tra kết nối ban đầu
      await _checkInitialConnectivity();
      
      // Lắng nghe thay đổi kết nối
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _onConnectivityChanged(results.isNotEmpty ? results.first : ConnectivityResult.none);
        },
        onError: (error) {
          // Removed debug log
        },
      );
      
      // Kiểm tra định kỳ mỗi 30 giây
      _startPeriodicCheck();
      
      _isInitialized = true;
      // Removed debug log
    } catch (e) {
      // Removed debug log
      _updateStatus(NetworkStatus.disconnected);
    }
  }

  /// Kiểm tra kết nối ban đầu
  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
      await _onConnectivityChanged(result);
    } catch (e) {
      _updateStatus(NetworkStatus.disconnected);
    }
  }

  /// Xử lý thay đổi kết nối
  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    // Removed debug log

    if (result == ConnectivityResult.none) {
      _updateStatus(NetworkStatus.disconnected);
      return;
    }

    // Kiểm tra kết nối thực tế đến server
    final isConnected = await _testServerConnection();
    _updateStatus(isConnected ? NetworkStatus.connected : NetworkStatus.disconnected);
  }

  /// Kiểm tra kết nối đến server
  Future<bool> _testServerConnection() async {
    try {
      // Removed debug log

      // Tạo HTTP client với timeout ngắn
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5)
        ..idleTimeout = const Duration(seconds: 5)
        ..badCertificateCallback = (cert, host, port) => true; // Bypass SSL cho test

      try {
        final uri = Uri.parse('${ApiConfig.baseUrl}/api/Auth/test');
        final request = await client.getUrl(uri);
        final response = await request.close();

        final isSuccess = response.statusCode < 500;
        // Removed debug log

        client.close();
        return isSuccess;
      } catch (e) {
        client.close();
        // Removed debug log
        return false;
      }
    } catch (e) {
      // Removed debug log
      return false;
    }
  }

  /// Bắt đầu kiểm tra định kỳ
  void _startPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// Kiểm tra kết nối
  Future<void> _checkConnectivity() async {
    if (_currentStatus == NetworkStatus.checking) return;

    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
      await _onConnectivityChanged(result);
    } catch (e) {
      // Removed debug log
    }
  }

  /// Cập nhật trạng thái
  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      // Removed debug log
    }
  }

  /// Kiểm tra có kết nối internet không
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
      if (result == ConnectivityResult.none) {
        return false;
      }

      return await _testServerConnection();
    } catch (e) {
      return false;
    }
  }

  /// Xử lý lỗi kết nối và trả về thông báo phù hợp
  NetworkException handleConnectionError(dynamic error) {
    if (error is SocketException) {
      if (error.message.contains('Failed host lookup')) {
        return NetworkException(
          'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
          NetworkErrorType.serverUnreachable,
        );
      } else {
        return NetworkException(
          'Mất kết nối internet. Vui lòng kiểm tra mạng của bạn.',
          NetworkErrorType.noInternet,
        );
      }
    } else if (error is TimeoutException) {
      return NetworkException(
        'Kết nối bị timeout. Vui lòng thử lại.',
        NetworkErrorType.timeout,
      );
    } else if (error is HandshakeException) {
      return NetworkException(
        'Lỗi bảo mật kết nối. Vui lòng thử lại.',
        NetworkErrorType.sslError,
      );
    } else {
      return NetworkException(
        'Lỗi kết nối không xác định: ${error.toString()}',
        NetworkErrorType.unknown,
      );
    }
  }

  /// Dọn dẹp resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    _statusController.close();
    _isInitialized = false;
  }
}

/// Provider cho NetworkConnectivityService
final networkConnectivityServiceProvider = Provider<NetworkConnectivityService>((ref) {
  final service = NetworkConnectivityService();
  
  // Khởi tạo service khi được tạo
  service.initialize();
  
  // Dọn dẹp khi provider bị dispose
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider cho trạng thái kết nối mạng
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkConnectivityServiceProvider);
  return service.statusStream;
});

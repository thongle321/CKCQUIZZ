/// Demo màn hình để test xử lý lỗi kết nối mạng
/// 
/// Màn hình này giúp test các tính năng:
/// - Network connectivity detection
/// - Error handling khi mất internet
/// - UI feedback cho người dùng
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/network_connectivity_service.dart';
import 'package:ckcandr/services/thong_bao_service.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/widgets/network_status_indicator.dart';

class NetworkErrorDemoScreen extends ConsumerStatefulWidget {
  const NetworkErrorDemoScreen({super.key});

  @override
  ConsumerState<NetworkErrorDemoScreen> createState() => _NetworkErrorDemoScreenState();
}

class _NetworkErrorDemoScreenState extends ConsumerState<NetworkErrorDemoScreen> 
    with NetworkStatusMixin {
  
  String _lastTestResult = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Error Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // DISABLED: Network status banner bỏ theo yêu cầu
          // const NetworkStatusBanner(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current network status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trạng thái kết nối hiện tại:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          networkStatus.when(
                            data: (status) => Row(
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            loading: () => const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Đang kiểm tra...'),
                              ],
                            ),
                            error: (error, stack) => Text(
                              'Lỗi: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test buttons
                  const Text(
                    'Test các API calls:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testNotificationAPI,
                    child: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Test Notification API'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testUserProfileAPI,
                    child: const Text('Test User Profile API'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testNetworkConnection,
                    child: const Text('Test Network Connection'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test results
                  const Text(
                    'Kết quả test:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _lastTestResult.isEmpty 
                              ? 'Chưa có kết quả test nào...' 
                              : _lastTestResult,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Clear button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _lastTestResult = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Xóa kết quả'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.checking:
        return Icons.wifi_find;
    }
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.checking:
        return Colors.orange;
    }
  }

  String _getStatusText(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'Đã kết nối';
      case NetworkStatus.disconnected:
        return 'Mất kết nối';
      case NetworkStatus.checking:
        return 'Đang kiểm tra';
    }
  }

  Future<void> _testNotificationAPI() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Đang test Notification API...\n';
    });

    try {
      final thongBaoService = ref.read(thongBaoServiceProvider);
      final notifications = await thongBaoService.getNotifications();
      
      setState(() {
        _lastTestResult += '✅ Notification API thành công!\n';
        _lastTestResult += 'Số lượng thông báo: ${notifications.items.length}\n';
        _lastTestResult += 'Tổng số thông báo: ${notifications.totalCount}\n';
        _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
      });
    } catch (e) {
      setState(() {
        _lastTestResult += '❌ Notification API thất bại!\n';
        _lastTestResult += 'Lỗi: $e\n';
        _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUserProfileAPI() async {
    setState(() {
      _isLoading = true;
      _lastTestResult += 'Đang test User Profile API...\n';
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final profile = await apiService.getCurrentUserProfile();
      
      setState(() {
        _lastTestResult += '✅ User Profile API thành công!\n';
        _lastTestResult += 'User: ${profile.email}\n';
        _lastTestResult += 'Fullname: ${profile.fullname}\n';
        _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
      });
    } catch (e) {
      setState(() {
        _lastTestResult += '❌ User Profile API thất bại!\n';
        _lastTestResult += 'Lỗi: $e\n';
        _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNetworkConnection() async {
    setState(() {
      _isLoading = true;
      _lastTestResult += 'Đang test Network Connection...\n';
    });

    try {
      final hasConnection = await hasNetworkConnection();
      
      setState(() {
        _lastTestResult += hasConnection 
            ? '✅ Network Connection thành công!\n'
            : '❌ Network Connection thất bại!\n';
        _lastTestResult += 'Kết quả: $hasConnection\n';
        _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
      });
    } catch (e) {
      setState(() {
        _lastTestResult += '❌ Network Connection test lỗi!\n';
        _lastTestResult += 'Lỗi: $e\n';
        _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void onNetworkStatusChanged(NetworkStatus status) {
    super.onNetworkStatusChanged(status);
    
    // Log network status changes
    setState(() {
      _lastTestResult += '📶 Network status changed: ${_getStatusText(status)}\n';
      _lastTestResult += 'Thời gian: ${DateTime.now()}\n\n';
    });
  }
}

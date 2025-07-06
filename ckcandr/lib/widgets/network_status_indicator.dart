/// Network Status Indicator Widget
/// 
/// Widget hiển thị trạng thái kết nối mạng cho người dùng
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/network_connectivity_service.dart';

/// Widget hiển thị trạng thái kết nối mạng
class NetworkStatusIndicator extends ConsumerWidget {
  final bool showWhenConnected;
  final EdgeInsets? margin;

  const NetworkStatusIndicator({
    super.key,
    this.showWhenConnected = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return networkStatus.when(
      data: (status) {
        // Chỉ hiển thị khi mất kết nối hoặc khi được yêu cầu hiển thị khi có kết nối
        if (status == NetworkStatus.connected && !showWhenConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: margin ?? const EdgeInsets.all(8),
          child: _buildStatusCard(context, status),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusCard(BuildContext context, NetworkStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case NetworkStatus.connected:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.wifi;
        message = 'Đã kết nối mạng';
        break;
      case NetworkStatus.disconnected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.wifi_off;
        message = 'Mất kết nối mạng';
        break;
      case NetworkStatus.checking:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.wifi_find;
        message = 'Đang kiểm tra kết nối...';
        break;
    }

    return Card(
      elevation: 2,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner hiển thị trạng thái mạng ở đầu màn hình
class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return networkStatus.when(
      data: (status) {
        if (status == NetworkStatus.connected) {
          return const SizedBox.shrink();
        }

        return Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: status == NetworkStatus.disconnected 
                ? Colors.red.shade600 
                : Colors.orange.shade600,
            child: Row(
              children: [
                Icon(
                  status == NetworkStatus.disconnected 
                      ? Icons.wifi_off 
                      : Icons.wifi_find,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status == NetworkStatus.disconnected
                        ? 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.'
                        : 'Đang kiểm tra kết nối mạng...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (status == NetworkStatus.disconnected)
                  TextButton(
                    onPressed: () {
                      // Thử kết nối lại
                      ref.read(networkConnectivityServiceProvider).hasInternetConnection();
                    },
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

/// Snackbar hiển thị thông báo kết nối mạng
class NetworkStatusSnackbar {
  static void show(BuildContext context, NetworkStatus status) {
    if (status == NetworkStatus.connected) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            status == NetworkStatus.disconnected 
                ? Icons.wifi_off 
                : Icons.wifi_find,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status == NetworkStatus.disconnected
                  ? 'Mất kết nối mạng'
                  : 'Đang kiểm tra kết nối...',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: status == NetworkStatus.disconnected 
          ? Colors.red.shade600 
          : Colors.orange.shade600,
      duration: const Duration(seconds: 3),
      action: status == NetworkStatus.disconnected
          ? SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                // Có thể thêm logic thử kết nối lại ở đây
              },
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

/// Mixin để xử lý trạng thái mạng trong các screen
mixin NetworkStatusMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  NetworkStatus? _lastNetworkStatus;

  @override
  void initState() {
    super.initState();
    
    // Lắng nghe thay đổi trạng thái mạng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AsyncValue<NetworkStatus>>(
        networkStatusProvider,
        (previous, next) {
          next.whenData((status) {
            if (_lastNetworkStatus != null && _lastNetworkStatus != status) {
              onNetworkStatusChanged(status);
            }
            _lastNetworkStatus = status;
          });
        },
      );
    });
  }

  /// Override method này để xử lý thay đổi trạng thái mạng
  void onNetworkStatusChanged(NetworkStatus status) {
    if (mounted) {
      switch (status) {
        case NetworkStatus.connected:
          // Có thể hiển thị thông báo kết nối thành công
          break;
        case NetworkStatus.disconnected:
          NetworkStatusSnackbar.show(context, status);
          break;
        case NetworkStatus.checking:
          // Có thể hiển thị loading indicator
          break;
      }
    }
  }

  /// Kiểm tra có kết nối mạng không
  Future<bool> hasNetworkConnection() async {
    final networkService = ref.read(networkConnectivityServiceProvider);
    return await networkService.hasInternetConnection();
  }

  /// Hiển thị dialog lỗi kết nối
  void showNetworkErrorDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi kết nối'),
          ],
        ),
        content: const Text(
          'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final hasConnection = await hasNetworkConnection();
              if (!hasConnection && mounted) {
                showNetworkErrorDialog();
              }
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

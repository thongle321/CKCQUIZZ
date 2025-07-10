/// Network Status Indicator Widget
/// 
/// Widget hiển thị trạng thái kết nối mạng cho người dùng
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/network_connectivity_service.dart';

/// Widget hiển thị trạng thái kết nối mạng
/// DISABLED: Không hiển thị thông báo mạng theo yêu cầu
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
    // Luôn trả về widget rỗng để ẩn thông báo mạng
    return const SizedBox.shrink();
  }

  // DISABLED: Method không sử dụng nữa
  // Widget _buildStatusCard(BuildContext context, NetworkStatus status) { ... }
}

/// Banner hiển thị trạng thái mạng ở đầu màn hình
/// DISABLED: Không hiển thị thông báo mạng theo yêu cầu
class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Luôn trả về widget rỗng để ẩn thông báo mạng
    return const SizedBox.shrink();
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
/// DISABLED: Không hiển thị thông báo mạng theo yêu cầu
mixin NetworkStatusMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // DISABLED: Không cần track network status nữa
  // NetworkStatus? _lastNetworkStatus;

  @override
  void initState() {
    super.initState();

    // DISABLED: Không lắng nghe thay đổi trạng thái mạng nữa
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.listen<AsyncValue<NetworkStatus>>(
    //     networkStatusProvider,
    //     (previous, next) {
    //       next.whenData((status) {
    //         if (_lastNetworkStatus != null && _lastNetworkStatus != status) {
    //           onNetworkStatusChanged(status);
    //         }
    //         _lastNetworkStatus = status;
    //       });
    //     },
    //   );
    // });
  }

  /// Override method này để xử lý thay đổi trạng thái mạng
  /// DISABLED: Không hiển thị thông báo mạng theo yêu cầu
  void onNetworkStatusChanged(NetworkStatus status) {
    // DISABLED: Không hiển thị thông báo mạng nữa
    // if (mounted) {
    //   switch (status) {
    //     case NetworkStatus.connected:
    //       // Có thể hiển thị thông báo kết nối thành công
    //       break;
    //     case NetworkStatus.disconnected:
    //       NetworkStatusSnackbar.show(context, status);
    //       break;
    //     case NetworkStatus.checking:
    //       // Có thể hiển thị loading indicator
    //       break;
    //   }
    // }
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

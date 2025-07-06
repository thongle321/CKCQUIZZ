/// Widget debug để test kết nối HTTP/HTTPS với server
/// 
/// Widget này giúp developer test và debug kết nối với server

import 'package:flutter/material.dart';
import 'package:ckcandr/core/config/api_config.dart';
import 'package:ckcandr/core/utils/connection_test.dart';

class ConnectionDebugWidget extends StatefulWidget {
  const ConnectionDebugWidget({super.key});

  @override
  State<ConnectionDebugWidget> createState() => _ConnectionDebugWidgetState();
}

class _ConnectionDebugWidgetState extends State<ConnectionDebugWidget> {
  String _status = 'Chưa test';
  bool _isLoading = false;

  Future<void> _testConnections() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang test kết nối...';
    });

    try {
      final protocol = await ConnectionTest.findBestProtocol();
      
      setState(() {
        switch (protocol) {
          case 'https':
            _status = '✅ HTTPS hoạt động tốt\nURL: ${ApiConfig.httpsUrl}';
            break;
          case 'http':
            _status = '✅ HTTP hoạt động tốt\nURL: ${ApiConfig.httpUrl}';
            break;
          default:
            _status = '❌ Không thể kết nối server\nKiểm tra lại cấu hình';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Lỗi test kết nối: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSpecificProtocol(bool useHttps) async {
    setState(() {
      _isLoading = true;
      _status = 'Đang test ${useHttps ? 'HTTPS' : 'HTTP'}...';
    });

    try {
      final success = useHttps 
        ? await ConnectionTest.testHttpsConnection()
        : await ConnectionTest.testHttpConnection();
      
      final protocol = useHttps ? 'HTTPS' : 'HTTP';
      final url = useHttps ? ApiConfig.httpsUrl : ApiConfig.httpUrl;
      
      setState(() {
        _status = success 
          ? '✅ $protocol hoạt động\nURL: $url'
          : '❌ $protocol không hoạt động\nURL: $url';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Lỗi test ${useHttps ? 'HTTPS' : 'HTTP'}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔧 Debug Kết Nối Server',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Current config info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 Cấu hình hiện tại:'),
                  Text('• Protocol: ${ApiConfig.useHttps ? 'HTTPS' : 'HTTP'}'),
                  Text('• Domain: ${ApiConfig.serverDomain}'),
                  Text('• Base URL: ${ApiConfig.baseUrl}'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testConnections,
                  icon: const Icon(Icons.search),
                  label: const Text('Auto Test'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testSpecificProtocol(true),
                  icon: const Icon(Icons.security),
                  label: const Text('Test HTTPS'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testSpecificProtocol(false),
                  icon: const Icon(Icons.http),
                  label: const Text('Test HTTP'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading
                ? const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Đang test...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
            ),
            
            const SizedBox(height: 12),
            
            // Instructions
            const Text(
              '💡 Hướng dẫn:\n'
              '• Auto Test: Tự động tìm protocol tốt nhất\n'
              '• Test HTTPS/HTTP: Test protocol cụ thể\n'
              '• Nếu cần đổi protocol, sửa useHttps trong ApiConfig',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

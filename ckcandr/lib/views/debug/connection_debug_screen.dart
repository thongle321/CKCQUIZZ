/// Screen debug để test kết nối HTTP/HTTPS với server
/// 
/// Screen này cung cấp giao diện để developer test và debug kết nối

import 'package:flutter/material.dart';
import 'package:ckcandr/core/widgets/connection_debug_widget.dart';
import 'package:ckcandr/core/config/api_config.dart';

class ConnectionDebugScreen extends StatelessWidget {
  const ConnectionDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug Kết Nối'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Connection debug widget
            const ConnectionDebugWidget(),
            
            // Additional info card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📚 Thông Tin Kỹ Thuật',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInfoRow('Server Domain', ApiConfig.serverDomain),
                    _buildInfoRow('HTTP URL', ApiConfig.httpUrl),
                    _buildInfoRow('HTTPS URL', ApiConfig.httpsUrl),
                    _buildInfoRow('Current Protocol', ApiConfig.useHttps ? 'HTTPS' : 'HTTP'),
                    _buildInfoRow('Base URL', ApiConfig.baseUrl),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      '🔧 Cách Thay Đổi Protocol:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '1. Mở file: lib/core/config/api_config.dart\n'
                        '2. Tìm dòng: static const bool useHttps = true;\n'
                        '3. Đổi thành false để dùng HTTP\n'
                        '4. Đổi thành true để dùng HTTPS\n'
                        '5. Hot reload app để áp dụng thay đổi',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

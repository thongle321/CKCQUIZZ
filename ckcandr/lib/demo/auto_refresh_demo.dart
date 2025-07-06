import 'package:flutter/material.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
import 'package:ckcandr/widgets/auto_refresh_indicator.dart';

/// Demo màn hình để test auto-refresh functionality
class AutoRefreshDemo extends StatefulWidget {
  const AutoRefreshDemo({super.key});

  @override
  State<AutoRefreshDemo> createState() => _AutoRefreshDemoState();
}

class _AutoRefreshDemoState extends State<AutoRefreshDemo> with AutoRefreshMixin {
  int _counter = 0;
  DateTime _lastRefresh = DateTime.now();
  final List<String> _refreshLog = [];

  // AutoRefreshMixin implementation
  @override
  String get autoRefreshKey => 'demo_screen';

  @override
  void onAutoRefresh() {
    setState(() {
      _counter++;
      _lastRefresh = DateTime.now();
      _refreshLog.insert(0, 'Auto-refresh #$_counter at ${_lastRefresh.toString().substring(11, 19)}');
      
      // Giữ tối đa 10 logs
      if (_refreshLog.length > 10) {
        _refreshLog.removeLast();
      }
    });
    debugPrint('🔄 Auto-refresh triggered: $_counter');
  }

  @override
  int get refreshIntervalSeconds => 10; // Refresh mỗi 10 giây để demo

  void _manualRefresh() {
    setState(() {
      _counter++;
      _lastRefresh = DateTime.now();
      _refreshLog.insert(0, 'Manual refresh #$_counter at ${_lastRefresh.toString().substring(11, 19)}');
      
      if (_refreshLog.length > 10) {
        _refreshLog.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Refresh Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          AutoRefreshToggleButton(
            refreshKey: autoRefreshKey,
            onRefresh: _manualRefresh,
            intervalSeconds: refreshIntervalSeconds,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _manualRefresh,
            tooltip: 'Manual Refresh',
          ),
        ],
      ),
      body: AutoRefreshIndicator(
        refreshKey: autoRefreshKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      'Refresh Count',
                      _counter.toString(),
                      Icons.refresh,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusCard(
                      'Last Refresh',
                      _lastRefresh.toString().substring(11, 19),
                      Icons.access_time,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Auto-refresh status
              AutoRefreshStatusWidget(
                refreshKeys: [autoRefreshKey],
                showDetails: true,
              ),
              
              const SizedBox(height: 24),
              
              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hướng dẫn sử dụng:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Nhấn nút 🔄 trên AppBar để bật/tắt auto-refresh'),
                      const Text('• Auto-refresh sẽ chạy mỗi 10 giây'),
                      const Text('• Nhấn nút ↻ để refresh thủ công'),
                      const Text('• Biểu tượng xanh ở góc phải hiển thị khi auto-refresh đang hoạt động'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Refresh log
              Text(
                'Refresh Log:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: _refreshLog.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có refresh nào\nHãy bật auto-refresh hoặc refresh thủ công',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _refreshLog.length,
                        itemBuilder: (context, index) {
                          final log = _refreshLog[index];
                          final isAuto = log.contains('Auto-refresh');
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                isAuto ? Icons.autorenew : Icons.refresh,
                                color: isAuto ? Colors.green : Colors.blue,
                              ),
                              title: Text(log),
                              trailing: Text(
                                isAuto ? 'AUTO' : 'MANUAL',
                                style: TextStyle(
                                  color: isAuto ? Colors.green : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ckcandr/providers/mon_hoc_provider.dart';

/// Test screen for loading subjects from API
class TestSubjectsScreen extends ConsumerStatefulWidget {
  const TestSubjectsScreen({super.key});

  @override
  ConsumerState<TestSubjectsScreen> createState() => _TestSubjectsScreenState();
}

class _TestSubjectsScreenState extends ConsumerState<TestSubjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Load subjects when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(monHocProvider.notifier).loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monHocState = ref.watch(monHocProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test - Môn học từ API'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(monHocProvider.notifier).loadSubjects();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildContent(monHocState, theme),
    );
  }

  Widget _buildContent(MonHocState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu từ API...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi khi tải dữ liệu:',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(monHocProvider.notifier).loadSubjects();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.subjects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Không có môn học nào',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('API trả về danh sách rỗng'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đã tải thành công từ API',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tổng số môn học: ${state.subjects.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                'API Endpoint: https://34.145.23.90:7254/api/MonHoc',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        
        // List of subjects
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.subjects.length,
            itemBuilder: (context, index) {
              final subject = state.subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: subject.trangThai 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: subject.trangThai 
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            child: Text(
                              'ID: ${subject.maMonHoc}',
                              style: TextStyle(
                                color: subject.trangThai 
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subject.tenMonHoc,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Details
                      _buildDetailRow('Số tín chỉ:', '${subject.soTinChi}'),
                      _buildDetailRow('Số tiết lý thuyết:', '${subject.soTietLyThuyet}'),
                      _buildDetailRow('Số tiết thực hành:', '${subject.soTietThucHanh}'),
                      _buildDetailRow(
                        'Trạng thái:', 
                        subject.trangThai ? 'Hoạt động' : 'Không hoạt động',
                        valueColor: subject.trangThai ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

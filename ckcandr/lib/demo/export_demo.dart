/// Demo để test export functionality
/// 
/// File này demo việc export bảng điểm ra CSV và TXT

import 'package:flutter/material.dart';
import 'package:ckcandr/services/export_service.dart';
import 'package:ckcandr/models/exam_taking_model.dart';

class ExportDemo extends StatefulWidget {
  const ExportDemo({super.key});

  @override
  State<ExportDemo> createState() => _ExportDemoState();
}

class _ExportDemoState extends State<ExportDemo> {
  final ExportService _exportService = ExportService();
  bool _isExporting = false;

  // Mock data để test
  final List<StudentResult> _mockResults = [
    const StudentResult(
      studentId: 'SV001',
      firstName: 'Nguyễn Văn',
      lastName: 'A',
      score: 8.5,
      startTime: null,
      duration: 45,
      tabSwitchCount: 2,
      status: 'Đã nộp',
      classId: 1,
    ),
    const StudentResult(
      studentId: 'SV002',
      firstName: 'Trần Thị',
      lastName: 'B',
      score: 7.0,
      startTime: null,
      duration: 50,
      tabSwitchCount: 1,
      status: 'Đã nộp',
      classId: 1,
    ),
    const StudentResult(
      studentId: 'SV003',
      firstName: 'Lê Văn',
      lastName: 'C',
      score: null,
      startTime: null,
      duration: null,
      tabSwitchCount: 0,
      status: 'Vắng thi',
      classId: 1,
    ),
    const StudentResult(
      studentId: 'SV004',
      firstName: 'Phạm Thị',
      lastName: 'D',
      score: 9.5,
      startTime: null,
      duration: 40,
      tabSwitchCount: 0,
      status: 'Đã nộp',
      classId: 2,
    ),
  ];

  Future<void> _exportCSV() async {
    setState(() => _isExporting = true);
    
    try {
      final success = await _exportService.exportExamResultsToCSV(
        results: _mockResults,
        examTitle: 'Demo Exam - Kiểm tra giữa kỳ',
        fileName: 'demo_export_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Export CSV thành công!' : 'Export CSV thất bại!'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi export CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportDetailed() async {
    setState(() => _isExporting = true);
    
    try {
      final success = await _exportService.exportDetailedResults(
        results: _mockResults,
        examTitle: 'Demo Exam - Kiểm tra giữa kỳ',
        fileName: 'demo_detailed_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Export chi tiết thành công!' : 'Export chi tiết thất bại!'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi export chi tiết: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demo Export Functionality',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Dữ liệu mẫu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: ListView.builder(
                itemCount: _mockResults.length,
                itemBuilder: (context, index) {
                  final result = _mockResults[index];
                  return Card(
                    child: ListTile(
                      title: Text(result.fullName),
                      subtitle: Text('MSSV: ${result.studentId} - Lớp: ${result.classId}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Điểm: ${result.score?.toString() ?? 'N/A'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            result.status,
                            style: TextStyle(
                              color: result.status == 'Đã nộp' ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportCSV,
              icon: _isExporting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.table_chart),
              label: const Text('Export CSV (Excel)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportDetailed,
              icon: _isExporting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.description),
              label: const Text('Export Chi tiết (TXT)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Lưu ý: File sẽ được lưu vào thư mục Download và tự động chia sẻ.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

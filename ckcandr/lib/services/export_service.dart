import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ckcandr/models/exam_taking_model.dart';

/// Service để export bảng điểm ra Excel/PDF
class ExportService {
  
  /// Export exam results to CSV format (simple implementation)
  Future<bool> exportExamResultsToCSV({
    required List<StudentResult> results,
    required String examTitle,
    required String fileName,
  }) async {
    try {
      debugPrint('📊 ExportService: Starting CSV export for ${results.length} results');

      // Create CSV content
      final csvContent = createCSVContent(results, examTitle);

      // Get app documents directory (không cần quyền đặc biệt)
      final directory = await getApplicationDocumentsDirectory();

      // Create file
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsString(csvContent, encoding: utf8);

      debugPrint('✅ ExportService: CSV file saved to ${file.path}');

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Bảng điểm: $examTitle');

      return true;
    } catch (e) {
      debugPrint('❌ ExportService: Error exporting to CSV: $e');
      return false;
    }
  }

  /// Create CSV content from exam results (public for testing)
  String createCSVContent(List<StudentResult> results, String examTitle) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('BẢNG ĐIỂM THI: $examTitle');
    buffer.writeln('Ngày xuất: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('');

    // Column headers
    buffer.writeln('STT,Mã sinh viên,Họ tên,Lớp,Điểm,Số câu đúng,Tổng câu,Thời gian làm bài,Thời gian vào thi,Trạng thái');

    // Data rows
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      buffer.writeln('${i + 1},'
          '"${result.studentId}",'
          '"${result.fullName}",'
          '"Lớp ${result.classId}",'
          '${result.score ?? 0},'
          '"N/A",'  // Số câu đúng không có trong StudentResult
          '"N/A",'  // Tổng câu không có trong StudentResult
          '"${_formatDuration(result.duration)}",'
          '"${_formatDateTime(result.startTime)}",'
          '"${result.status}"');
    }

    return buffer.toString();
  }

  /// Format duration in minutes to readable format
  String _formatDuration(int? durationInMinutes) {
    if (durationInMinutes == null) return 'N/A';
    
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Format DateTime to readable format
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Export detailed exam results with answers (for advanced export)
  Future<bool> exportDetailedResults({
    required List<StudentResult> results,
    required String examTitle,
    required String fileName,
  }) async {
    try {
      debugPrint('📊 ExportService: Starting detailed export');

      // Create detailed content
      final content = createDetailedContent(results, examTitle);

      // Get app documents directory (không cần quyền đặc biệt)
      final directory = await getApplicationDocumentsDirectory();

      // Create file
      final file = File('${directory.path}/$fileName.txt');
      await file.writeAsString(content, encoding: utf8);

      debugPrint('✅ ExportService: Detailed file saved to ${file.path}');

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Chi tiết bảng điểm: $examTitle');

      return true;
    } catch (e) {
      debugPrint('❌ ExportService: Error exporting detailed results: $e');
      return false;
    }
  }

  /// Create detailed content with all information (public for testing)
  String createDetailedContent(List<StudentResult> results, String examTitle) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * 60);
    buffer.writeln('BẢNG ĐIỂM CHI TIẾT: $examTitle');
    buffer.writeln('Ngày xuất: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('Tổng số sinh viên: ${results.length}');
    buffer.writeln('=' * 60);
    buffer.writeln();
    
    // Summary statistics - updated logic to match provider
    final totalStudents = results.length;
    final submittedStudents = results.where((r) => r.status == 'Đã nộp').toList();
    final passedStudents = results.where((r) => (r.score ?? 0) >= 5 && r.status == 'Đã nộp').length;

    // Điểm trung bình tính cho tất cả sinh viên (chưa thi = 0 điểm)
    final totalScore = totalStudents > 0
        ? results.map((r) => r.score ?? 0).reduce((a, b) => a + b)
        : 0.0;
    final averageScore = totalStudents > 0 ? totalScore / totalStudents : 0;

    // Tỷ lệ đậu dựa trên tổng số sinh viên trong lớp
    final passRate = totalStudents > 0 ? (passedStudents * 100 / totalStudents) : 0;

    buffer.writeln('THỐNG KÊ TỔNG QUAN:');
    buffer.writeln('- Tổng số sinh viên trong lớp: $totalStudents');
    buffer.writeln('- Số sinh viên đã làm bài: ${submittedStudents.length}');
    buffer.writeln('- Số sinh viên đạt (≥5 điểm): $passedStudents');
    buffer.writeln('- Tỷ lệ đậu (trên tổng số sinh viên): ${passRate.toStringAsFixed(1)}%');
    buffer.writeln('- Điểm trung bình (tính cả sinh viên chưa thi): ${averageScore.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln('-' * 60);
    buffer.writeln();
    
    // Individual results
    buffer.writeln('CHI TIẾT KẾT QUẢ TỪNG SINH VIÊN:');
    buffer.writeln();
    
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      buffer.writeln('${i + 1}. ${result.fullName} (${result.studentId})');
      buffer.writeln('   Lớp: Lớp ${result.classId}');
      buffer.writeln('   Điểm: ${result.score ?? 0}/10');
      buffer.writeln('   Số lần thoát: ${result.tabSwitchCount}');
      buffer.writeln('   Thời gian làm bài: ${_formatDuration(result.duration)}');
      buffer.writeln('   Thời gian vào thi: ${_formatDateTime(result.startTime)}');
      buffer.writeln('   Trạng thái: ${result.status}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  /// Calculate statistics for testing - updated to match provider logic
  Map<String, dynamic> calculateStatistics(List<StudentResult> results) {
    if (results.isEmpty) {
      return {
        'totalStudents': 0,
        'averageScore': 0.0,
        'highestScore': 0.0,
        'lowestScore': 0.0,
        'completionRate': 0.0,
        'passRate': 0.0,
      };
    }

    final totalStudents = results.length;
    // Tính điểm trung bình cho tất cả sinh viên (chưa thi = 0 điểm)
    final totalScore = results.map((r) => r.score ?? 0).reduce((a, b) => a + b);
    final averageScore = totalScore / totalStudents;

    final submittedStudents = results.where((r) => r.status == 'Đã nộp').toList();
    final highestScore = submittedStudents.isNotEmpty
        ? submittedStudents.map((r) => r.score ?? 0).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final lowestScore = submittedStudents.isNotEmpty
        ? submittedStudents.map((r) => r.score ?? 0).reduce((a, b) => a < b ? a : b)
        : 0.0;

    final completedStudents = submittedStudents.length;
    final completionRate = (completedStudents * 100.0) / totalStudents;

    // Tỷ lệ đậu dựa trên tổng số sinh viên trong lớp
    final passedStudents = results.where((r) => (r.score ?? 0) >= 5 && r.status == 'Đã nộp').length;
    final passRate = (passedStudents * 100.0) / totalStudents;

    return {
      'totalStudents': totalStudents,
      'averageScore': double.parse(averageScore.toStringAsFixed(2)),
      'highestScore': highestScore,
      'lowestScore': lowestScore,
      'completionRate': double.parse(completionRate.toStringAsFixed(1)),
      'passRate': double.parse(passRate.toStringAsFixed(1)),
    };
  }

  /// Show export options dialog
  static Future<String?> showExportDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất bảng điểm'),
        content: const Text('Chọn định dạng file để xuất:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('csv'),
            child: const Text('CSV (Excel)'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('detailed'),
            child: const Text('Chi tiết (TXT)'),
          ),
        ],
      ),
    );
  }
}

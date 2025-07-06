import 'package:flutter_test/flutter_test.dart';
import 'package:ckcandr/services/export_service.dart';
import 'package:ckcandr/models/exam_taking_model.dart';

void main() {
  group('ExportService Tests', () {
    late ExportService exportService;
    late List<StudentResult> mockResults;

    setUp(() {
      exportService = ExportService();
      mockResults = [
        StudentResult(
          studentId: '2021001',
          firstName: 'Nguyễn',
          lastName: 'Văn A',
          score: 8.5,
          startTime: DateTime(2024, 1, 15, 9, 0),
          duration: 2700, // 45 minutes in seconds
          tabSwitchCount: 2,
          status: 'Đã nộp',
          classId: 101,
        ),
        StudentResult(
          studentId: '2021002',
          firstName: 'Trần',
          lastName: 'Thị B',
          score: 7.0,
          startTime: DateTime(2024, 1, 15, 9, 5),
          duration: 3000, // 50 minutes in seconds
          tabSwitchCount: 0,
          status: 'Đã nộp',
          classId: 101,
        ),
        StudentResult(
          studentId: '2021003',
          firstName: 'Lê',
          lastName: 'Văn C',
          score: 9.5,
          startTime: DateTime(2024, 1, 15, 9, 10),
          duration: 2400, // 40 minutes in seconds
          tabSwitchCount: 1,
          status: 'Đã nộp',
          classId: 102,
        ),
      ];
    });

    test('should create CSV content correctly', () {
      // Tạo method public để test
      final csvContent = exportService.createCSVContent(mockResults, 'Test Exam');

      expect(csvContent, contains('BẢNG ĐIỂM THI: Test Exam'));
      expect(csvContent, contains('STT,Mã sinh viên,Họ tên,Lớp,Điểm'));
      expect(csvContent, contains('"2021001"'));
      expect(csvContent, contains('"Nguyễn Văn A"'));
      expect(csvContent, contains('8.5'));
      expect(csvContent, contains('"Đã nộp"'));
    });

    test('should create detailed content correctly', () {
      final detailedContent = exportService.createDetailedContent(mockResults, 'Test Exam');

      expect(detailedContent, contains('BẢNG ĐIỂM CHI TIẾT: Test Exam'));
      expect(detailedContent, contains('Tổng số sinh viên: 3'));
      expect(detailedContent, contains('Điểm trung bình (tính cả sinh viên chưa thi): 8.33'));
      expect(detailedContent, contains('Nguyễn Văn A'));
      expect(detailedContent, contains('Điểm: 8.5/10'));
      expect(detailedContent, contains('Trạng thái: Đã nộp'));
    });

    test('should handle empty results', () {
      final csvContent = exportService.createCSVContent([], 'Empty Exam');
      expect(csvContent, contains('BẢNG ĐIỂM THI: Empty Exam'));
      expect(csvContent, contains('STT,Mã sinh viên,Họ tên,Lớp,Điểm'));

      final detailedContent = exportService.createDetailedContent([], 'Empty Exam');
      expect(detailedContent, contains('Tổng số sinh viên: 0'));
      expect(detailedContent, contains('BẢNG ĐIỂM CHI TIẾT: Empty Exam'));
    });

    test('should calculate statistics correctly', () {
      final stats = exportService.calculateStatistics(mockResults);

      expect(stats['totalStudents'], equals(3));
      expect(stats['averageScore'], equals(8.33));
      expect(stats['highestScore'], equals(9.5));
      expect(stats['lowestScore'], equals(7.0));
      expect(stats['completionRate'], equals(100.0));
      expect(stats['passRate'], equals(100.0)); // All students passed (≥5)
    });

    test('should handle single result', () {
      final singleResult = [mockResults.first];
      final stats = exportService.calculateStatistics(singleResult);

      expect(stats['totalStudents'], equals(1));
      expect(stats['averageScore'], equals(8.5));
      expect(stats['highestScore'], equals(8.5));
      expect(stats['lowestScore'], equals(8.5));
      expect(stats['completionRate'], equals(100.0));
      expect(stats['passRate'], equals(100.0));
    });

    test('should handle empty statistics', () {
      final stats = exportService.calculateStatistics([]);

      expect(stats['totalStudents'], equals(0));
      expect(stats['averageScore'], equals(0.0));
      expect(stats['highestScore'], equals(0.0));
      expect(stats['lowestScore'], equals(0.0));
      expect(stats['completionRate'], equals(0.0));
      expect(stats['passRate'], equals(0.0));
    });

    test('should calculate statistics with absent students correctly', () {
      // Tạo danh sách có sinh viên vắng thi để test logic mới
      final mixedResults = [
        ...mockResults, // 3 sinh viên đã nộp: 8.5, 7.0, 9.5
        StudentResult(
          studentId: '2021004',
          firstName: 'Phạm',
          lastName: 'Văn D',
          score: null, // Chưa thi
          startTime: null,
          duration: 0,
          tabSwitchCount: 0,
          status: 'Vắng thi',
          classId: 101,
        ),
      ];

      final stats = exportService.calculateStatistics(mixedResults);

      expect(stats['totalStudents'], equals(4)); // 4 sinh viên trong lớp
      expect(stats['averageScore'], equals(6.25)); // (8.5+7.0+9.5+0)/4 = 6.25
      expect(stats['highestScore'], equals(9.5)); // Chỉ tính sinh viên đã nộp
      expect(stats['lowestScore'], equals(7.0)); // Chỉ tính sinh viên đã nộp
      expect(stats['completionRate'], equals(75.0)); // 3/4 = 75%
      expect(stats['passRate'], equals(75.0)); // 3 sinh viên đậu / 4 sinh viên = 75%
    });
  });
}

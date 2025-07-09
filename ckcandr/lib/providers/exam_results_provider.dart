import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/services/export_service.dart';
import 'package:ckcandr/core/utils/timezone_helper.dart';

/// Provider cho quản lý kết quả thi - dành cho giáo viên xem kết quả của sinh viên
/// Hỗ trợ xem danh sách kết quả, chi tiết từng bài thi, và export dữ liệu

/// State cho danh sách kết quả thi
@immutable
class ExamResultsState {
  final TestResultResponse? testResults;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final ExamResultDetail? selectedResultDetail;
  final bool isLoadingDetail;
  final String? detailError;
  final int? selectedClassId; // Lớp được chọn để filter
  final DateTime? examStartTime; // Thời gian bắt đầu thi
  final DateTime? examEndTime; // Thời gian kết thúc thi

  const ExamResultsState({
    this.testResults,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.selectedResultDetail,
    this.isLoadingDetail = false,
    this.detailError,
    this.selectedClassId,
    this.examStartTime,
    this.examEndTime,
  });

  ExamResultsState copyWith({
    TestResultResponse? testResults,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    ExamResultDetail? selectedResultDetail,
    bool? isLoadingDetail,
    String? detailError,
    int? selectedClassId,
    DateTime? examStartTime,
    DateTime? examEndTime,
  }) {
    return ExamResultsState(
      testResults: testResults ?? this.testResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedResultDetail: selectedResultDetail ?? this.selectedResultDetail,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      detailError: detailError,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      examStartTime: examStartTime ?? this.examStartTime,
      examEndTime: examEndTime ?? this.examEndTime,
    );
  }

  /// Danh sách sinh viên (tất cả hoặc theo lớp được chọn)
  List<StudentResult> get students {
    if (testResults == null) return [];
    if (selectedClassId == null) return testResults!.results;
    return testResults!.results.where((s) => s.classId == selectedClassId).toList();
  }

  /// Danh sách lớp học
  List<LopInfo> get classes => testResults?.lops ?? [];

  /// Thông tin đề thi
  TestInfo? get examInfo => testResults?.deThiInfo;

  /// Xác định trạng thái hiện tại của exam dựa trên thời gian
  ExamMonitoringStatus get currentExamStatus {
    if (examStartTime == null || examEndTime == null) {
      return ExamMonitoringStatus.afterExam; // Fallback
    }

    final now = TimezoneHelper.nowLocal();
    if (now.isBefore(examStartTime!)) {
      return ExamMonitoringStatus.beforeExam;
    } else if (now.isAfter(examEndTime!)) {
      return ExamMonitoringStatus.afterExam;
    } else {
      return ExamMonitoringStatus.duringExam;
    }
  }

  /// thống kê cơ bản - tính điểm trung bình cho tất cả sinh viên trong lớp
  /// (sinh viên chưa thi hoặc vắng thi được tính là 0 điểm)
  double get averageScore {
    if (students.isEmpty) return 0;

    // Tính tổng điểm của tất cả sinh viên (sinh viên chưa thi = 0 điểm)
    final totalScore = students.map((s) => s.hasSubmitted ? s.displayScore : 0.0).reduce((a, b) => a + b);
    final average = totalScore / students.length; // Chia cho tổng số sinh viên trong lớp

    if (average.isNaN || average.isInfinite) return 0.0;
    return average;
  }

  int get totalStudents => students.length;
  int get submittedCount => students.where((s) => s.hasSubmitted).length;
  int get absentCount => students.where((s) => s.status == 'Vắng thi').length;
  int get passedCount => students.where((s) => s.hasSubmitted && s.displayScore >= 5).length;
  int get failedCount => students.where((s) => s.hasSubmitted && s.displayScore < 5).length;

  /// Số sinh viên đang làm bài (chỉ có ý nghĩa trong khi thi)
  int get inProgressCount {
    final examStatus = currentExamStatus;
    if (examStatus != ExamMonitoringStatus.duringExam) return 0;
    return students.where((s) => s.hasTakenExam && !s.hasSubmitted).length;
  }

  /// Số sinh viên chưa vào thi (chỉ có ý nghĩa trong khi thi)
  int get notStartedCount {
    final examStatus = currentExamStatus;
    if (examStatus != ExamMonitoringStatus.duringExam) return 0;
    return students.where((s) => !s.hasTakenExam).length;
  }

  double get passRate {
    if (students.isEmpty) return 0;
    // Tính tỷ lệ đậu dựa trên tổng số sinh viên trong lớp (không chỉ sinh viên đã thi)
    final rate = (passedCount / students.length) * 100;
    if (rate.isNaN || rate.isInfinite) return 0.0;
    return rate.clamp(0.0, 100.0);
  }

  StudentResult? get highestScore {
    final submittedStudents = students.where((s) => s.hasSubmitted).toList();
    if (submittedStudents.isEmpty) return null;
    return submittedStudents.reduce((a, b) => a.displayScore > b.displayScore ? a : b);
  }

  StudentResult? get lowestScore {
    final submittedStudents = students.where((s) => s.hasSubmitted).toList();
    if (submittedStudents.isEmpty) return null;
    return submittedStudents.reduce((a, b) => a.displayScore < b.displayScore ? a : b);
  }
}

/// Notifier cho quản lý kết quả thi
class ExamResultsNotifier extends StateNotifier<ExamResultsState> {
  final ApiService _apiService;

  ExamResultsNotifier(this._apiService) : super(const ExamResultsState());

  /// load kết quả thi cho một đề thi
  Future<void> loadExamResults(int examId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final testResults = await _apiService.getExamResults(examId);

      // sắp xếp sinh viên theo điểm số giảm dần (sinh viên đã thi trước)
      final sortedResults = List<StudentResult>.from(testResults.results);
      sortedResults.sort((a, b) {
        // Sinh viên đã thi trước
        if (a.hasSubmitted && !b.hasSubmitted) return -1;
        if (!a.hasSubmitted && b.hasSubmitted) return 1;
        // Nếu cùng trạng thái, sắp xếp theo điểm
        return b.displayScore.compareTo(a.displayScore);
      });

      final updatedTestResults = TestResultResponse(
        deThiInfo: testResults.deThiInfo,
        lops: testResults.lops,
        results: sortedResults,
      );

      // Load exam timing từ API /DeThi/{id}
      DateTime? examStartTime;
      DateTime? examEndTime;
      try {
        final examDetail = await _apiService.getDeThiById(examId);
        examStartTime = examDetail.thoigiantbatdau;
        examEndTime = examDetail.thoigianketthuc;
        debugPrint('✅ Loaded exam timing: Start=$examStartTime, End=$examEndTime');
      } catch (e) {
        debugPrint('⚠️ Could not load exam timing: $e');
        // Continue without timing info
      }

      state = state.copyWith(
        testResults: updatedTestResults,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
        selectedClassId: testResults.lops.isNotEmpty ? testResults.lops.first.classId : null,
        examStartTime: examStartTime,
        examEndTime: examEndTime,
      );

      if (testResults.results.isEmpty) {
        debugPrint('📋 No students found for exam $examId - exam may not be assigned to any class');
      } else {
        debugPrint('✅ Loaded ${testResults.results.length} students (${state.submittedCount} submitted)');
      }
    } catch (e) {
      debugPrint('❌ Error loading exam results: $e');

      // Phân biệt giữa lỗi không tìm thấy và lỗi khác
      String errorMessage = e.toString();
      if (errorMessage.contains('404') ||
          errorMessage.contains('Not Found') ||
          errorMessage.contains('không tìm thấy')) {
        errorMessage = 'Không tìm thấy dữ liệu kết quả thi. Đề thi có thể chưa được gán cho lớp nào hoặc chưa có sinh viên làm bài.';
      } else if (errorMessage.contains('403') || errorMessage.contains('Forbidden')) {
        errorMessage = 'Bạn không có quyền xem kết quả thi này.';
      } else if (errorMessage.contains('500') || errorMessage.contains('Internal Server Error')) {
        errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        testResults: null, // Clear results on error
      );
    }
  }

  /// load chi tiết kết quả của một sinh viên
  Future<void> loadResultDetail(int resultId) async {
    state = state.copyWith(isLoadingDetail: true, detailError: null);

    try {
      final detail = await _apiService.getExamResultDetail(resultId);

      state = state.copyWith(
        selectedResultDetail: detail,
        isLoadingDetail: false,
        detailError: null,
      );

      debugPrint('✅ Loaded result detail for result $resultId');
    } catch (e) {
      debugPrint('❌ Error loading result detail: $e');
      state = state.copyWith(
        isLoadingDetail: false,
        detailError: e.toString(),
      );
    }
  }

  /// clear chi tiết kết quả
  void clearResultDetail() {
    state = state.copyWith(
      selectedResultDetail: null,
      detailError: null,
    );
  }

  /// export kết quả ra file
  Future<bool> exportResults(int examId, String format, String examTitle) async {
    try {
      debugPrint('📊 ExamResultsProvider: Starting export - ExamId: $examId, Format: $format');

      // Lấy dữ liệu kết quả hiện tại
      final currentResults = state.testResults?.results ?? [];
      if (currentResults.isEmpty) {
        debugPrint('❌ ExamResultsProvider: No results to export');
        state = state.copyWith(error: 'Không có dữ liệu để xuất');
        return false;
      }

      final exportService = ExportService();
      final fileName = 'BangDiem_${examTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

      bool success = false;
      if (format == 'csv' || format == 'excel') {
        success = await exportService.exportExamResultsToCSV(
          results: currentResults,
          examTitle: examTitle,
          fileName: fileName,
        );
      } else if (format == 'detailed' || format == 'pdf') {
        success = await exportService.exportDetailedResults(
          results: currentResults,
          examTitle: examTitle,
          fileName: fileName,
        );
      }

      if (success) {
        debugPrint('✅ ExamResultsProvider: Export successful');
        return true;
      } else {
        debugPrint('❌ ExamResultsProvider: Export failed');
        state = state.copyWith(error: 'Lỗi khi xuất file');
        return false;
      }
    } catch (e) {
      debugPrint('❌ ExamResultsProvider: Error exporting results: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// refresh kết quả
  Future<void> refresh(int examId) async {
    await loadExamResults(examId);
  }

  /// Thay đổi lớp được chọn để filter
  void selectClass(int? classId) {
    state = state.copyWith(selectedClassId: classId);
  }

  /// lọc sinh viên theo điều kiện
  List<StudentResult> filterStudents({
    double? minScore,
    double? maxScore,
    String? studentNameFilter,
    String? statusFilter,
  }) {
    var filtered = state.students;

    if (minScore != null) {
      filtered = filtered.where((s) => s.displayScore >= minScore).toList();
    }

    if (maxScore != null) {
      filtered = filtered.where((s) => s.displayScore <= maxScore).toList();
    }

    if (studentNameFilter != null && studentNameFilter.isNotEmpty) {
      final query = studentNameFilter.toLowerCase();
      filtered = filtered.where((s) =>
        s.fullName.toLowerCase().contains(query) ||
        s.studentId.toLowerCase().contains(query)
      ).toList();
    }

    if (statusFilter != null && statusFilter.isNotEmpty) {
      filtered = filtered.where((s) => s.status == statusFilter).toList();
    }

    return filtered;
  }

  /// sắp xếp sinh viên
  void sortStudents(String sortBy, bool ascending) {
    if (state.testResults == null) return;

    final sortedStudents = List<StudentResult>.from(state.students);

    switch (sortBy) {
      case 'score':
        sortedStudents.sort((a, b) => ascending
          ? a.displayScore.compareTo(b.displayScore)
          : b.displayScore.compareTo(a.displayScore));
        break;
      case 'studentId':
        sortedStudents.sort((a, b) => ascending
          ? a.studentId.compareTo(b.studentId)
          : b.studentId.compareTo(a.studentId));
        break;
      case 'name':
        sortedStudents.sort((a, b) => ascending
          ? a.fullName.compareTo(b.fullName)
          : b.fullName.compareTo(a.fullName));
        break;
      case 'status':
        sortedStudents.sort((a, b) => ascending
          ? a.status.compareTo(b.status)
          : b.status.compareTo(a.status));
        break;
      default:
        break;
    }

    // Update the entire test results with sorted students
    final updatedTestResults = TestResultResponse(
      deThiInfo: state.testResults!.deThiInfo,
      lops: state.testResults!.lops,
      results: sortedStudents,
    );

    state = state.copyWith(testResults: updatedTestResults);
  }

  /// Lấy kết quả bài thi chi tiết của sinh viên (dành cho giáo viên xem)
  Future<ExamResultDetail?> getStudentExamResult(int resultId) async {
    try {
      debugPrint('🔍 Getting student exam result detail: resultId=$resultId');

      // Gọi API để lấy chi tiết kết quả bài thi của sinh viên
      final result = await _apiService.getExamResultDetail(resultId);

      debugPrint('✅ Student exam result retrieved successfully');
      return result;
    } catch (e) {
      debugPrint('❌ Error getting student exam result: $e');
      return null;
    }
  }
}

/// Provider chính cho exam results
final examResultsProvider = StateNotifierProvider<ExamResultsNotifier, ExamResultsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ExamResultsNotifier(apiService);
});

/// Provider cho kết quả của một đề thi cụ thể
final examResultsForExamProvider = FutureProvider.family<TestResultResponse, int>((ref, examId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getExamResults(examId);
});

/// Provider cho chi tiết kết quả của một sinh viên
final examResultDetailProvider = FutureProvider.family<ExamResultDetail, int>((ref, resultId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getExamResultDetail(resultId);
});

/// Provider cho thống kê kết quả thi
final examResultsStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(examResultsProvider);

  return {
    'totalStudents': state.totalStudents,
    'submittedCount': state.submittedCount,
    'absentCount': state.absentCount,
    'averageScore': state.averageScore,
    'passedCount': state.passedCount,
    'failedCount': state.failedCount,
    'passRate': state.passRate,
    'highestScore': state.highestScore?.displayScore ?? 0,
    'lowestScore': state.lowestScore?.displayScore ?? 0,
    'inProgressCount': state.inProgressCount,
    'notStartedCount': state.notStartedCount,
  };
});

/// Provider cho việc lọc sinh viên
final filteredStudentsProvider = Provider.family<List<StudentResult>, Map<String, dynamic>>((ref, filters) {
  final notifier = ref.watch(examResultsProvider.notifier);

  return notifier.filterStudents(
    minScore: filters['minScore'] as double?,
    maxScore: filters['maxScore'] as double?,
    studentNameFilter: filters['studentName'] as String?,
    statusFilter: filters['status'] as String?,
  );
});

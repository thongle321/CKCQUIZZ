import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/exam_taking_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// Provider cho quản lý kết quả thi - dành cho giáo viên xem kết quả của sinh viên
/// Hỗ trợ xem danh sách kết quả, chi tiết từng bài thi, và export dữ liệu

/// State cho danh sách kết quả thi
@immutable
class ExamResultsState {
  final List<ExamResult> results;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final ExamResultDetail? selectedResultDetail;
  final bool isLoadingDetail;
  final String? detailError;

  const ExamResultsState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.selectedResultDetail,
    this.isLoadingDetail = false,
    this.detailError,
  });

  ExamResultsState copyWith({
    List<ExamResult>? results,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    ExamResultDetail? selectedResultDetail,
    bool? isLoadingDetail,
    String? detailError,
  }) {
    return ExamResultsState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedResultDetail: selectedResultDetail ?? this.selectedResultDetail,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      detailError: detailError,
    );
  }

  /// thống kê cơ bản
  double get averageScore {
    if (results.isEmpty) return 0;
    final sum = results.map((r) => r.score).reduce((a, b) => a + b);
    final average = sum / results.length;
    if (average.isNaN || average.isInfinite) return 0.0;
    return average;
  }

  int get passedCount => results.where((r) => r.score >= 5).length;
  int get failedCount => results.where((r) => r.score < 5).length;
  double get passRate {
    if (results.isEmpty) return 0;
    final rate = (passedCount / results.length) * 100;
    if (rate.isNaN || rate.isInfinite) return 0.0;
    return rate.clamp(0.0, 100.0);
  }

  ExamResult? get highestScore => results.isEmpty 
      ? null 
      : results.reduce((a, b) => a.score > b.score ? a : b);
  
  ExamResult? get lowestScore => results.isEmpty 
      ? null 
      : results.reduce((a, b) => a.score < b.score ? a : b);
}

/// Notifier cho quản lý kết quả thi
class ExamResultsNotifier extends StateNotifier<ExamResultsState> {
  final ApiService _apiService;

  ExamResultsNotifier(this._apiService) : super(const ExamResultsState());

  /// load kết quả thi cho một đề thi
  Future<void> loadExamResults(int examId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _apiService.getExamResults(examId);

      // sắp xếp theo điểm số giảm dần
      results.sort((a, b) => b.score.compareTo(a.score));

      state = state.copyWith(
        results: results,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
      );

      if (results.isEmpty) {
        debugPrint('📋 No exam results found for exam $examId - empty class or no submissions');
      } else {
        debugPrint('✅ Loaded ${results.length} exam results');
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
        results: [], // Clear results on error
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
  Future<String?> exportResults(int examId, String format) async {
    try {
      final downloadUrl = await _apiService.exportExamResults(examId, format);
      debugPrint('✅ Export successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error exporting results: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// refresh kết quả
  Future<void> refresh(int examId) async {
    await loadExamResults(examId);
  }

  /// lọc kết quả theo điều kiện
  List<ExamResult> filterResults({
    double? minScore,
    double? maxScore,
    String? studentNameFilter,
  }) {
    var filtered = state.results;

    if (minScore != null) {
      filtered = filtered.where((r) => r.score >= minScore).toList();
    }

    if (maxScore != null) {
      filtered = filtered.where((r) => r.score <= maxScore).toList();
    }

    if (studentNameFilter != null && studentNameFilter.isNotEmpty) {
      // cần thêm student name vào ExamResult model hoặc load từ API khác
      // tạm thời skip filter này
    }

    return filtered;
  }

  /// sắp xếp kết quả
  void sortResults(String sortBy, bool ascending) {
    final sortedResults = List<ExamResult>.from(state.results);

    switch (sortBy) {
      case 'score':
        sortedResults.sort((a, b) => ascending 
            ? a.score.compareTo(b.score) 
            : b.score.compareTo(a.score));
        break;
      case 'time':
        sortedResults.sort((a, b) => ascending 
            ? a.duration.compareTo(b.duration) 
            : b.duration.compareTo(a.duration));
        break;
      case 'completedTime':
        sortedResults.sort((a, b) => ascending 
            ? a.completedTime.compareTo(b.completedTime) 
            : b.completedTime.compareTo(a.completedTime));
        break;
      default:
        break;
    }

    state = state.copyWith(results: sortedResults);
  }
}

/// Provider chính cho exam results
final examResultsProvider = StateNotifierProvider<ExamResultsNotifier, ExamResultsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ExamResultsNotifier(apiService);
});

/// Provider cho kết quả của một đề thi cụ thể
final examResultsForExamProvider = FutureProvider.family<List<ExamResult>, int>((ref, examId) async {
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
    'totalStudents': state.results.length,
    'averageScore': state.averageScore,
    'passedCount': state.passedCount,
    'failedCount': state.failedCount,
    'passRate': state.passRate,
    'highestScore': state.highestScore?.score ?? 0,
    'lowestScore': state.lowestScore?.score ?? 0,
  };
});

/// Provider cho việc lọc và sắp xếp kết quả
final filteredExamResultsProvider = Provider.family<List<ExamResult>, Map<String, dynamic>>((ref, filters) {
  final notifier = ref.watch(examResultsProvider.notifier);
  
  return notifier.filterResults(
    minScore: filters['minScore'] as double?,
    maxScore: filters['maxScore'] as double?,
    studentNameFilter: filters['studentName'] as String?,
  );
});

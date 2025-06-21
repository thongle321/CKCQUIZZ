import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/core/utils/retry_helper.dart';

/// Provider for chapters list
final chaptersProvider = StateNotifierProvider.family<ChaptersNotifier, AsyncValue<List<ChuongDTO>>, int?>(
  (ref, mamonhocId) => ChaptersNotifier(ref, mamonhocId),
);

/// Provider for assigned subjects (môn học được phân công)
final assignedSubjectsProvider = FutureProvider<List<MonHocDTO>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getAssignedSubjects();
});

/// Notifier for managing chapters state
class ChaptersNotifier extends StateNotifier<AsyncValue<List<ChuongDTO>>> {
  final Ref _ref;
  final int? _mamonhocId;

  ChaptersNotifier(this._ref, this._mamonhocId) : super(const AsyncValue.loading()) {
    loadChapters();
  }

  /// Load chapters from API
  Future<void> loadChapters() async {
    try {
      state = const AsyncValue.loading();
      final apiService = _ref.read(apiServiceProvider);

      // Sử dụng retry mechanism để xử lý trường hợp API trả về empty
      final chapters = await RetryHelper.retryForList<ChuongDTO>(
        () async {
          print('🔄 Fetching chapters for subject ID: $_mamonhocId');
          final result = await apiService.getChapters(mamonhocId: _mamonhocId);
          print('📊 Chapters result for subject $_mamonhocId: ${result.length} chapters');
          if (result.isEmpty) {
            print('⚠️ Empty chapters for subject $_mamonhocId - will retry');
          }
          return result;
        },
        maxRetries: 3, // Tăng số lần retry
        initialDelay: const Duration(milliseconds: 500),
      );

      // Log final result
      if (chapters.isEmpty) {
        print('❌ Final result: No chapters found for subject $_mamonhocId after retries');
      } else {
        print('✅ Final result: ${chapters.length} chapters loaded for subject $_mamonhocId');
      }

      // Ensure state update happens properly
      state = AsyncValue.data(chapters);
      print('🎯 Provider state updated: ${chapters.length} chapters for subject $_mamonhocId');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add new chapter
  Future<void> addChapter(CreateChuongRequestDTO request) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final newChapter = await apiService.createChapter(request);
      
      // Update state with new chapter
      state.whenData((chapters) {
        state = AsyncValue.data([...chapters, newChapter]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update existing chapter
  Future<void> updateChapter(int id, UpdateChuongRequestDTO request) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final updatedChapter = await apiService.updateChapter(id, request);
      
      // Update state with updated chapter
      state.whenData((chapters) {
        final updatedList = chapters.map((chapter) {
          return chapter.machuong == id ? updatedChapter : chapter;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete chapter
  Future<void> deleteChapter(int id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.deleteChapter(id);
      
      // Update state by removing deleted chapter
      state.whenData((chapters) {
        final updatedList = chapters.where((chapter) => chapter.machuong != id).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh chapters list
  Future<void> refresh() async {
    await loadChapters();
  }
}

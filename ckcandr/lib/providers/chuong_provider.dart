import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/services/api_service.dart';

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
      final chapters = await apiService.getChapters(mamonhocId: _mamonhocId);
      state = AsyncValue.data(chapters);
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

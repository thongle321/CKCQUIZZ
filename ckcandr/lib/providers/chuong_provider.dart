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

      // Nếu không có môn học ID, trả về danh sách rỗng
      if (_mamonhocId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final apiService = _ref.read(apiServiceProvider);

      // Gọi API trực tiếp mà không retry để tránh lỗi phức tạp
      print('🔄 Fetching chapters for subject ID: $_mamonhocId');
      final chapters = await apiService.getChapters(mamonhocId: _mamonhocId);
      print('📊 Chapters result for subject $_mamonhocId: ${chapters.length} chapters');

      // Cập nhật state với kết quả (có thể là danh sách rỗng)
      state = AsyncValue.data(chapters);
      print('🎯 Provider state updated: ${chapters.length} chapters for subject $_mamonhocId');
    } catch (error) {
      print('❌ Error loading chapters for subject $_mamonhocId: $error');
      // Trả về danh sách rỗng thay vì lỗi để không crash UI
      state = const AsyncValue.data([]);
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
    } catch (error) {
      print('❌ Error adding chapter: $error');
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
    } catch (error) {
      print('❌ Error updating chapter: $error');
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
    } catch (error) {
      print('❌ Error deleting chapter: $error');
      rethrow;
    }
  }

  /// Refresh chapters list
  Future<void> refresh() async {
    await loadChapters();
  }
}

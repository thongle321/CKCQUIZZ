import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/services/api_service.dart';

/// State class for subject management
class MonHocState {
  final List<ApiMonHoc> subjects;
  final bool isLoading;
  final String? error;
  final ApiMonHoc? selectedSubject;

  const MonHocState({
    this.subjects = const [],
    this.isLoading = false,
    this.error,
    this.selectedSubject,
  });

  MonHocState copyWith({
    List<ApiMonHoc>? subjects,
    bool? isLoading,
    String? error,
    ApiMonHoc? selectedSubject,
    bool clearError = false,
    bool clearSelectedSubject = false,
  }) {
    return MonHocState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedSubject: clearSelectedSubject ? null : (selectedSubject ?? this.selectedSubject),
    );
  }
}

/// Notifier for subject management
class MonHocNotifier extends StateNotifier<MonHocState> {
  final ApiService _apiService;

  MonHocNotifier(this._apiService) : super(const MonHocState());

  /// Load all subjects
  Future<void> loadSubjects() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final subjects = await _apiService.getSubjects();
      state = state.copyWith(
        subjects: subjects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create new subject
  Future<bool> createSubject(CreateMonHocRequestDTO request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final newSubject = await _apiService.createSubject(request);
      final updatedSubjects = [...state.subjects, newSubject];
      state = state.copyWith(
        subjects: updatedSubjects,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update subject
  Future<bool> updateSubject(int maMonHoc, UpdateMonHocRequestDTO request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _apiService.updateSubject(maMonHoc, request);

      // Reload subjects to get updated data
      await loadSubjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete subject
  Future<bool> deleteSubject(int maMonHoc) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _apiService.deleteSubject(maMonHoc);

      // Remove subject from local state
      final updatedSubjects = state.subjects.where((s) => s.maMonHoc != maMonHoc).toList();
      state = state.copyWith(
        subjects: updatedSubjects,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Select subject for editing
  void selectSubject(ApiMonHoc subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  /// Clear selected subject
  void clearSelectedSubject() {
    state = state.copyWith(clearSelectedSubject: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for subject management
final monHocProvider = StateNotifierProvider<MonHocNotifier, MonHocState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MonHocNotifier(apiService);
});

/// Legacy provider for backward compatibility - converts ApiMonHoc to MonHoc
final monHocListProvider = Provider<List<MonHoc>>((ref) {
  final apiSubjects = ref.watch(monHocProvider).subjects;
  // Convert ApiMonHoc to MonHoc for backward compatibility
  return apiSubjects.map((apiSubject) => MonHoc(
    id: apiSubject.maMonHoc.toString(),
    tenMonHoc: apiSubject.tenMonHoc,
    maMonHoc: apiSubject.maMonHoc.toString(),
    soTinChi: apiSubject.soTinChi,
    soGioLT: apiSubject.soTietLyThuyet,
    soGioTH: apiSubject.soTietThucHanh,
    trangThai: apiSubject.trangThai,
  )).toList();
});

/// Provider for filtered subjects (for search functionality)
final filteredSubjectsProvider = Provider.family<List<MonHoc>, String?>((ref, searchQuery) {
  final subjects = ref.watch(monHocListProvider);

  if (searchQuery == null || searchQuery.isEmpty) {
    return subjects;
  }

  final query = searchQuery.toLowerCase();
  return subjects.where((subject) {
    return subject.tenMonHoc.toLowerCase().contains(query) ||
           subject.maMonHoc.toLowerCase().contains(query);
  }).toList();
});
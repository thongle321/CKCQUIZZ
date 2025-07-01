/// Providers for Exam Management (Đề Kiểm Tra)
/// 
/// This file contains all Riverpod providers for managing exam state,
/// including CRUD operations, form state, and UI state management.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/services/notification_service.dart';

// ===== STATE CLASSES =====

/// State for exam list
@immutable
class DeThiListState {
  final List<DeThiModel> deThis;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const DeThiListState({
    required this.deThis,
    required this.isLoading,
    this.error,
    required this.searchQuery,
  });

  DeThiListState copyWith({
    List<DeThiModel>? deThis,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return DeThiListState(
      deThis: deThis ?? this.deThis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get filtered exams based on search query
  List<DeThiModel> get filteredDeThis {
    if (searchQuery.isEmpty) return deThis;
    
    return deThis.where((deThi) {
      final tende = deThi.tende?.toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return tende.contains(query);
    }).toList();
  }
}

/// State for exam form (create/edit)
@immutable
class DeThiFormState {
  final bool isLoading;
  final String? error;
  final bool isEditMode;
  final DeThiDetailModel? editingDeThi;

  const DeThiFormState({
    required this.isLoading,
    this.error,
    required this.isEditMode,
    this.editingDeThi,
  });

  DeThiFormState copyWith({
    bool? isLoading,
    String? error,
    bool? isEditMode,
    DeThiDetailModel? editingDeThi,
  }) {
    return DeThiFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditMode: isEditMode ?? this.isEditMode,
      editingDeThi: editingDeThi ?? this.editingDeThi,
    );
  }
}

/// State for question composer
@immutable
class QuestionComposerState {
  final List<CauHoiSoanThaoModel> questionsInExam;
  final List<int> selectedQuestionIds;
  final bool isLoading;
  final String? error;

  const QuestionComposerState({
    required this.questionsInExam,
    required this.selectedQuestionIds,
    required this.isLoading,
    this.error,
  });

  QuestionComposerState copyWith({
    List<CauHoiSoanThaoModel>? questionsInExam,
    List<int>? selectedQuestionIds,
    bool? isLoading,
    String? error,
  }) {
    return QuestionComposerState(
      questionsInExam: questionsInExam ?? this.questionsInExam,
      selectedQuestionIds: selectedQuestionIds ?? this.selectedQuestionIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ===== STATE NOTIFIERS =====

/// State notifier for exam list management
class DeThiListNotifier extends StateNotifier<AsyncValue<DeThiListState>> {
  final ApiService _apiService;

  DeThiListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadDeThis();
  }

  /// Load all exams
  Future<void> loadDeThis() async {
    state = const AsyncValue.loading();

    try {
      final deThis = await _apiService.getAllDeThis();

      // Filter out soft-deleted exams (trangthai = false)
      final activeDeThis = deThis.where((deThi) => deThi.trangthai == true).toList();

      state = AsyncValue.data(DeThiListState(
        deThis: activeDeThis,
        isLoading: false,
        searchQuery: '',
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh exam list
  Future<void> refresh() async {
    await loadDeThis();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: query));
    });
  }

  /// Add new exam to list
  void addDeThi(DeThiModel deThi) {
    state.whenData((currentState) {
      final updatedList = [deThi, ...currentState.deThis];
      state = AsyncValue.data(currentState.copyWith(deThis: updatedList));
    });
  }

  /// Update exam in list
  void updateDeThi(DeThiModel updatedDeThi) {
    state.whenData((currentState) {
      final updatedList = currentState.deThis.map((deThi) {
        return deThi.made == updatedDeThi.made ? updatedDeThi : deThi;
      }).toList();
      state = AsyncValue.data(currentState.copyWith(deThis: updatedList));
    });
  }

  /// Remove exam from list
  void removeDeThi(int deThiId) {
    state.whenData((currentState) {
      final updatedList = currentState.deThis.where((deThi) => deThi.made != deThiId).toList();
      state = AsyncValue.data(currentState.copyWith(deThis: updatedList));
    });
  }
}

/// State notifier for exam form management
class DeThiFormNotifier extends StateNotifier<DeThiFormState> {
  final ApiService _apiService;
  final NotificationService _notificationService;

  DeThiFormNotifier(this._apiService, this._notificationService) : super(const DeThiFormState(
    isLoading: false,
    isEditMode: false,
  ));

  /// Start creating new exam
  void startCreate() {
    state = state.copyWith(
      isEditMode: false,
      editingDeThi: null,
      error: null,
    );
  }

  /// Start editing exam
  Future<void> startEdit(int deThiId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('🔄 Loading exam for edit: $deThiId');
      final deThi = await _apiService.getDeThiById(deThiId);
      debugPrint('✅ Loaded exam data: ${deThi.tende}');
      state = state.copyWith(
        isLoading: false,
        isEditMode: true,
        editingDeThi: deThi,
      );
    } catch (e) {
      debugPrint('❌ Error loading exam for edit: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create new exam
  Future<DeThiModel?> createDeThi(DeThiCreateRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newDeThi = await _apiService.createDeThi(request);
      state = state.copyWith(isLoading: false);

      // Send notification for exam creation with class IDs
      await _notificationService.notifyExamCreated(newDeThi, classIds: request.malops);

      return newDeThi;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Update exam
  Future<bool> updateDeThi(int id, DeThiUpdateRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _apiService.updateDeThi(id, request);

      if (success) {
        // Create a simple DeThiModel for notification
        final examForNotification = DeThiModel(
          made: id,
          tende: request.tende,
          giaoCho: '',
          monthi: request.monthi,
          thoigianbatdau: request.thoigianbatdau,
          thoigianketthuc: request.thoigianketthuc,
          trangthai: true,
        );

        // Send notification for exam update with class IDs
        await _notificationService.notifyExamUpdated(examForNotification, classIds: request.malops);
      }

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete exam
  Future<bool> deleteDeThi(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get exam details before deletion to get class IDs and name
      final examDetail = await _apiService.getDeThiById(id);

      final success = await _apiService.deleteDeThi(id);
      state = state.copyWith(isLoading: false);

      if (success) {
        // Send notification for exam deletion with class IDs
        await _notificationService.notifyExamDeleted(
          examDetail.tende ?? 'Đề thi #$id',
          classIds: examDetail.malops,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ===== PROVIDERS =====

/// Provider for exam list state
final deThiListProvider = StateNotifierProvider<DeThiListNotifier, AsyncValue<DeThiListState>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DeThiListNotifier(apiService);
});

/// Provider for exam form state
final deThiFormProvider = StateNotifierProvider<DeThiFormNotifier, DeThiFormState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return DeThiFormNotifier(apiService, notificationService);
});

/// Provider for getting exam detail by ID
final deThiDetailProvider = FutureProvider.family<DeThiDetailModel, int>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getDeThiById(id);
});

/// Provider for question composer state
final questionComposerProvider = StateNotifierProvider.family<QuestionComposerNotifier, AsyncValue<QuestionComposerState>, int>(
  (ref, deThiId) {
    final apiService = ref.watch(apiServiceProvider);
    return QuestionComposerNotifier(apiService, deThiId);
  },
);

/// State notifier for question composer
class QuestionComposerNotifier extends StateNotifier<AsyncValue<QuestionComposerState>> {
  final ApiService _apiService;
  final int _deThiId;

  QuestionComposerNotifier(this._apiService, this._deThiId) : super(const AsyncValue.loading()) {
    loadQuestionsInExam();
  }

  /// Load questions in exam
  Future<void> loadQuestionsInExam() async {
    state = const AsyncValue.loading();

    try {
      final questions = await _apiService.getCauHoiCuaDeThi(_deThiId);
      state = AsyncValue.data(QuestionComposerState(
        questionsInExam: questions,
        selectedQuestionIds: [],
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add questions to exam
  Future<bool> addQuestionsToExam(List<int> questionIds) async {
    try {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(isLoading: true));
      });

      final request = DapAnSoanThaoRequest(cauHoiIds: questionIds);
      final success = await _apiService.addCauHoiVaoDeThi(_deThiId, request);

      if (success) {
        await loadQuestionsInExam(); // Reload to get updated list
      }

      return success;
    } catch (e) {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      });
      return false;
    }
  }

  /// Remove question from exam
  Future<bool> removeQuestionFromExam(int questionId) async {
    try {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(isLoading: true));
      });

      final success = await _apiService.removeCauHoiKhoiDeThi(_deThiId, questionId);

      if (success) {
        await loadQuestionsInExam(); // Reload to get updated list
      }

      return success;
    } catch (e) {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      });
      return false;
    }
  }

  /// Update selected question IDs
  void updateSelectedQuestions(List<int> selectedIds) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedQuestionIds: selectedIds));
    });
  }
}

/// Provider for getting questions by subject
final questionsBySubjectProvider = FutureProvider.family<List<CauHoi>, int>((ref, subjectId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getQuestionsBySubject(subjectId);
});

/// Provider for getting questions by subject and chapter
final questionsBySubjectAndChapterProvider = FutureProvider.family<List<CauHoi>, QuestionFilterParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);

  if (params.chapterIds.isEmpty) {
    // If no chapters selected, get all questions for the subject
    return await apiService.getQuestionsBySubject(params.subjectId);
  } else {
    // Get questions filtered by chapters
    return await apiService.getQuestionsBySubjectAndChapters(params.subjectId, params.chapterIds);
  }
});

/// Parameters for filtering questions
class QuestionFilterParams {
  final int subjectId;
  final List<int> chapterIds;

  const QuestionFilterParams({
    required this.subjectId,
    this.chapterIds = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionFilterParams &&
        other.subjectId == subjectId &&
        _listEquals(other.chapterIds, chapterIds);
  }

  @override
  int get hashCode => Object.hash(subjectId, chapterIds);

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

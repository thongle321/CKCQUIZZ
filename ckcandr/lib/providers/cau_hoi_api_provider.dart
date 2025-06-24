/// Riverpod providers for Question (Câu hỏi) API state management
/// 
/// This file contains all the providers for managing question state,
/// including loading, creating, updating, and deleting questions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/services/cau_hoi_service.dart';

/// State class for question list with pagination
class CauHoiListState {
  final List<CauHoi> questions;
  final bool isLoading;
  final String? error;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasMore;

  CauHoiListState({
    this.questions = const [],
    this.isLoading = false,
    this.error,
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 10,
    this.hasMore = false,
  });

  CauHoiListState copyWith({
    List<CauHoi>? questions,
    bool? isLoading,
    String? error,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasMore,
  }) {
    return CauHoiListState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Filter parameters for question list
class CauHoiFilter {
  final int? maMonHoc;
  final int? maChuong;
  final int? doKho;
  final String? keyword;

  CauHoiFilter({
    this.maMonHoc,
    this.maChuong,
    this.doKho,
    this.keyword,
  });

  CauHoiFilter copyWith({
    int? maMonHoc,
    int? maChuong,
    int? doKho,
    String? keyword,
  }) {
    return CauHoiFilter(
      maMonHoc: maMonHoc ?? this.maMonHoc,
      maChuong: maChuong ?? this.maChuong,
      doKho: doKho ?? this.doKho,
      keyword: keyword ?? this.keyword,
    );
  }
}

/// Provider for current question filter
final cauHoiFilterProvider = StateProvider<CauHoiFilter>((ref) {
  return CauHoiFilter();
});

/// Provider for question list state
class CauHoiListNotifier extends StateNotifier<CauHoiListState> {
  final CauHoiService _cauHoiService;

  CauHoiListNotifier(this._cauHoiService) : super(CauHoiListState());

  /// Load questions with current filter
  Future<void> loadQuestions({
    CauHoiFilter? filter,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    } else if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _cauHoiService.getQuestions(
        maMonHoc: filter?.maMonHoc,
        maChuong: filter?.maChuong,
        doKho: filter?.doKho,
        keyword: filter?.keyword,
        pageNumber: page,
        pageSize: state.pageSize,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final newQuestions = page == 1 ? data.items : [...state.questions, ...data.items];
        final hasMore = newQuestions.length < data.totalCount;

        state = state.copyWith(
          questions: newQuestions,
          isLoading: false,
          error: null,
          totalCount: data.totalCount,
          currentPage: page,
          hasMore: hasMore,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Lỗi không xác định',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi kết nối: $e',
      );
    }
  }

  /// Refresh questions list
  Future<void> refresh(CauHoiFilter? filter) async {
    await loadQuestions(filter: filter, page: 1, refresh: true);
  }

  /// Load more questions (pagination)
  Future<void> loadMore(CauHoiFilter? filter) async {
    if (!state.hasMore || state.isLoading) return;
    await loadQuestions(filter: filter, page: state.currentPage + 1);
  }

  /// Add new question to list
  void addQuestion(CauHoi question) {
    state = state.copyWith(
      questions: [question, ...state.questions],
      totalCount: state.totalCount + 1,
    );
  }

  /// Update question in list
  void updateQuestion(CauHoi updatedQuestion) {
    final updatedQuestions = state.questions.map((q) {
      return q.macauhoi == updatedQuestion.macauhoi ? updatedQuestion : q;
    }).toList();

    state = state.copyWith(questions: updatedQuestions);
  }

  /// Remove question from list
  void removeQuestion(int questionId) {
    final updatedQuestions = state.questions.where((q) => q.macauhoi != questionId).toList();
    state = state.copyWith(
      questions: updatedQuestions,
      totalCount: state.totalCount - 1,
    );
  }

  /// Clear all questions
  void clear() {
    state = CauHoiListState();
  }
}

final cauHoiListProvider = StateNotifierProvider<CauHoiListNotifier, CauHoiListState>((ref) {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  return CauHoiListNotifier(cauHoiService);
});

/// Provider for question detail
final cauHoiDetailProvider = FutureProvider.family<CauHoi?, int>((ref, questionId) async {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  final response = await cauHoiService.getQuestionById(questionId);
  
  if (response.isSuccess) {
    return response.data;
  } else {
    throw Exception(response.error ?? 'Lỗi khi tải chi tiết câu hỏi');
  }
});

/// Provider for creating question
final createQuestionProvider = FutureProvider.family<int?, CauHoi>((ref, question) async {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  final response = await cauHoiService.createQuestion(question);
  
  if (response.isSuccess) {
    // Add to list
    ref.read(cauHoiListProvider.notifier).addQuestion(question);
    return response.data;
  } else {
    throw Exception(response.error ?? 'Lỗi khi tạo câu hỏi');
  }
});

/// Provider for updating question
final updateQuestionProvider = FutureProvider.family<bool, ({int id, CauHoi question})>((ref, params) async {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  final response = await cauHoiService.updateQuestion(params.id, params.question);
  
  if (response.isSuccess) {
    // Update in list
    ref.read(cauHoiListProvider.notifier).updateQuestion(params.question);
    return true;
  } else {
    throw Exception(response.error ?? 'Lỗi khi cập nhật câu hỏi');
  }
});

/// Provider for deleting question
final deleteQuestionProvider = FutureProvider.family<bool, int>((ref, questionId) async {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  final response = await cauHoiService.deleteQuestion(questionId);
  
  if (response.isSuccess) {
    // Remove from list
    ref.read(cauHoiListProvider.notifier).removeQuestion(questionId);
    return true;
  } else {
    throw Exception(response.error ?? 'Lỗi khi xóa câu hỏi');
  }
});

/// Provider for uploading image
final uploadImageProvider = FutureProvider.family<String?, XFile>((ref, imageFile) async {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  final response = await cauHoiService.uploadImage(imageFile);
  
  if (response.isSuccess) {
    return response.data;
  } else {
    throw Exception(response.error ?? 'Lỗi khi tải ảnh');
  }
});

/// Provider for image to base64 conversion
final imageToBase64Provider = FutureProvider.family<String, XFile>((ref, imageFile) async {
  final cauHoiService = ref.watch(cauHoiServiceProvider);
  return await cauHoiService.imageToBase64(imageFile);
});

/// Helper provider to get filtered questions
final filteredCauHoiProvider = Provider<List<CauHoi>>((ref) {
  final questionList = ref.watch(cauHoiListProvider);
  final filter = ref.watch(cauHoiFilterProvider);

  return questionList.questions.where((question) {
    if (filter.maMonHoc != null && question.monHocId != filter.maMonHoc) {
      return false;
    }
    if (filter.maChuong != null && question.chuongMucId != filter.maChuong) {
      return false;
    }
    if (filter.doKho != null && question.doKhoBackend != filter.doKho) {
      return false;
    }
    if (filter.keyword != null && filter.keyword!.isNotEmpty) {
      return question.noiDung.toLowerCase().contains(filter.keyword!.toLowerCase());
    }
    return true;
  }).toList();
});

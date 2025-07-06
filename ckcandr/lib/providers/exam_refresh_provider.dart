import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider để trigger refresh danh sách bài thi sau khi nộp bài
class ExamRefreshNotifier extends StateNotifier<int> {
  ExamRefreshNotifier() : super(0);

  /// Trigger refresh bằng cách tăng counter
  void triggerRefresh() {
    state = state + 1;
  }
}

/// Provider để quản lý refresh state
final examRefreshProvider = StateNotifierProvider<ExamRefreshNotifier, int>((ref) {
  return ExamRefreshNotifier();
});

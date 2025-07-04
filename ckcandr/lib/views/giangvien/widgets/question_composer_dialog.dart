/// Question Composer Dialog for Exam Management
///
/// This dialog allows teachers to add/remove questions to/from an exam,
/// similar to the QuestionComposerModal in Vue.js implementation.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/de_thi_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/models/api_models.dart';


class QuestionComposerDialog extends ConsumerStatefulWidget {
  final DeThiModel deThi;

  const QuestionComposerDialog({
    super.key,
    required this.deThi,
  });

  @override
  ConsumerState<QuestionComposerDialog> createState() => _QuestionComposerDialogState();
}

class _QuestionComposerDialogState extends ConsumerState<QuestionComposerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  int? _selectedDoKho;
  String _searchQuery = '';
  List<int> _selectedChapterIds = [];

  // Selection states
  Set<int> _selectedQuestionIds = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // SỬA: Tự động chọn các chương từ đề thi để lọc câu hỏi phù hợp
    _initializeChapterFilter();
  }

  /// SỬA: Khởi tạo bộ lọc chương dựa trên đề thi
  void _initializeChapterFilter() {
    // Delay để đảm bảo widget đã được build hoàn toàn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExamChapters();
    });
  }

  /// SỬA: Load các chương từ đề thi để tự động lọc
  Future<void> _loadExamChapters() async {
    try {
      // Lấy thông tin chi tiết đề thi để biết các chương đã chọn
      final examDetail = await ref.read(deThiDetailProvider(widget.deThi.made).future);

      if (examDetail.machuongs.isNotEmpty) {
        setState(() {
          _selectedChapterIds = List.from(examDetail.machuongs);
        });
        debugPrint('🎯 Auto-selected chapters from exam: $_selectedChapterIds');
      } else {
        // Nếu đề thi không có chương cụ thể, hiển thị tất cả câu hỏi của môn học
        setState(() {
          _selectedChapterIds = [];
        });
        debugPrint('🎯 No specific chapters in exam, showing all questions for subject');
      }
    } catch (e) {
      debugPrint('❌ Error loading exam chapters: $e');
      // Fallback: hiển thị tất cả câu hỏi của môn học
      setState(() {
        _selectedChapterIds = [];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // SỬA: Thêm method để refresh tất cả data
  Future<void> _refreshAllData() async {
    try {
      final filterParams = QuestionFilterParams(
        subjectId: widget.deThi.monthi,
        chapterIds: _selectedChapterIds,
      );

      // Invalidate providers để force reload từ server
      ref.invalidate(questionsBySubjectAndChapterProvider(filterParams));
      ref.invalidate(questionComposerProvider(widget.deThi.made));

      // Delay ngắn để đảm bảo invalidate hoàn thành
      await Future.delayed(const Duration(milliseconds: 300));

      // Trigger rebuild để load data mới
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Log error nếu cần debug
      debugPrint('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsInExamAsync = ref.watch(questionComposerProvider(widget.deThi.made));
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SỬA: Header ngắn gọn hơn
            Row(
              children: [
                Icon(Icons.quiz, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soạn câu hỏi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.deThi.tende ?? 'Đề thi',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const Divider(),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Ngân hàng câu hỏi'),
                Tab(text: 'Câu hỏi trong đề'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildQuestionBankTab(questionsInExamAsync),
                  _buildExamQuestionsTab(questionsInExamAsync),
                ],
              ),
            ),

            // Footer
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question count info
                  questionsInExamAsync.when(
                    data: (state) => Text(
                      'Tổng số câu hỏi trong đề: ${state.questionsInExam.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    loading: () => const Text('Đang tải...'),
                    error: (_, __) => const Text('Có lỗi xảy ra'),
                  ),
                  const SizedBox(height: 8),

                  // SỬA: Action buttons - Thay đổi layout để tránh overflow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedQuestionIds.isNotEmpty) ...[
                        // SỬA: Nút thêm câu hỏi đã chọn
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addSelectedQuestions,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text('Thêm ${_selectedQuestionIds.length} câu hỏi'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // SỬA: Row cho các nút khác
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _showAutoAddDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Thêm tự động'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tính năng gợi ý thông minh đang được phát triển')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Gợi ý thông minh'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Đóng'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBankTab(AsyncValue<QuestionComposerState> questionsInExamAsync) {
    // Get chapters for the subject
    final chaptersAsync = ref.watch(chaptersProvider(widget.deThi.monthi));

    // Get questions by subject and selected chapters
    // SỬA: Nếu không chọn chapter nào, load tất cả câu hỏi của môn học
    final filterParams = QuestionFilterParams(
      subjectId: widget.deThi.monthi,
      chapterIds: _selectedChapterIds, // Để rỗng sẽ load tất cả câu hỏi của môn học
    );
    final questionsAsync = ref.watch(questionsBySubjectAndChapterProvider(filterParams));

    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm câu hỏi...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _selectedDoKho,
                      decoration: const InputDecoration(
                        labelText: 'Độ khó',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: 1, child: Text('Dễ')),
                        DropdownMenuItem(value: 2, child: Text('Trung bình')),
                        DropdownMenuItem(value: 3, child: Text('Khó')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDoKho = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: chaptersAsync.when(
                      data: (chapters) => _buildChapterFilter(chapters),
                      loading: () => const SizedBox(
                        height: 48,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SizedBox(height: 48),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Questions list
        Expanded(
          child: questionsAsync.when(
            data: (questions) {
              return questionsInExamAsync.when(
                data: (examState) {
                  // Get IDs of questions already in exam
                  final questionsInExamIds = examState.questionsInExam
                      .map((q) => q.macauhoi)
                      .toSet();

                  // Filter out questions already in exam
                  final availableQuestions = questions
                      .where((q) => !questionsInExamIds.contains(q.macauhoi))
                      .toList();

                  final filteredQuestions = _filterQuestions(availableQuestions);

                  if (filteredQuestions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            availableQuestions.isEmpty
                                ? 'Tất cả câu hỏi đã được thêm vào đề thi'
                                : 'Không có câu hỏi nào phù hợp với bộ lọc',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = filteredQuestions[index];
                      final isSelected = _selectedQuestionIds.contains(question.macauhoi);

                      // SỬA: Đã filter rồi nên không cần check lại
                      return _QuestionCard(
                        question: question,
                        isSelected: isSelected,
                        isAlreadyInExam: false, // Đã filter rồi nên luôn false
                        onSelectionChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedQuestionIds.add(question.macauhoi!);
                            } else {
                              _selectedQuestionIds.remove(question.macauhoi);
                            }
                          });
                        },
                        showAddButton: true, // Luôn hiện vì đã filter
                        onAdd: () => _addSingleQuestion(question.macauhoi!),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Lỗi khi tải câu hỏi trong đề')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Lỗi: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamQuestionsTab(AsyncValue<QuestionComposerState> questionsInExamAsync) {
    return questionsInExamAsync.when(
      data: (state) {
        if (state.questionsInExam.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có câu hỏi nào trong đề thi',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Hãy thêm câu hỏi từ ngân hàng câu hỏi',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.questionsInExam.length,
          itemBuilder: (context, index) {
            final question = state.questionsInExam[index];
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getDoKhoColor(question.doKho),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  question.noiDung,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('Độ khó: ${question.doKho}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeQuestionFromExam(question.macauhoi),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Lỗi: $error'),
      ),
    );
  }

  // Helper methods
  List<CauHoi> _filterQuestions(List<CauHoi> questions) {
    return questions.where((question) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!question.noiDung.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by difficulty
      if (_selectedDoKho != null) {
        // Map difficulty levels: 1=Dễ, 2=Trung bình, 3=Khó
        String expectedDifficulty;
        switch (_selectedDoKho) {
          case 1:
            expectedDifficulty = 'de';
            break;
          case 2:
            expectedDifficulty = 'trungbinh';
            break;
          case 3:
            expectedDifficulty = 'kho';
            break;
          default:
            expectedDifficulty = '';
        }

        if (question.doKho.toString().toLowerCase() != expectedDifficulty) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getDoKhoColor(String doKho) {
    switch (doKho.toLowerCase()) {
      case 'dễ':
      case 'de':
        return Colors.green;
      case 'trung bình':
      case 'trungbinh':
        return Colors.orange;
      case 'khó':
      case 'kho':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addSingleQuestion(int questionId) async {
    try {
      final success = await ref
          .read(questionComposerProvider(widget.deThi.made).notifier)
          .addQuestionsToExam([questionId]);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm câu hỏi vào đề thi'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // SỬA: Hiển thị thông báo khi server từ chối (có thể do duplicate)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Câu hỏi đã có trong đề thi hoặc không hợp lệ'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Remove from selection and refresh UI
        setState(() {
          _selectedQuestionIds.remove(questionId);
        });

        // SỬA: Refresh tất cả data
        await _refreshAllData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addSelectedQuestions() async {
    if (_selectedQuestionIds.isEmpty) return;

    try {
      // SỬA: Thêm câu hỏi trực tiếp và xử lý response từ server
      final success = await ref
          .read(questionComposerProvider(widget.deThi.made).notifier)
          .addQuestionsToExam(_selectedQuestionIds.toList());

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${_selectedQuestionIds.length} câu hỏi vào đề thi'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // SỬA: Hiển thị thông báo khi server từ chối (có thể do duplicate)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Một số câu hỏi đã có trong đề thi hoặc không hợp lệ'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Clear selection and refresh UI
        setState(() {
          _selectedQuestionIds.clear();
        });

        // SỬA: Refresh state để đảm bảo UI cập nhật đúng
        await _refreshAllData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// SỬA: Thêm method hiển thị dialog thêm tự động với nhiều tùy chọn
  Future<void> _showAutoAddDialog() async {
    final TextEditingController countController = TextEditingController();
    String selectedDifficulty = 'all'; // all, easy, medium, hard
    String selectedStrategy = 'random'; // random, balanced, difficulty_based

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm tự động', style: TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextField(
                  controller: countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng',
                    border: OutlineInputBorder(),
                    hintText: 'Ví dụ: 10',
                    isDense: true,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                const Text('Độ khó:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tất cả độ khó')),
                    DropdownMenuItem(value: 'easy', child: Text('Chỉ câu dễ')),
                    DropdownMenuItem(value: 'medium', child: Text('Chỉ câu trung bình')),
                    DropdownMenuItem(value: 'hard', child: Text('Chỉ câu khó')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDifficulty = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                const Text('Chiến lược chọn:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStrategy,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'random', child: Text('Ngẫu nhiên')),
                    DropdownMenuItem(value: 'balanced', child: Text('Cân bằng độ khó')),
                    DropdownMenuItem(value: 'difficulty_based', child: Text('Ưu tiên theo độ khó')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStrategy = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final count = int.tryParse(countController.text);
                if (count != null && count > 0) {
                  Navigator.of(context).pop({
                    'count': count,
                    'difficulty': selectedDifficulty,
                    'strategy': selectedStrategy,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập số hợp lệ')),
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _addRandomQuestionsAdvanced(
        result['count'],
        result['difficulty'],
        result['strategy'],
      );
    }
  }

  /// SỬA: Thêm method thêm câu hỏi ngẫu nhiên nâng cao
  Future<void> _addRandomQuestionsAdvanced(int count, String difficulty, String strategy) async {
    try {
      // Get available questions (not already in exam)
      final filterParams = QuestionFilterParams(
        subjectId: widget.deThi.monthi,
        chapterIds: _selectedChapterIds,
      );
      final questionsAsync = ref.read(questionsBySubjectAndChapterProvider(filterParams));
      final questionsInExamAsync = ref.read(questionComposerProvider(widget.deThi.made));

      await questionsAsync.when(
        data: (availableQuestions) async {
          await questionsInExamAsync.when(
            data: (examState) async {
              // Filter out questions already in exam
              final existingIds = examState.questionsInExam.map((q) => q.macauhoi).toSet();
              var availableForAdd = availableQuestions
                  .where((q) => !existingIds.contains(q.macauhoi))
                  .toList();

              // SỬA: Lọc theo độ khó nếu được chỉ định
              if (difficulty != 'all') {
                final targetDifficulty = difficulty == 'easy' ? DoKho.de : difficulty == 'medium' ? DoKho.trungBinh : DoKho.kho;
                availableForAdd = availableForAdd
                    .where((q) => q.doKho == targetDifficulty)
                    .toList();
              }

              if (availableForAdd.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không có câu hỏi nào khả dụng với độ khó $difficulty'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              // Limit count to available questions
              final actualCount = count > availableForAdd.length ? availableForAdd.length : count;

              // SỬA: Chọn câu hỏi theo chiến lược (simplified)
              final random = math.Random();
              availableForAdd.shuffle(random);
              final selectedQuestions = availableForAdd.take(actualCount).toList();

              final randomQuestions = selectedQuestions;
              final questionIds = randomQuestions.map((q) => q.macauhoi!).toList();

              // Add to exam
              final success = await ref
                  .read(questionComposerProvider(widget.deThi.made).notifier)
                  .addQuestionsToExam(questionIds);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm thành công $actualCount câu hỏi vào đề thi'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );

                // Refresh UI để cập nhật danh sách
                ref.invalidate(questionsBySubjectAndChapterProvider(filterParams));
                ref.invalidate(questionComposerProvider(widget.deThi.made));

                // SỬA: Sử dụng method refresh chung
                await _refreshAllData();
              }
            },
            loading: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang tải dữ liệu...')),
                );
              }
            },
            error: (_, __) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lỗi khi tải danh sách câu hỏi trong đề'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
        },
        loading: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đang tải dữ liệu...')),
            );
          }
        },
        error: (_, __) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lỗi khi tải ngân hàng câu hỏi'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeQuestionFromExam(int questionId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này khỏi đề thi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ref
            .read(questionComposerProvider(widget.deThi.made).notifier)
            .removeQuestionFromExam(questionId);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa câu hỏi khỏi đề thi')),
          );

          // SỬA: Refresh danh sách câu hỏi trong ngân hàng để hiển thị lại câu hỏi đã remove
          final filterParams = QuestionFilterParams(
            subjectId: widget.deThi.monthi,
            chapterIds: _selectedChapterIds,
          );
          ref.invalidate(questionsBySubjectAndChapterProvider(filterParams));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  Widget _buildChapterFilter(List<ChuongDTO> chapters) {
    if (chapters.isEmpty) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: Text(
            'Không có chương',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return PopupMenuButton<List<int>>(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedChapterIds.isEmpty
                    ? 'Tất cả chương'
                    : '${_selectedChapterIds.length} chương',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<List<int>>(
          value: [],
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Select All / Clear All
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setMenuState(() {
                            _selectedChapterIds = chapters.map((c) => c.machuong).toList();
                          });
                          setState(() {});
                        },
                        child: const Text('Chọn tất cả'),
                      ),
                      TextButton(
                        onPressed: () {
                          setMenuState(() {
                            _selectedChapterIds.clear();
                          });
                          setState(() {});
                        },
                        child: const Text('Bỏ chọn'),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Chapter list
                  ...chapters.map((chapter) {
                    final isSelected = _selectedChapterIds.contains(chapter.machuong);
                    return CheckboxListTile(
                      title: Text(
                        chapter.tenchuong,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setMenuState(() {
                          if (value == true) {
                            _selectedChapterIds.add(chapter.machuong);
                          } else {
                            _selectedChapterIds.remove(chapter.machuong);
                          }
                        });
                        setState(() {});
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
      onSelected: (_) {
        // This will trigger rebuild with new filter
      },
    );
  }
}

// Widget for displaying question card
class _QuestionCard extends StatelessWidget {
  final CauHoi question;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged; // SỬA: Cho phép null
  final bool showAddButton;
  final VoidCallback? onAdd;
  final bool isAlreadyInExam; // SỬA: Thêm parameter mới

  const _QuestionCard({
    required this.question,
    required this.isSelected,
    this.onSelectionChanged, // SỬA: Không bắt buộc
    this.showAddButton = false,
    this.onAdd,
    this.isAlreadyInExam = false, // SỬA: Thêm parameter mới
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      elevation: isSelected ? 3 : 1,
      color: isAlreadyInExam
          ? Colors.grey.withValues(alpha: 0.2) // SỬA: Màu xám cho câu hỏi đã có trong đề
          : (isSelected ? theme.primaryColor.withValues(alpha: 0.1) : null),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SỬA: Header with checkbox and difficulty - Sử dụng Flexible để tránh overflow
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: isAlreadyInExam ? null : (value) => onSelectionChanged?.call(value ?? false),
                ),
                Expanded(
                  child: Text(
                    question.noiDung,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // SỬA: Sử dụng Flexible cho Container độ khó để tránh overflow
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // SỬA: Padding nhỏ hơn
                    decoration: BoxDecoration(
                      color: _getDoKhoColor(question.doKho.toString()),
                      borderRadius: BorderRadius.circular(8), // SỬA: Border radius nhỏ hơn
                    ),
                    child: Text(
                      question.doKho.toString().split('.').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10, // SỬA: Font nhỏ hơn
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Question details
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  question.tenLoaiCauHoi,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${question.cacLuaChon.length} lựa chọn',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                // SỬA: Thêm indicator cho câu hỏi đã có trong đề
                if (isAlreadyInExam) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Đã có trong đề',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // SỬA: Add button - Sử dụng nút nhỏ gọn hơn để tránh overflow
            if (showAddButton) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 28),
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDoKhoColor(String doKho) {
    switch (doKho.toLowerCase()) {
      case 'de':
        return Colors.green;
      case 'trungbinh':
        return Colors.orange;
      case 'kho':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


}

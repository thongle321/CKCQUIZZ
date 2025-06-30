/// Question Composer Dialog for Exam Management
/// 
/// This dialog allows teachers to add/remove questions to/from an exam,
/// similar to the QuestionComposerModal in Vue.js implementation.

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soạn thảo câu hỏi',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đề thi: ${widget.deThi.tende}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
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

                  // Action buttons
                  Row(
                    children: [
                      if (_selectedQuestionIds.isNotEmpty) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addSelectedQuestions,
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              'Thêm ${_selectedQuestionIds.length} câu hỏi',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Đóng'),
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

                      // SỬA: Kiểm tra xem câu hỏi đã có trong đề thi chưa
                      final isAlreadyInExam = questionsInExamAsync.when(
                        data: (state) => state.questionsInExam
                            .any((q) => q.macauhoi == question.macauhoi),
                        loading: () => false,
                        error: (_, __) => false,
                      );

                      return _QuestionCard(
                        question: question,
                        isSelected: isSelected,
                        isAlreadyInExam: isAlreadyInExam, // SỬA: Thêm flag này
                        onSelectionChanged: isAlreadyInExam ? null : (selected) {
                          setState(() {
                            if (selected) {
                              _selectedQuestionIds.add(question.macauhoi!);
                            } else {
                              _selectedQuestionIds.remove(question.macauhoi);
                            }
                          });
                        },
                        showAddButton: !isAlreadyInExam, // SỬA: Chỉ hiện nút Add nếu chưa có trong đề
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

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm câu hỏi vào đề thi'),
            duration: Duration(seconds: 2),
          ),
        );

        // Remove from selection and refresh UI
        setState(() {
          _selectedQuestionIds.remove(questionId);
        });

        // SỬA: Refresh danh sách câu hỏi trong ngân hàng để ẩn câu hỏi đã thêm
        final filterParams = QuestionFilterParams(
          subjectId: widget.deThi.monthi,
          chapterIds: _selectedChapterIds,
        );
        ref.invalidate(questionsBySubjectAndChapterProvider(filterParams));
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

    final count = _selectedQuestionIds.length;

    try {
      final success = await ref
          .read(questionComposerProvider(widget.deThi.made).notifier)
          .addQuestionsToExam(_selectedQuestionIds.toList());

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm $count câu hỏi vào đề thi'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Clear selection and refresh UI
        setState(() {
          _selectedQuestionIds.clear();
        });

        // SỬA: Refresh danh sách câu hỏi trong ngân hàng để ẩn câu hỏi đã thêm
        final filterParams = QuestionFilterParams(
          subjectId: widget.deThi.monthi,
          chapterIds: _selectedChapterIds,
        );
        ref.invalidate(questionsBySubjectAndChapterProvider(filterParams));
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
            // Header with checkbox and difficulty
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDoKhoColor(question.doKho.toString()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.doKho.toString().split('.').last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

            // Add button
            if (showAddButton) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm vào đề'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

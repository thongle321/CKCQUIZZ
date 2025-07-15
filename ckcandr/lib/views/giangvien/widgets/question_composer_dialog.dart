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
import 'package:ckcandr/providers/cau_hoi_api_provider.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';


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
  List<int> _tempSelectedChapterIds = []; // State tạm thời cho popup
  bool _showMyQuestionsOnly = false; // Mặc định hiển thị tất cả câu hỏi trong dialog
  Map<int, String> _chapterIdToNameMap = {}; // SỬA: Mapping từ ID chương sang tên chương

  // Selection states
  Set<int> _selectedQuestionIds = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // SỬA: Bắt đầu với không chọn chương nào (hiển thị tất cả câu hỏi)
    // Không tự động load chương từ đề thi để tránh nhầm lẫn
    debugPrint('🎯 Question composer initialized with no chapter filter (show all questions)');

    // Load initial questions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyQuestions();
    });
  }

  /// Load my created questions with current filter
  void _loadMyQuestions() {
    if (!_showMyQuestionsOnly) return;

    // SỬA: Không filter theo chương ở API level, để client tự filter
    // Vì API chỉ hỗ trợ 1 chương, nhưng UI cho phép chọn nhiều chương
    final filter = CauHoiFilter(
      maMonHoc: widget.deThi.monthi,
      maChuong: null, // Luôn null để lấy tất cả câu hỏi của môn học
    );

    ref.read(myCreatedQuestionsProvider.notifier).refresh(filter);
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
        showMyQuestionsOnly: _showMyQuestionsOnly,
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
      // Ignore error during refresh
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
                      'Tổng: ${state.questionsInExam.length} câu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
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

                      // Nút đóng
                      SizedBox(
                        width: double.infinity,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBankTab(AsyncValue<QuestionComposerState> questionsInExamAsync) {
    // Get chapters for the subject
    final chaptersAsync = ref.watch(chaptersProvider(widget.deThi.monthi));

    // SỬA: Sử dụng provider tương tự như phần "Quản lý câu hỏi"
    AsyncValue<List<CauHoi>> questionsAsync;

    if (_showMyQuestionsOnly) {
      // Sử dụng myCreatedQuestionsProvider cho câu hỏi bản thân
      final myQuestionsState = ref.watch(myCreatedQuestionsProvider);
      questionsAsync = AsyncValue.data(myQuestionsState.questions);
    } else {
      // Sử dụng provider cũ cho tất cả câu hỏi
      final filterParams = QuestionFilterParams(
        subjectId: widget.deThi.monthi,
        chapterIds: _selectedChapterIds,
        showMyQuestionsOnly: false,
      );
      questionsAsync = ref.watch(questionsBySubjectAndChapterProvider(filterParams));
    }

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
              // Switch để chuyển đổi giữa câu hỏi của tôi và tất cả câu hỏi
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Hiển thị câu hỏi GV khác',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  Switch(
                    value: !_showMyQuestionsOnly,
                    onChanged: (value) {
                      setState(() {
                        _showMyQuestionsOnly = !value;
                      });
                      // Load lại câu hỏi với filter mới
                      _loadMyQuestions();
                    },
                  ),
                ],
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
                      data: (chapters) {
                        // SỬA: Populate mapping từ ID chương sang tên chương
                        _chapterIdToNameMap = {
                          for (var chapter in chapters) chapter.machuong: chapter.tenchuong
                        };
                        debugPrint('🗺️ Chapter ID to Name mapping: $_chapterIdToNameMap');
                        return _buildChapterFilter(chapters);
                      },
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
                                ? 'Tất cả câu hỏi đã được thêm'
                                : 'Không có câu hỏi phù hợp',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                  'Đề thi rỗng',
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
    debugPrint('🔍 Filtering ${questions.length} questions with selectedChapterIds: $_selectedChapterIds');

    // Debug: In ra thông tin của câu hỏi đầu tiên để kiểm tra cấu trúc
    if (questions.isNotEmpty) {
      final firstQuestion = questions.first;
      debugPrint('🔍 First question structure: macauhoi=${firstQuestion.macauhoi}, chuongMucId=${firstQuestion.chuongMucId}, tenChuong=${firstQuestion.tenChuong}');

      // Debug thêm: kiểm tra mapping
      if (_selectedChapterIds.isNotEmpty) {
        debugPrint('🔍 Chapter mapping debug:');
        for (final id in _selectedChapterIds) {
          final name = _chapterIdToNameMap[id];
          debugPrint('   ID $id -> Name "$name"');
          if (firstQuestion.tenChuong != null) {
            debugPrint('   Question chapter: "${firstQuestion.tenChuong}"');
            debugPrint('   Equals check: "${firstQuestion.tenChuong}" == "$name" = ${firstQuestion.tenChuong == name}');
          }
        }
      }
    } else {
      debugPrint('🔍 No questions to filter!');
    }

    final filtered = questions.where((question) {
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

      // SỬA: Filter by selected chapters
      // Nếu có chọn chương cụ thể thì chỉ hiển thị câu hỏi thuộc các chương đó
      if (_selectedChapterIds.isNotEmpty) {
        bool passesChapterFilter = false;

        debugPrint('🔍 Question ${question.macauhoi} - filter check: chuongMucId=${question.chuongMucId}, tenChuong=${question.tenChuong}');

        // SỬA: Logic filter chương đơn giản và chính xác
        // Trường hợp 1: Câu hỏi có chuongMucId (ID chương) - từ API thông thường
        if (question.chuongMucId != null) {
          passesChapterFilter = _selectedChapterIds.contains(question.chuongMucId!);
        }
        // Trường hợp 2: Câu hỏi có tenChuong (tên chương) - từ API my-created-questions
        else if (question.tenChuong != null && question.tenChuong!.isNotEmpty) {
          // Lấy danh sách tên chương từ các ID đã chọn
          final selectedChapterNames = _selectedChapterIds
              .map((id) => _chapterIdToNameMap[id])
              .where((name) => name != null && name.isNotEmpty)
              .cast<String>()
              .toList();

          // So sánh tên chương (case-insensitive và trim whitespace)
          final questionChapterName = question.tenChuong!.trim().toLowerCase();
          passesChapterFilter = selectedChapterNames.any((name) =>
            name.trim().toLowerCase() == questionChapterName
          );
        }

        // Nếu không pass filter thì loại bỏ
        if (!passesChapterFilter) {
          return false;
        }
      }

      return true;
    }).toList();

    debugPrint('✅ Filtered result: ${filtered.length} questions');
    return filtered;
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
          await SuccessDialog.show(
            context,
            message: 'Đã thêm ${_selectedQuestionIds.length} câu hỏi vào đề thi',
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
        await ErrorDialog.show(
          context,
          message: 'Lỗi: ${e.toString()}',
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
          await SuccessDialog.show(
            context,
            message: 'Đã xóa câu hỏi khỏi đề thi',
          );

          // SỬA: Refresh danh sách câu hỏi trong ngân hàng để hiển thị lại câu hỏi đã remove
          final filterParams = QuestionFilterParams(
            subjectId: widget.deThi.monthi,
            chapterIds: _selectedChapterIds,
            showMyQuestionsOnly: _showMyQuestionsOnly,
          );
          ref.invalidate(questionsBySubjectAndChapterProvider(filterParams));
        }
      } catch (e) {
        if (mounted) {
          await ErrorDialog.show(
            context,
            message: 'Lỗi: ${e.toString()}',
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
                    ? 'Chương'
                    : '${_selectedChapterIds.length} chương',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      onOpened: () {
        // Khởi tạo state tạm thời khi mở popup
        _tempSelectedChapterIds = List.from(_selectedChapterIds);
      },
      itemBuilder: (context) => [
        PopupMenuItem<List<int>>(
          value: [],
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return SizedBox(
                width: 280,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header với nút chọn tất cả / bỏ chọn
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setMenuState(() {
                              _tempSelectedChapterIds = chapters.map((c) => c.machuong).toList();
                            });
                          },
                          child: const Text('Chọn tất cả', style: TextStyle(fontSize: 12)),
                        ),
                        TextButton(
                          onPressed: () {
                            setMenuState(() {
                              _tempSelectedChapterIds.clear();
                            });
                          },
                          child: const Text('Bỏ chọn', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    // Chapter list với max height
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          children: chapters.map((chapter) {
                            final isSelected = _tempSelectedChapterIds.contains(chapter.machuong);
                            return CheckboxListTile(
                              title: Text(
                                chapter.tenchuong,
                                style: const TextStyle(fontSize: 13),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setMenuState(() {
                                  if (value == true) {
                                    _tempSelectedChapterIds.add(chapter.machuong);
                                  } else {
                                    _tempSelectedChapterIds.remove(chapter.machuong);
                                  }
                                });
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Nút xác nhận
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Hủy', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedChapterIds = List.from(_tempSelectedChapterIds);
                            });
                            Navigator.of(context).pop();

                            // SỬA: Invalidate tất cả providers để force reload
                            _refreshAllData();

                            // Load lại câu hỏi với filter mới
                            _loadMyQuestions();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Áp dụng', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

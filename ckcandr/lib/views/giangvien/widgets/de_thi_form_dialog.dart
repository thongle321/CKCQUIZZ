/// Form Dialog for Creating/Editing Exams (Đề Kiểm Tra)
/// 
/// This dialog provides a comprehensive form for teachers to create new exams
/// or edit existing ones, based on the Vue.js implementation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/providers/de_thi_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:intl/intl.dart';
import 'exam_status_toggle.dart';
import 'package:ckcandr/core/utils/message_utils.dart';

class DeThiFormDialog extends ConsumerStatefulWidget {
  final DeThiModel? deThi; // null = create, not null = edit

  const DeThiFormDialog({
    super.key,
    this.deThi,
  });

  @override
  ConsumerState<DeThiFormDialog> createState() => _DeThiFormDialogState();
}

class _DeThiFormDialogState extends ConsumerState<DeThiFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _tenDeController = TextEditingController();
  final _thoiGianThiController = TextEditingController();
  final _soCauDeController = TextEditingController();
  final _soCauTBController = TextEditingController();
  final _soCauKhoController = TextEditingController();
  
  // Form state
  DateTime? _thoiGianBatDau;
  DateTime? _thoiGianKetThuc;
  int? _selectedMonHocId;
  List<int> _selectedChuongIds = [];
  List<int> _selectedLopIds = [];
  
  // Settings
  bool _xemDiemThi = true;
  bool _hienThiBaiLam = false;
  bool _xemDapAn = false;
  bool _tronCauHoi = true;
  bool _trangThai = true; // Mặc định bật đề thi
  LoaiDe _loaiDe = LoaiDe.tuDong;
  
  bool get isEditing => widget.deThi != null;

  // Track if data has been loaded to prevent multiple loads
  bool _dataLoaded = false;

  /// Check if exam is currently active (during exam period)
  bool get isExamActive {
    if (!isEditing || _thoiGianBatDau == null || _thoiGianKetThuc == null) {
      return false;
    }

    final now = TimezoneHelper.nowInVietnam();
    return now.isAfter(_thoiGianBatDau!) && now.isBefore(_thoiGianKetThuc!);
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (isEditing) {
      // Load existing exam data - delay to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(deThiFormProvider.notifier).startEdit(widget.deThi!.made);
      });
    } else {
      // Initialize for new exam - delay to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(deThiFormProvider.notifier).startCreate();
      });
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    _thoiGianThiController.text = '60'; // Default 60 minutes
    _soCauDeController.text = '5';
    _soCauTBController.text = '10';
    _soCauKhoController.text = '5';

    // Set default time to tomorrow at 8:00 AM
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _thoiGianBatDau = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
    _thoiGianKetThuc = _thoiGianBatDau!.add(const Duration(hours: 2));

    // SỬA: Auto-select exam type based on intelligent logic
    _autoSelectExamType();
  }

  /// SỬA: Thêm logic tự động chọn loại đề thi thông minh
  void _autoSelectExamType() {
    // Logic thông minh để chọn loại đề thi:
    // 1. Nếu có nhiều chương được chọn (>= 3) -> Tự động (dễ tạo đề đa dạng)
    // 2. Nếu thời gian thi ngắn (<= 30 phút) -> Tự động (nhanh chóng)
    // 3. Nếu số lượng câu hỏi mong muốn lớn (>= 20) -> Tự động
    // 4. Mặc định -> Tự động (phù hợp với hầu hết trường hợp)

    final examDuration = int.tryParse(_thoiGianThiController.text) ?? 60;
    final totalQuestions = (int.tryParse(_soCauDeController.text) ?? 5) +
                          (int.tryParse(_soCauTBController.text) ?? 10) +
                          (int.tryParse(_soCauKhoController.text) ?? 5);

    // Mặc định chọn tự động vì:
    // - Tiết kiệm thời gian cho giảng viên
    // - Đảm bảo tính ngẫu nhiên và công bằng
    // - Phù hợp với hầu hết các kỳ thi
    _loaiDe = LoaiDe.tuDong;

    debugPrint('🎯 Auto-selected exam type: ${_loaiDe.displayName} (Duration: ${examDuration}min, Questions: $totalQuestions)');
  }

  /// SỬA: Logic tự động chọn loại đề thi dựa trên context hiện tại
  void _autoSelectExamTypeBasedOnContext() {
    final examDuration = int.tryParse(_thoiGianThiController.text) ?? 60;
    final totalQuestions = (int.tryParse(_soCauDeController.text) ?? 5) +
                          (int.tryParse(_soCauTBController.text) ?? 10) +
                          (int.tryParse(_soCauKhoController.text) ?? 5);
    final selectedChaptersCount = _selectedChuongIds.length;

    // Logic thông minh:
    // 1. Nếu có nhiều chương (>= 3) và nhiều câu hỏi (>= 15) -> Tự động
    // 2. Nếu thời gian thi dài (>= 90 phút) và ít chương (<= 2) -> Có thể thủ công
    // 3. Nếu thời gian thi ngắn (<= 45 phút) -> Tự động (nhanh chóng)
    // 4. Mặc định -> Tự động

    if (selectedChaptersCount >= 3 && totalQuestions >= 15) {
      _loaiDe = LoaiDe.tuDong;
      debugPrint('🎯 Auto-selected TỰ ĐỘNG: Nhiều chương ($selectedChaptersCount) và nhiều câu hỏi ($totalQuestions)');
    } else if (examDuration >= 90 && selectedChaptersCount <= 2 && totalQuestions <= 10) {
      _loaiDe = LoaiDe.thuCong;
      debugPrint('🎯 Auto-selected THỦ CÔNG: Thời gian dài (${examDuration}min), ít chương ($selectedChaptersCount), ít câu hỏi ($totalQuestions)');
    } else if (examDuration <= 45) {
      _loaiDe = LoaiDe.tuDong;
      debugPrint('🎯 Auto-selected TỰ ĐỘNG: Thời gian ngắn (${examDuration}min)');
    } else {
      _loaiDe = LoaiDe.tuDong;
      debugPrint('🎯 Auto-selected TỰ ĐỘNG: Mặc định (Duration: ${examDuration}min, Chapters: $selectedChaptersCount, Questions: $totalQuestions)');
    }
  }

  /// SỬA: Tự động xóa câu hỏi thuộc chương bị bỏ chọn
  Future<void> _autoRemoveQuestionsFromDeselectedChapters(int examId) async {
    try {
      if (!isEditing) return; // Chỉ áp dụng khi chỉnh sửa đề thi

      // Lấy thông tin đề thi hiện tại để so sánh chương
      final currentExamDetail = await ref.read(deThiDetailProvider(examId).future);
      final originalChapterIds = Set<int>.from(currentExamDetail.machuongs);
      final newChapterIds = Set<int>.from(_selectedChuongIds);

      // Tìm các chương bị bỏ chọn
      final deselectedChapterIds = originalChapterIds.difference(newChapterIds);

      if (deselectedChapterIds.isEmpty) {
        debugPrint('🎯 No chapters deselected, no questions to remove');
        return;
      }



      // Lấy danh sách câu hỏi hiện tại trong đề thi
      final questionsInExamAsync = ref.read(questionComposerProvider(examId));

      // Tìm câu hỏi thuộc các chương bị bỏ chọn
      final questionsToRemove = <int>[];

      await questionsInExamAsync.when(
        data: (questionsState) async {
          // Lấy thông tin chi tiết của từng câu hỏi để biết chúng thuộc chương nào
          try {
            // Lấy tất cả câu hỏi của môn học để tìm thông tin chương
            final allQuestions = await ref.read(questionsBySubjectProvider(currentExamDetail.monthi!).future);

            for (final question in questionsState.questionsInExam) {
              try {
                // Tìm câu hỏi tương ứng trong danh sách đầy đủ
                final fullQuestion = allQuestions.firstWhere(
                  (q) => q.macauhoi == question.macauhoi,
                  orElse: () => throw Exception('Question not found'),
                );

                // Kiểm tra xem câu hỏi có thuộc chương bị bỏ chọn không
                if (fullQuestion.chuongMucId != null && deselectedChapterIds.contains(fullQuestion.chuongMucId)) {
                  questionsToRemove.add(question.macauhoi);
                  debugPrint('🗑️ Question ${question.macauhoi} belongs to deselected chapter ${fullQuestion.chuongMucId}');
                }
              } catch (e) {
                debugPrint('❌ Error checking question ${question.macauhoi}: $e');
              }
            }
          } catch (e) {
            debugPrint('❌ Error loading all questions for subject: $e');
          }
        },
        loading: () async {
          // Questions still loading
        },
        error: (error, stack) async {
          // Error loading questions
        },
      );

      if (questionsToRemove.isEmpty) {
        return;
      }

      // Xóa từng câu hỏi
      int removedCount = 0;
      for (final questionId in questionsToRemove) {
        try {
          final success = await ref
              .read(questionComposerProvider(examId).notifier)
              .removeQuestionFromExam(questionId);
          if (success) {
            removedCount++;
          }
        } catch (e) {
          // Error removing question
        }
      }

      if (removedCount > 0 && mounted) {
        await MessageUtils.showInfo(
          context,
          title: 'Cập nhật câu hỏi',
          message: 'Đã tự động xóa $removedCount câu hỏi thuộc chương bị bỏ chọn khỏi đề thi.',
        );
      }

      debugPrint('✅ Auto-removed $removedCount questions from deselected chapters');
    } catch (e) {
      debugPrint('❌ Error in auto-remove questions: $e');
      if (mounted) {
        await MessageUtils.showError(
          context,
          title: 'Lỗi cập nhật câu hỏi',
          message: 'Không thể tự động xóa câu hỏi. Vui lòng thử lại sau.',
        );
      }
    }
  }

  @override
  void dispose() {
    _tenDeController.dispose();
    _thoiGianThiController.dispose();
    _soCauDeController.dispose();
    _soCauTBController.dispose();
    _soCauKhoController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(deThiFormProvider);
    final assignedSubjects = ref.watch(assignedSubjectsProvider);
    final lopHocList = ref.watch(lopHocListProvider);
    
    // Watch chapters for selected subject
    final chaptersAsync = _selectedMonHocId == null
        ? const AsyncValue<List<ChuongDTO>>.data([])
        : ref.watch(chaptersProvider(_selectedMonHocId));

    // Debug form state
    debugPrint('🔍 Form State - isEditing: $isEditing, isEditMode: ${formState.isEditMode}, hasData: ${formState.editingDeThi != null}, dataLoaded: $_dataLoaded');

    // Load form data if editing
    if (isEditing && formState.isEditMode && formState.editingDeThi != null && !_dataLoaded) {
      _loadEditingData(formState.editingDeThi!);
    }

    // Show error if any
    if (formState.error != null) {
      debugPrint('❌ Form Error: ${formState.error}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageUtils.showError(
          context,
          title: 'Lỗi xử lý đề thi',
          message: formState.error!,
        );
        ref.read(deThiFormProvider.notifier).clearError();
      });
    }

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92, // SỬA: Giảm width
        height: MediaQuery.of(context).size.height * 0.80, // SỬA: Giảm height
        padding: const EdgeInsets.all(12), // SỬA: Giảm padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SỬA: Header ngắn gọn hơn
            Row(
              children: [
                Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEditing ? 'Sửa đề thi' : 'Tạo đề thi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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

            // Warning message when exam is active
            if (isExamActive) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đề thi đang diễn ra',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const Text(
                            'Chỉ có thể bật/tắt đề thi. Không thể sửa các thông tin khác.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎯 TRẠNG THÁI ĐỀ THI (hiển thị cho cả tạo mới và sửa)
                      _buildExamStatusSection(),
                      const SizedBox(height: 16),
                      // Basic info section
                      _buildBasicInfoSection(assignedSubjects, chaptersAsync),
                      const SizedBox(height: 16),
                      // SỬA: Settings section - chỉ hiển thị khi tạo mới (disable hoàn toàn khi edit)
                      if (!isEditing)
                        _buildSettingsSection(lopHocList),
                    ],
                  ),
                ),
              ),
            ),

            // Footer buttons
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: formState.isLoading ? null : _handleSubmit,
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Cập nhật' : 'Tạo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(
    AsyncValue<List<MonHocDTO>> assignedSubjects,
    AsyncValue<List<ChuongDTO>> chaptersAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),


            // Exam name - SỬA: Luôn cho phép edit tên đề (1/3 thông tin cơ bản)
            TextFormField(
              controller: _tenDeController,
              decoration: const InputDecoration(
                labelText: 'Tên đề *',
                border: OutlineInputBorder(),
                hintText: 'Kiểm tra cuối kỳ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên đề thi';
                }
                return null;
              },
            ),
            const SizedBox(height: 8), // SỬA: Giảm khoảng cách

            // Time range - SỬA: Luôn cho phép edit thời gian thi (2/3 thông tin cơ bản)
            _buildTimeRangeField(),
            const SizedBox(height: 8),

            // Exam duration - SỬA: Luôn cho phép edit thời gian làm bài (3/3 thông tin cơ bản)
            TextFormField(
              controller: _thoiGianThiController,
              decoration: const InputDecoration(
                labelText: 'Thời gian *',
                border: OutlineInputBorder(),
                suffixText: 'phút',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                // SỬA: Auto-select exam type when duration changes
                if (!isEditing && value.isNotEmpty) {
                  _autoSelectExamTypeBasedOnContext();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập thời gian làm bài';
                }
                final time = int.tryParse(value);
                if (time == null || time <= 0) {
                  return 'Thời gian phải là số dương';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Subject selection - chỉ hiển thị khi tạo mới
            if (!isEditing) ...[
              assignedSubjects.when(
                data: (subjects) => _buildSubjectDropdown(subjects),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
              const SizedBox(height: 10),

              // Chapters selection
              chaptersAsync.when(
                data: (chapters) => _buildChaptersSelection(chapters),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(AsyncValue<List<LopHoc>> lopHocList) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Exam type
            IgnorePointer(
              ignoring: isExamActive, // Disable during active exam
              child: Opacity(
                opacity: isExamActive ? 0.5 : 1.0,
                child: _buildExamTypeSelection(),
              ),
            ),
            const SizedBox(height: 12),

            // Question counts (only for automatic type)
            if (_loaiDe == LoaiDe.tuDong) ...[
              IgnorePointer(
                ignoring: isExamActive, // Disable during active exam
                child: Opacity(
                  opacity: isExamActive ? 0.5 : 1.0,
                  child: _buildQuestionCountFields(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // SỬA: Thông báo hướng dẫn cho thủ công
            if (_loaiDe == LoaiDe.thuCong) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chế độ thủ công: Sau khi tạo đề thi, bạn sẽ chọn câu hỏi từ ngân hàng câu hỏi của môn học.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Class selection
            IgnorePointer(
              ignoring: isExamActive, // Disable during active exam
              child: Opacity(
                opacity: isExamActive ? 0.5 : 1.0,
                child: lopHocList.when(
                  data: (classes) => _buildClassSelection(classes),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Lỗi: $error'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Exam settings
            IgnorePointer(
              ignoring: isExamActive, // Disable during active exam
              child: Opacity(
                opacity: isExamActive ? 0.5 : 1.0,
                child: _buildExamSettings(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeField() {
    return InkWell(
      onTap: isExamActive ? null : _selectTimeRange, // Disable during active exam
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Lịch thi *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, size: 16),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // SỬA: Giảm padding
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Text(
                _thoiGianBatDau != null && _thoiGianKetThuc != null
                    ? '${DateFormat('dd/MM HH:mm').format(_thoiGianBatDau!)}\n- ${DateFormat('dd/MM HH:mm').format(_thoiGianKetThuc!)} (GMT+7)'
                    : 'Chọn thời gian diễn ra (GMT+7)',
                style: TextStyle(
                  fontSize: 11, // SỬA: Giảm font size hơn nữa
                  color: isExamActive
                      ? Colors.grey[400]
                      : (_thoiGianBatDau != null ? null : Colors.grey[600]),
                ),
                overflow: TextOverflow.ellipsis, // SỬA: Thêm ellipsis
                maxLines: 2, // SỬA: Cho phép 2 dòng
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown(List<MonHocDTO> subjects) {
    // Ensure selected value exists in the list
    final validSelectedId = _selectedMonHocId != null &&
        subjects.any((s) => s.mamonhoc == _selectedMonHocId)
        ? _selectedMonHocId
        : null;

    return DropdownButtonFormField<int>(
      value: validSelectedId,
      decoration: const InputDecoration(
        labelText: 'Môn học *',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // SỬA: Giảm padding
      ),
      // SỬA: Custom hiển thị giá trị đã chọn với ellipsis
      selectedItemBuilder: (BuildContext context) {
        return subjects.map<Widget>((subject) {
          return Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(maxWidth: 150), // SỬA: Giảm width hơn nữa
            child: Text(
              subject.tenmonhoc,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12), // SỬA: Giảm font size hơn nữa
              maxLines: 1,
            ),
          );
        }).toList();
      },
      items: subjects.map((subject) {
        return DropdownMenuItem<int>(
          value: subject.mamonhoc,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200), // SỬA: Giảm width hơn nữa
            child: Text(
              subject.tenmonhoc,
              overflow: TextOverflow.ellipsis, // SỬA: Tránh overflow
              style: const TextStyle(fontSize: 12), // SỬA: Giảm font size hơn nữa
              maxLines: 1, // SỬA: Chỉ hiển thị 1 dòng
            ),
          ),
        );
      }).toList(),
      onChanged: isExamActive ? null : (value) { // Disable during active exam
        setState(() {
          _selectedMonHocId = value;
          _selectedChuongIds.clear(); // Clear chapters when subject changes
          // SỬA: Auto-select exam type when subject changes
          if (!isEditing) {
            _autoSelectExamTypeBasedOnContext();
          }
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn môn học';
        }
        return null;
      },
    );
  }

  Widget _buildChaptersSelection(List<ChuongDTO> chapters) {
    if (chapters.isEmpty) {
      return const Text('Không có chương nào cho môn học này');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Chương *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isExamActive) ...[
              const SizedBox(width: 8),
              const Icon(Icons.lock, color: Colors.orange, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (isExamActive)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Đang thi - không thể sửa',
              style: TextStyle(color: Colors.orange, fontSize: 14),
            ),
          )
        else
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return CheckboxListTile(
                  title: Text(
                    chapter.tenchuong,
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: _selectedChuongIds.contains(chapter.machuong),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedChuongIds.add(chapter.machuong);
                      } else {
                        _selectedChuongIds.remove(chapter.machuong);
                      }
                      // SỬA: Auto-select exam type when chapters change
                      if (!isEditing) {
                        _autoSelectExamTypeBasedOnContext();
                      }
                    });
                  },
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExamTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại đề *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        // SỬA: Dùng Column thay vì Row để tránh overflow
        ...LoaiDe.values.map((type) {
          return RadioListTile<LoaiDe>(
            title: Text(
              type.displayName,
              style: const TextStyle(fontSize: 14), // SỬA: Giảm font size
            ),
            value: type,
            groupValue: _loaiDe,
            onChanged: (LoaiDe? value) {
              setState(() {
                _loaiDe = value!;
                // RESET khi chuyển loại đề
                if (value == LoaiDe.thuCong) {
                  _selectedChuongIds.clear();
                  _soCauDeController.clear();
                  _soCauTBController.clear();
                  _soCauKhoController.clear();
                }
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero, // SỬA: Bỏ padding để tiết kiệm không gian
          );
        }),
      ],
    );
  }

  Widget _buildQuestionCountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số lượng câu hỏi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        // SỬA: Dùng Column thay vì Row để tránh overflow
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _soCauDeController,
                    decoration: const InputDecoration(
                      labelText: 'Dễ',
                      border: OutlineInputBorder(),
                      isDense: true, // SỬA: Compact hơn
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      // SỬA: Auto-select exam type when question count changes
                      if (!isEditing && value.isNotEmpty) {
                        _autoSelectExamTypeBasedOnContext();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Bắt buộc';
                      final num = int.tryParse(value);
                      if (num == null || num < 0) return 'Số không hợp lệ';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _soCauTBController,
                    decoration: const InputDecoration(
                      labelText: 'TB',
                      border: OutlineInputBorder(),
                      isDense: true, // SỬA: Compact hơn
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      // SỬA: Auto-select exam type when question count changes
                      if (!isEditing && value.isNotEmpty) {
                        _autoSelectExamTypeBasedOnContext();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Bắt buộc';
                      final num = int.tryParse(value);
                      if (num == null || num < 0) return 'Số không hợp lệ';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _soCauKhoController,
                    decoration: const InputDecoration(
                      labelText: 'Khó',
                      border: OutlineInputBorder(),
                      isDense: true, // SỬA: Compact hơn
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      // SỬA: Auto-select exam type when question count changes
                      if (!isEditing && value.isNotEmpty) {
                        _autoSelectExamTypeBasedOnContext();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Bắt buộc';
                      final num = int.tryParse(value);
                      if (num == null || num < 0) return 'Số không hợp lệ';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassSelection(List<LopHoc> classes) {
    // Filter classes by selected subject
    final filteredClasses = _selectedMonHocId == null
        ? <LopHoc>[]
        : classes.where((lop) =>
            lop.monhocs.any((monhoc) =>
              monhoc.toLowerCase().contains(_getSubjectName().toLowerCase())
            )
          ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lớp học *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (filteredClasses.isEmpty)
          const Text('Không có lớp nào cho môn học này')
        else
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              itemCount: filteredClasses.length,
              itemBuilder: (context, index) {
                final lop = filteredClasses[index];
                return CheckboxListTile(
                  title: Text(
                    lop.tenlop,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    '${lop.hocky} - ${lop.namhoc}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _selectedLopIds.contains(lop.malop),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedLopIds.add(lop.malop);
                      } else {
                        _selectedLopIds.remove(lop.malop);
                      }
                    });
                  },
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExamSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tùy chọn',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // SỬA: Compact switches với icon
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Xem điểm', style: TextStyle(fontSize: 14)),
                value: _xemDiemThi,
                onChanged: (value) => setState(() => _xemDiemThi = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Xem bài làm', style: TextStyle(fontSize: 14)),
                value: _hienThiBaiLam,
                onChanged: (value) => setState(() => _hienThiBaiLam = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Xem đáp án', style: TextStyle(fontSize: 14)),
                value: _xemDapAn,
                onChanged: (value) => setState(() => _xemDapAn = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Trộn câu hỏi', style: TextStyle(fontSize: 14)),
                value: _tronCauHoi,
                onChanged: (value) => setState(() => _tronCauHoi = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  String _getSubjectName() {
    if (_selectedMonHocId == null) return '';
    final assignedSubjects = ref.read(assignedSubjectsProvider);
    return assignedSubjects.when(
      data: (subjects) {
        final subject = subjects.firstWhere(
          (s) => s.mamonhoc == _selectedMonHocId,
          orElse: () => MonHocDTO(
            mamonhoc: 0,
            tenmonhoc: '',
            sotinchi: 0,
            sotietlythuyet: 0,
            sotietthuchanh: 0,
            trangthai: true,
          ),
        );
        return subject.tenmonhoc;
      },
      loading: () => '',
      error: (_, __) => '',
    );
  }

  void _loadEditingData(DeThiDetailModel deThi) {
    debugPrint('📝 Loading editing data for exam: ${deThi.tende}');

    // Load data from existing exam
    _tenDeController.text = deThi.tende ?? '';
    _thoiGianThiController.text = deThi.thoigianthi.toString();
    _soCauDeController.text = deThi.socaude.toString();
    _soCauTBController.text = deThi.socautb.toString();
    _soCauKhoController.text = deThi.socaukho.toString();

    // Convert database times (GMT+0) to display times (GMT+7)
    _thoiGianBatDau = deThi.displayStartTime;
    _thoiGianKetThuc = deThi.displayEndTime;
    _selectedMonHocId = deThi.monthi;
    _selectedChuongIds = List.from(deThi.machuongs);
    _selectedLopIds = List.from(deThi.malops);

    _xemDiemThi = deThi.xemdiemthi;
    _hienThiBaiLam = deThi.hienthibailam;
    _xemDapAn = deThi.xemdapan;
    _tronCauHoi = deThi.troncauhoi;
    _trangThai = deThi.trangthai ?? true; // Load exam status
    _loaiDe = deThi.loaide == 1 ? LoaiDe.tuDong : LoaiDe.thuCong;

    // Mark data as loaded
    _dataLoaded = true;

    debugPrint('✅ Form data loaded successfully');
    debugPrint('🔍 Exam status loaded: ${deThi.trangthai} -> _trangThai: $_trangThai');

    // Trigger rebuild to update UI
    setState(() {});
  }

  Future<void> _selectTimeRange() async {
    final now = DateTime.now();
    final initialStart = _thoiGianBatDau ?? now.add(const Duration(days: 1));

    // Select start date and time
    final startDate = await showDatePicker(
      context: context,
      initialDate: initialStart,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (startDate == null) return;

    if (!mounted) return;

    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialStart),
    );

    if (startTime == null || !mounted) return;

    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    // Select end date and time
    if (!mounted) return;

    final endDate = await showDatePicker(
      context: context,
      initialDate: start.add(const Duration(hours: 2)),
      firstDate: start,
      lastDate: start.add(const Duration(days: 7)),
    );

    if (endDate == null || !mounted) return;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(start.add(const Duration(hours: 2))),
    );

    if (endTime == null || !mounted) return;

    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    if (end.isBefore(start)) {
      if (mounted) {
        MessageUtils.showError(
          context,
          title: 'Lỗi thời gian',
          message: 'Thời gian kết thúc phải sau thời gian bắt đầu.',
        );
      }
      return;
    }

    // Validate start time is not in the past (only for new exams)
    if (!isEditing) {
      final now = TimezoneHelper.nowInVietnam();
      if (start.isBefore(now)) {
        if (mounted) {
          MessageUtils.showError(
            context,
            title: 'Lỗi thời gian',
            message: 'Thời gian bắt đầu không được ở quá khứ.\n\nThời gian hiện tại: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}\nThời gian bạn chọn: ${DateFormat('dd/MM/yyyy HH:mm').format(start)}',
          );
        }
        return;
      }
    }

    setState(() {
      _thoiGianBatDau = start;
      _thoiGianKetThuc = end;
    });
  }

  Future<void> _handleSubmit() async {
    debugPrint('🚀 _handleSubmit called - isEditing: $isEditing');

    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Form validation failed');
      return;
    }

    // Validate required fields
    if (_thoiGianBatDau == null || _thoiGianKetThuc == null) {
      debugPrint('❌ Missing time range');
      await MessageUtils.showError(
        context,
        title: 'Thiếu thông tin',
        message: 'Vui lòng chọn thời gian diễn ra kỳ thi.',
      );
      return;
    }

    if (!isEditing && _selectedMonHocId == null) {
      debugPrint('❌ Missing subject ID');
      await MessageUtils.showError(
        context,
        title: 'Thiếu thông tin',
        message: 'Vui lòng chọn môn học cho đề thi.',
      );
      return;
    }

    if (!isEditing && _selectedChuongIds.isEmpty && _loaiDe == LoaiDe.tuDong) {
      debugPrint('❌ Missing chapters for automatic exam');
      await MessageUtils.showError(
        context,
        title: 'Thiếu thông tin',
        message: 'Vui lòng chọn ít nhất một chương cho đề thi tự động.',
      );
      return;
    }

    if (!isEditing && _selectedLopIds.isEmpty) {
      debugPrint('❌ Missing class IDs');
      await MessageUtils.showError(
        context,
        title: 'Thiếu thông tin',
        message: 'Vui lòng chọn ít nhất một lớp học để giao đề thi.',
      );
      return;
    }

    // Validate question counts for automatic exam type
    if (_loaiDe == LoaiDe.tuDong) {
      final soCauDe = int.tryParse(_soCauDeController.text) ?? 0;
      final soCauTB = int.tryParse(_soCauTBController.text) ?? 0;
      final soCauKho = int.tryParse(_soCauKhoController.text) ?? 0;

      if (soCauDe + soCauTB + soCauKho == 0) {
        await MessageUtils.showError(
          context,
          title: 'Thiếu thông tin',
          message: 'Vui lòng nhập số lượng câu hỏi cho đề thi tự động.',
        );
        return;
      }
    }

    try {
      debugPrint('✅ All validations passed, proceeding with submit');
      bool success;

      if (isEditing) {
        // Update existing exam - chỉ gửi tên và thời gian như Vue.js
        final request = DeThiUpdateRequest.fromLocalTimes(
          tende: _tenDeController.text.trim(),
          localStartTime: _thoiGianBatDau!, // GMT+7 input
          localEndTime: _thoiGianKetThuc!, // GMT+7 input
          thoigianthi: int.parse(_thoiGianThiController.text),
          // Giữ nguyên các giá trị từ form state (đã load từ database)
          monthi: _selectedMonHocId!,
          malops: _selectedLopIds,
          xemdiemthi: _xemDiemThi,
          hienthibailam: _hienThiBaiLam,
          xemdapan: _xemDapAn,
          troncauhoi: _tronCauHoi,
          loaide: _loaiDe.value,
          machuongs: _selectedChuongIds,
          socaude: int.tryParse(_soCauDeController.text) ?? 0,
          socautb: int.tryParse(_soCauTBController.text) ?? 0,
          socaukho: int.tryParse(_soCauKhoController.text) ?? 0,
          trangthai: _trangThai,
        );

        success = await ref.read(deThiFormProvider.notifier).updateDeThi(
          widget.deThi!.made,
          request,
        );
      } else {
        // Create new exam - sử dụng GMT+7 input, convert to GMT+0 for database
        final request = DeThiCreateRequest.fromLocalTimes(
          tende: _tenDeController.text.trim(),
          localStartTime: _thoiGianBatDau!, // GMT+7 input
          localEndTime: _thoiGianKetThuc!, // GMT+7 input
          thoigianthi: int.parse(_thoiGianThiController.text),
          monthi: _selectedMonHocId!,
          malops: _selectedLopIds,
          xemdiemthi: _xemDiemThi,
          hienthibailam: _hienThiBaiLam,
          xemdapan: _xemDapAn,
          troncauhoi: _tronCauHoi,
          loaide: _loaiDe.value,
          machuongs: _selectedChuongIds,
          // SỬA: Chỉ gửi số câu hỏi khi là tự động
          socaude: _loaiDe == LoaiDe.tuDong ? int.parse(_soCauDeController.text) : 0,
          socautb: _loaiDe == LoaiDe.tuDong ? int.parse(_soCauTBController.text) : 0,
          socaukho: _loaiDe == LoaiDe.tuDong ? int.parse(_soCauKhoController.text) : 0,
          trangthai: _trangThai,
        );

        final newDeThi = await ref.read(deThiFormProvider.notifier).createDeThi(request);
        success = newDeThi != null;

        if (success) {
          // Add to list
          ref.read(deThiListProvider.notifier).addDeThi(newDeThi);

          // SỬA: Nếu là thủ công, mở modal chọn câu hỏi như Vue.js
          if (_loaiDe == LoaiDe.thuCong && mounted) {
            Navigator.of(context).pop(); // Đóng form tạo đề thi

            // Hiện thông báo và hướng dẫn
            await MessageUtils.showSuccess(
              context,
              title: 'Tạo đề thi thành công',
              message: 'Đề thi đã được tạo thành công. Bây giờ hãy chọn câu hỏi cho đề thi.',
            );

            // TODO: Mở modal chọn câu hỏi (sẽ implement sau)
            // _openQuestionSelectionModal(newDeThi);
            return;
          }
        }
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          await MessageUtils.showSuccess(
            context,
            title: isEditing ? 'Cập nhật thành công' : 'Tạo đề thi thành công',
            message: isEditing
              ? 'Thông tin đề thi đã được cập nhật thành công.'
              : 'Đề thi mới đã được tạo thành công và sẵn sàng sử dụng.',
          );

          // Refresh list
          ref.read(deThiListProvider.notifier).refresh();
        }
      } else {
        if (mounted) {
          await MessageUtils.showError(
            context,
            title: isEditing ? 'Cập nhật thất bại' : 'Tạo đề thi thất bại',
            message: isEditing
              ? 'Không thể cập nhật thông tin đề thi. Vui lòng thử lại sau.'
              : 'Không thể tạo đề thi mới. Vui lòng kiểm tra thông tin và thử lại.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await MessageUtils.showError(
          context,
          title: 'Lỗi hệ thống',
          message: 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.',
        );
      }
    }
  }

  Widget _buildExamStatusSection() {
    return Card(
      elevation: 2,
      color: _trangThai ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _trangThai ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _trangThai ? Icons.check : Icons.block,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái đề thi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _trangThai ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _trangThai ? 'Sinh viên có thể thi' : 'Không thể thi',
                        style: TextStyle(
                          fontSize: 12,
                          color: _trangThai ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Sử dụng ExamStatusToggle nếu đang edit, Switch đơn giản nếu tạo mới
                if (isEditing && widget.deThi != null)
                  ExamStatusToggle(
                    examId: widget.deThi!.made,
                    initialStatus: _trangThai,
                    isCompact: true,
                    showLabel: false,
                    onStatusChanged: () {
                      setState(() {
                        _trangThai = !_trangThai;
                      });
                    },
                  )
                else
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: _trangThai,
                      onChanged: (value) => setState(() => _trangThai = value),
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.withValues(alpha: 0.3),
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
  LoaiDe _loaiDe = LoaiDe.tuDong;
  
  bool get isEditing => widget.deThi != null;

  // Track if data has been loaded to prevent multiple loads
  bool _dataLoaded = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${formState.error!}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        ref.read(deThiFormProvider.notifier).clearError();
      });
    }

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
                Text(
                  isEditing ? 'Sửa Đề thi' : 'Tạo Đề thi mới',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic info section
                      _buildBasicInfoSection(assignedSubjects, chaptersAsync),
                      const SizedBox(height: 16),
                      // Settings section
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
            const SizedBox(height: 16),

            // Exam name
            TextFormField(
              controller: _tenDeController,
              decoration: const InputDecoration(
                labelText: 'Tên đề thi *',
                border: OutlineInputBorder(),
                hintText: 'VD: Kiểm tra cuối kỳ',
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên đề thi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Time range
            _buildTimeRangeField(),
            const SizedBox(height: 12),

            // Exam duration
            TextFormField(
              controller: _thoiGianThiController,
              decoration: const InputDecoration(
                labelText: 'Thời gian làm bài (phút) *',
                border: OutlineInputBorder(),
                suffixText: 'phút',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            const SizedBox(height: 12),

            // Subject selection
            assignedSubjects.when(
              data: (subjects) => _buildSubjectDropdown(subjects),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Lỗi: $error'),
            ),
            const SizedBox(height: 12),

            // Chapters selection
            chaptersAsync.when(
              data: (chapters) => _buildChaptersSelection(chapters),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Lỗi: $error'),
            ),
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
              'Cài đặt đề thi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Exam type
            _buildExamTypeSelection(),
            const SizedBox(height: 12),

            // Question counts (only for automatic type)
            if (_loaiDe == LoaiDe.tuDong) ...[
              _buildQuestionCountFields(),
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
            lopHocList.when(
              data: (classes) => _buildClassSelection(classes),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Lỗi: $error'),
            ),
            const SizedBox(height: 12),

            // Exam settings
            _buildExamSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeField() {
    return InkWell(
      onTap: _selectTimeRange,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Thời gian diễn ra *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _thoiGianBatDau != null && _thoiGianKetThuc != null
              ? '${DateFormat('dd/MM/yyyy HH:mm').format(_thoiGianBatDau!)} - ${DateFormat('dd/MM/yyyy HH:mm').format(_thoiGianKetThuc!)}'
              : 'Chọn thời gian diễn ra',
          style: TextStyle(
            color: _thoiGianBatDau != null ? null : Colors.grey[600],
          ),
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
      ),
      items: subjects.map((subject) {
        return DropdownMenuItem<int>(
          value: subject.mamonhoc,
          child: Text(
            subject.tenmonhoc,
            overflow: TextOverflow.ellipsis, // SỬA: Tránh overflow
            style: const TextStyle(fontSize: 14), // SỬA: Giảm font size
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMonHocId = value;
          _selectedChuongIds.clear(); // Clear chapters when subject changes
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
        const Text(
          'Chương *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
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
          'Cài đặt đề thi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Xem điểm thi'),
          subtitle: const Text('Cho phép sinh viên xem điểm sau khi thi'),
          value: _xemDiemThi,
          onChanged: (value) => setState(() => _xemDiemThi = value),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Hiển thị bài làm'),
          subtitle: const Text('Cho phép sinh viên xem lại bài làm'),
          value: _hienThiBaiLam,
          onChanged: (value) => setState(() => _hienThiBaiLam = value),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Xem đáp án'),
          subtitle: const Text('Cho phép sinh viên xem đáp án đúng'),
          value: _xemDapAn,
          onChanged: (value) => setState(() => _xemDapAn = value),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Trộn câu hỏi'),
          subtitle: const Text('Thay đổi thứ tự câu hỏi cho mỗi sinh viên'),
          value: _tronCauHoi,
          onChanged: (value) => setState(() => _tronCauHoi = value),
          dense: true,
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

    _thoiGianBatDau = deThi.thoigiantbatdau;
    _thoiGianKetThuc = deThi.thoigianketthuc;
    _selectedMonHocId = deThi.monthi;
    _selectedChuongIds = List.from(deThi.machuongs);
    _selectedLopIds = List.from(deThi.malops);

    _xemDiemThi = deThi.xemdiemthi;
    _hienThiBaiLam = deThi.hienthibailam;
    _xemDapAn = deThi.xemdapan;
    _tronCauHoi = deThi.troncauhoi;
    _loaiDe = deThi.loaide == 1 ? LoaiDe.tuDong : LoaiDe.thuCong;

    // Mark data as loaded
    _dataLoaded = true;

    debugPrint('✅ Form data loaded successfully');

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thời gian kết thúc phải sau thời gian bắt đầu')),
        );
      }
      return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thời gian diễn ra')),
      );
      return;
    }

    if (_selectedMonHocId == null) {
      debugPrint('❌ Missing subject ID');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn môn học')),
      );
      return;
    }

    if (_selectedChuongIds.isEmpty && _loaiDe == LoaiDe.tuDong) {
      debugPrint('❌ Missing chapters for automatic exam');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một chương cho đề thi tự động')),
      );
      return;
    }

    if (_selectedLopIds.isEmpty) {
      debugPrint('❌ Missing class IDs');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một lớp học')),
      );
      return;
    }

    // Validate question counts for automatic exam type
    if (_loaiDe == LoaiDe.tuDong) {
      final soCauDe = int.tryParse(_soCauDeController.text) ?? 0;
      final soCauTB = int.tryParse(_soCauTBController.text) ?? 0;
      final soCauKho = int.tryParse(_soCauKhoController.text) ?? 0;

      if (soCauDe + soCauTB + soCauKho == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số lượng câu hỏi cho đề thi tự động')),
        );
        return;
      }
    }

    try {
      debugPrint('✅ All validations passed, proceeding with submit');
      bool success;

      if (isEditing) {
        debugPrint('📝 Updating existing exam ID: ${widget.deThi!.made}');
        // Update existing exam
        final request = DeThiUpdateRequest(
          tende: _tenDeController.text.trim(),
          thoigianbatdau: _thoiGianBatDau!,
          thoigianketthuc: _thoiGianKetThuc!,
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
        );

        debugPrint('🔄 Calling updateDeThi API...');
        success = await ref.read(deThiFormProvider.notifier).updateDeThi(
          widget.deThi!.made,
          request,
        );
        debugPrint('📊 Update result: $success');
      } else {
        // Create new exam
        final request = DeThiCreateRequest(
          tende: _tenDeController.text.trim(),
          thoigianbatdau: _thoiGianBatDau!,
          thoigianketthuc: _thoiGianKetThuc!,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo đề thi thành công! Bây giờ hãy chọn câu hỏi cho đề thi.'),
                duration: Duration(seconds: 3),
              ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Cập nhật đề thi thành công' : 'Tạo đề thi thành công'),
            ),
          );

          // Refresh list
          ref.read(deThiListProvider.notifier).refresh();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Cập nhật đề thi thất bại' : 'Tạo đề thi thất bại'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
    }
  }
}

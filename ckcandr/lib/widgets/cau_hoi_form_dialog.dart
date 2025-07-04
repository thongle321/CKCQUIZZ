/// Question Form Dialog for Adding/Editing Questions
/// 
/// This dialog provides a form for teachers to add or edit questions
/// with support for multiple choice answers, difficulty levels, and image upload

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/services/cau_hoi_service.dart';
import 'package:ckcandr/providers/cau_hoi_api_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class CauHoiFormDialog extends ConsumerStatefulWidget {
  final CauHoi? cauHoiToEdit;
  final int monHocIdForDialog;
  final List<MonHoc> monHocList;
  final List<ChuongMuc> chuongMucList;
  final VoidCallback onSaved;

  const CauHoiFormDialog({
    super.key,
    this.cauHoiToEdit,
    required this.monHocIdForDialog,
    required this.monHocList,
    required this.chuongMucList,
    required this.onSaved,
  });

  @override
  ConsumerState<CauHoiFormDialog> createState() => _CauHoiFormDialogState();
}

class _CauHoiFormDialogState extends ConsumerState<CauHoiFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noiDungController = TextEditingController();
  
  int? _selectedMonHocId;
  int? _selectedChuongMucId;
  int _selectedDoKho = 1;
  String _selectedLoaiCauHoi = 'single_choice';
  
  List<TextEditingController> _cauTraLoiControllers = [];
  List<bool> _cauTraLoiDapAn = [];
  List<int?> _cauTraLoiIds = []; // Store original answer IDs for edit mode
  bool _isLoading = false;

  // Image upload
  File? _selectedImage;
  String? _imageUrl;
  // Removed base64 - using file upload instead
  final ImagePicker _imagePicker = ImagePicker();

  // Text input answer (for essay questions)
  final TextEditingController _textAnswerController = TextEditingController();

  // SỬA: Auto-save functionality
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  DateTime? _lastAutoSave;

  @override
  void initState() {
    super.initState();
    _selectedMonHocId = widget.monHocIdForDialog;
    
    if (widget.cauHoiToEdit != null) {
      // Edit mode - load data from existing question
      final cauHoi = widget.cauHoiToEdit!;
      _noiDungController.text = cauHoi.noiDung;

      // Set selected values properly
      _selectedMonHocId = cauHoi.monHocId; // This should be int from mamonhoc
      _selectedChuongMucId = cauHoi.chuongMucId; // This should be int from machuong
      _selectedDoKho = cauHoi.doKhoBackend;
      _selectedLoaiCauHoi = cauHoi.loaiCauHoiBackend;
      _imageUrl = cauHoi.hinhanhUrl; // Load existing image URL

      print('🔧 Edit Mode - Loading question data:');
      print('   MonHoc ID: $_selectedMonHocId');
      print('   Chuong ID: $_selectedChuongMucId');
      print('   DoKho: $_selectedDoKho');
      print('   LoaiCauHoi: $_selectedLoaiCauHoi');
      print('   Image URL: $_imageUrl');
      print('   Answers count: ${cauHoi.cacLuaChon.length}');

      // Initialize answers
      for (int i = 0; i < cauHoi.cacLuaChon.length; i++) {
        final luaChon = cauHoi.cacLuaChon[i];
        _cauTraLoiControllers.add(TextEditingController(text: luaChon.noiDung));
        _cauTraLoiDapAn.add(luaChon.laDapAnDung ?? false);
        _cauTraLoiIds.add(luaChon.macautl); // Store original answer ID
        print('   Answer ${i + 1}: ${luaChon.noiDung} (Correct: ${luaChon.laDapAnDung}, ID: ${luaChon.macautl})');
      }
    } else {
      // Add mode - initialize with 4 empty answers
      for (int i = 0; i < 4; i++) {
        _cauTraLoiControllers.add(TextEditingController());
        _cauTraLoiDapAn.add(i == 0); // First answer is correct by default
        _cauTraLoiIds.add(null); // New answers have no ID
      }
    }
  }

  @override
  void dispose() {
    // SỬA: Cleanup auto-save timer
    _autoSaveTimer?.cancel();

    _noiDungController.dispose();
    _textAnswerController.dispose();
    for (var controller in _cauTraLoiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monHoc = widget.monHocList.firstWhere(
      (m) => int.tryParse(m.id) == _selectedMonHocId,
      orElse: () => MonHoc(id: '', tenMonHoc: 'Chưa chọn môn', maMonHoc: '', soTinChi: 0),
    );

    // Get chapters for selected subject dynamically using new provider
    final chaptersAsync = _selectedMonHocId == null
        ? const AsyncValue<List<ChuongDTO>>.data([])
        : ref.watch(chaptersProvider(_selectedMonHocId));

    // Convert ChuongDTO to ChuongMuc for compatibility
    final chuongMucListForSelectedMonHoc = chaptersAsync.when(
      data: (chapters) {
        print('Selected MonHoc ID: $_selectedMonHocId');
        print('Chapters count: ${chapters.length}');
        for (var ch in chapters) {
          print('  - ${ch.tenchuong} (ID: ${ch.machuong})');
        }

        final chuongMucList = chapters.map((ch) => ChuongMuc(
          id: ch.machuong.toString(),
          monHocId: ch.mamonhoc.toString(),
          tenChuongMuc: ch.tenchuong,
          thuTu: ch.machuong, // Use machuong as order since no thutu field
        )).toList();

        // Tự động chọn chương đầu tiên khi tạo câu hỏi mới và chưa có chương được chọn
        if (widget.cauHoiToEdit == null && // Chỉ áp dụng khi tạo mới
            _selectedChuongMucId == null && // Chưa có chương được chọn
            chuongMucList.isNotEmpty) { // Có ít nhất 1 chương
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedChuongMucId = int.tryParse(chuongMucList.first.id);
                print('🔄 Tự động chọn chương đầu tiên: ${chuongMucList.first.tenChuongMuc} (ID: $_selectedChuongMucId)');
              });
            }
          });
        }

        return chuongMucList;
      },
      loading: () {
        print('Loading chapters for MonHoc ID: $_selectedMonHocId');
        return <ChuongMuc>[];
      },
      error: (error, stack) {
        print('Error loading chapters: $error');
        return <ChuongMuc>[];
      },
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SỬA: Header ngắn gọn hơn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.cauHoiToEdit == null ? Icons.add : Icons.edit,
                    color: theme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.cauHoiToEdit == null ? 'Thêm câu hỏi' : 'Sửa câu hỏi',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    monHoc.tenMonHoc,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject selection dropdown
                      DropdownButtonFormField<int>(
                        value: widget.monHocList.any((m) => int.tryParse(m.id) == _selectedMonHocId)
                            ? _selectedMonHocId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Môn học *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        isExpanded: true, // Allow dropdown to expand properly
                        hint: const Text('Chọn môn học'),
                        items: widget.monHocList.isEmpty
                          ? [const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Không có môn học nào'),
                            )]
                          : widget.monHocList.map((monHoc) {
                              print('MonHoc: ${monHoc.tenMonHoc}, ID: ${monHoc.id}, maMonHoc: ${monHoc.maMonHoc}');
                              return DropdownMenuItem<int>(
                                value: int.tryParse(monHoc.id),
                                child: Text(
                                  monHoc.tenMonHoc,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                        onChanged: widget.monHocList.isEmpty ? null : (value) {
                          debugPrint('Selected MonHoc ID: $value');
                          setState(() {
                            _selectedMonHocId = value;
                            _selectedChuongMucId = null; // Reset chapter when subject changes
                            // SỬA: Track changes for auto-save
                            _markAsChanged();
                          });
                        },
                        validator: (value) {
                          if (value == null && widget.monHocList.isNotEmpty) {
                            return 'Vui lòng chọn môn học';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Question content
                      TextFormField(
                        controller: _noiDungController,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung câu hỏi *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.quiz),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung câu hỏi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Chapter and Difficulty
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<int>(
                              value: chuongMucListForSelectedMonHoc.any((cm) => int.tryParse(cm.id) == _selectedChuongMucId)
                                  ? _selectedChuongMucId
                                  : null,
                              decoration: InputDecoration(
                                labelText: _selectedMonHocId == null
                                    ? 'Chọn môn học trước'
                                    : chuongMucListForSelectedMonHoc.isEmpty
                                        ? 'Không có chương (${chuongMucListForSelectedMonHoc.length})'
                                        : 'Chương *',
                                border: const OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.book,
                                  size: 20,
                                  color: _selectedMonHocId == null ? Colors.grey : null,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                isDense: true,
                              ),
                              isExpanded: true,
                              hint: Text(
                                _selectedMonHocId == null
                                    ? 'Chọn môn học trước'
                                    : chuongMucListForSelectedMonHoc.isEmpty
                                        ? 'Không có chương'
                                        : 'Chương sẽ được chọn tự động',
                                style: const TextStyle(fontSize: 14),
                              ),
                              items: _selectedMonHocId == null
                                  ? [const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('Chọn môn học trước', style: TextStyle(fontSize: 14)),
                                    )]
                                  : chuongMucListForSelectedMonHoc.map((cm) {
                                      print('ChuongMuc: ${cm.tenChuongMuc}, ID: ${cm.id}');
                                      return DropdownMenuItem<int>(
                                        value: int.tryParse(cm.id),
                                        child: Text(cm.tenChuongMuc,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                              onChanged: _selectedMonHocId == null ? null : (value) {
                                print('Selected ChuongMuc ID: $value');
                                setState(() {
                                  _selectedChuongMucId = value;
                                });
                              },
                              validator: (value) {
                                if (_selectedMonHocId != null && chuongMucListForSelectedMonHoc.isNotEmpty && value == null) {
                                  return 'Vui lòng chọn chương';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<int>(
                              value: _selectedDoKho,
                              decoration: const InputDecoration(
                                labelText: 'Độ khó *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.trending_up, size: 20),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Dễ', style: TextStyle(fontSize: 14))),
                                DropdownMenuItem(value: 2, child: Text('TB', style: TextStyle(fontSize: 14))),
                                DropdownMenuItem(value: 3, child: Text('Khó', style: TextStyle(fontSize: 14))),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDoKho = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Question type
                      DropdownButtonFormField<String>(
                        value: _selectedLoaiCauHoi,
                        decoration: const InputDecoration(
                          labelText: 'Loại câu hỏi *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.quiz_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'single_choice', child: Text('Trắc nghiệm (1 đáp án)', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: 'multiple_choice', child: Text('Trắc nghiệm (nhiều đáp án)', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: 'essay', child: Text('Tự luận', style: TextStyle(fontSize: 14))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLoaiCauHoi = value!;
                            // SỬA: Cải thiện auto-reset khi thay đổi loại câu hỏi
                            _autoResetAnswersForQuestionType();
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Image upload button (compact)
                      if (_selectedImage != null || _imageUrl != null) ...[
                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                              children: [
                                _selectedImage != null
                                    ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)
                                    : Image.network(_imageUrl!, fit: BoxFit.cover, width: double.infinity),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: _pickImage,
                                          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedImage = null;
                                              _imageUrl = null;
                                            });
                                          },
                                          icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ] else ...[
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate, size: 18),
                          label: const Text('Thêm ảnh', style: TextStyle(fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(double.infinity, 36),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Answers section
                      if (_selectedLoaiCauHoi == 'essay') ...[
                        Text(
                          'Đáp án mẫu (tùy chọn):',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _textAnswerController,
                          decoration: const InputDecoration(
                            labelText: 'Đáp án mẫu cho câu tự luận',
                            border: OutlineInputBorder(),
                            hintText: 'Nhập đáp án mẫu hoặc hướng dẫn chấm điểm...',
                          ),
                          maxLines: 4,
                        ),
                      ] else ...[
                        Text(
                          'Các đáp án:',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        ..._buildAnswerFields(),

                        const SizedBox(height: 16),

                        // Add/Remove answer buttons
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _cauTraLoiControllers.length < 6 ? _addAnswer : null,
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm đáp án'),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: _cauTraLoiControllers.length > 2 ? _removeAnswer : null,
                              icon: const Icon(Icons.remove),
                              label: const Text('Xóa đáp án'),
                            ),
                          ],
                        ),
                      ],

                    ],
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(60, 36),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(80, 36),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            widget.cauHoiToEdit == null ? 'Thêm' : 'Cập nhật',
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _cauTraLoiControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // Correct answer checkbox/radio
              SizedBox(
                width: 40,
                child: _selectedLoaiCauHoi == 'single_choice'
                    ? Radio<int>(
                        value: i,
                        groupValue: _cauTraLoiDapAn.indexWhere((element) => element),
                        onChanged: (value) {
                          setState(() {
                            for (int j = 0; j < _cauTraLoiDapAn.length; j++) {
                              _cauTraLoiDapAn[j] = j == value;
                            }
                          });
                        },
                      )
                    : Checkbox(
                        value: _cauTraLoiDapAn[i],
                        onChanged: (value) {
                          setState(() {
                            _cauTraLoiDapAn[i] = value ?? false;
                          });
                        },
                      ),
              ),
              // Answer text field
              Expanded(
                child: TextFormField(
                  controller: _cauTraLoiControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Đáp án ${String.fromCharCode(65 + i)}',
                    border: const OutlineInputBorder(),
                    suffixIcon: _cauTraLoiDapAn[i]
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập đáp án';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }

  void _addAnswer() {
    if (_cauTraLoiControllers.length < 6) {
      setState(() {
        _cauTraLoiControllers.add(TextEditingController());
        _cauTraLoiDapAn.add(false);
        _cauTraLoiIds.add(null); // New answers have no ID
      });
    }
  }

  void _removeAnswer() {
    if (_cauTraLoiControllers.length > 2) {
      setState(() {
        _cauTraLoiControllers.removeLast().dispose();
        _cauTraLoiDapAn.removeLast();
        _cauTraLoiIds.removeLast(); // Remove corresponding ID
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrl = null; // Clear existing URL if any
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e')),
        );
      }
    }
  }

  void _saveQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // SỬA: Sử dụng auto-validation nâng cao
    final validationError = _autoValidateAnswers();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use file upload instead of base64
      String? imageData = _imageUrl; // Use uploaded image URL

      // Upload image first if selected
      if (_selectedImage != null) {
        final xFile = XFile(_selectedImage!.path);
        final uploadResponse = await ref.read(cauHoiServiceProvider).uploadImage(xFile);
        if (uploadResponse.isSuccess) {
          imageData = uploadResponse.data;
          print('✅ Image uploaded successfully: $imageData');
        } else {
          print('❌ Image upload failed: ${uploadResponse.error}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tải ảnh: ${uploadResponse.error}')),
            );
          }
          return; // Stop if image upload fails
        }
      }

      // Get selected MonHoc to get maMonHoc
      final selectedMonHoc = widget.monHocList.firstWhere(
        (m) => int.tryParse(m.id) == _selectedMonHocId,
      );
      final maMonHoc = int.parse(selectedMonHoc.maMonHoc);

      // Create CauHoi object
      final cauHoi = CauHoi(
        macauhoi: widget.cauHoiToEdit?.macauhoi,
        id: widget.cauHoiToEdit?.id ?? '',
        monHocId: maMonHoc, // Use maMonHoc instead of _selectedMonHocId
        chuongMucId: _selectedChuongMucId,
        noiDung: _noiDungController.text.trim(),
        loaiCauHoi: _selectedLoaiCauHoi == 'single_choice'
            ? LoaiCauHoi.tracNghiemChonMot
            : _selectedLoaiCauHoi == 'multiple_choice'
                ? LoaiCauHoi.tracNghiemChonNhieu
                : LoaiCauHoi.tuLuan,
        doKho: _selectedDoKho == 1
            ? DoKho.de
            : _selectedDoKho == 2
                ? DoKho.trungBinh
                : DoKho.kho,
        cacLuaChon: _selectedLoaiCauHoi == 'essay'
            ? (_textAnswerController.text.trim().isNotEmpty
                ? [LuaChonDapAn(
                    id: '1',
                    noiDung: _textAnswerController.text.trim(),
                    laDapAnDung: true,
                  )]
                : [])
            : _cauTraLoiControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                final originalId = index < _cauTraLoiIds.length ? _cauTraLoiIds[index] : null;
                print('🔧 Creating answer for update: "${controller.text.trim()}" with ID: $originalId');
                return LuaChonDapAn(
                  id: (index + 1).toString(), // Keep local ID for UI
                  macautl: originalId, // Use original backend ID if exists
                  noiDung: controller.text.trim(),
                  laDapAnDung: _cauTraLoiDapAn[index],
                );
              }).where((luaChon) => luaChon.noiDung.isNotEmpty).toList(),
        hinhanhUrl: imageData,
        trangthai: true,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );

      if (widget.cauHoiToEdit == null) {
        // Create new question
        final response = await ref.read(cauHoiServiceProvider).createQuestion(cauHoi);
        if (!response.isSuccess) {
          throw Exception(response.error ?? 'Lỗi tạo câu hỏi');
        }

        // Log activity
        final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
        hoatDongNotifier.addHoatDong(
          'Đã thêm câu hỏi mới: "${_noiDungController.text.trim()}"',
          LoaiHoatDong.CAU_HOI,
          Icons.add_circle_outline,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm câu hỏi thành công!')),
          );
        }
      } else {
        // Update existing question
        final response = await ref.read(cauHoiServiceProvider).updateQuestion(
          widget.cauHoiToEdit!.macauhoi!,
          cauHoi,
        );
        if (!response.isSuccess) {
          throw Exception(response.error ?? 'Lỗi cập nhật câu hỏi');
        }

        // Refresh the question list to get updated data from backend
        final currentFilter = ref.read(cauHoiFilterProvider);
        ref.read(cauHoiListProvider.notifier).refresh(currentFilter);

        // Log activity
        final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
        hoatDongNotifier.addHoatDong(
          'Đã cập nhật câu hỏi: "${_noiDungController.text.trim()}"',
          LoaiHoatDong.CAU_HOI,
          Icons.edit_outlined,
          idDoiTuongLienQuan: widget.cauHoiToEdit!.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật câu hỏi thành công!')),
          );
        }
      }

      widget.onSaved();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// SỬA: Auto-reset câu trả lời khi thay đổi loại câu hỏi
  void _autoResetAnswersForQuestionType() {
    switch (_selectedLoaiCauHoi) {
      case 'single_choice':
        // Đảm bảo có ít nhất 4 đáp án cho trắc nghiệm 1 đáp án
        _ensureMinimumAnswers(4);
        // Chỉ cho phép 1 đáp án đúng
        for (int i = 0; i < _cauTraLoiDapAn.length; i++) {
          _cauTraLoiDapAn[i] = i == 0; // Chỉ đáp án đầu tiên là đúng
        }
        debugPrint('🔄 Auto-reset to single choice: ${_cauTraLoiDapAn.length} answers, first one correct');
        break;

      case 'multiple_choice':
        // Đảm bảo có ít nhất 4 đáp án cho trắc nghiệm nhiều đáp án
        _ensureMinimumAnswers(4);
        // Cho phép nhiều đáp án đúng, mặc định 2 đáp án đầu đúng
        for (int i = 0; i < _cauTraLoiDapAn.length; i++) {
          _cauTraLoiDapAn[i] = i < 2; // 2 đáp án đầu tiên là đúng
        }
        debugPrint('🔄 Auto-reset to multiple choice: ${_cauTraLoiDapAn.length} answers, first 2 correct');
        break;

      case 'essay':
        // Xóa tất cả đáp án trắc nghiệm cho câu hỏi tự luận
        _cauTraLoiControllers.clear();
        _cauTraLoiDapAn.clear();
        _cauTraLoiIds.clear();
        _textAnswerController.clear();
        debugPrint('🔄 Auto-reset to essay: cleared all multiple choice answers');
        break;
    }
  }

  /// SỬA: Đảm bảo số lượng đáp án tối thiểu
  void _ensureMinimumAnswers(int minCount) {
    while (_cauTraLoiControllers.length < minCount) {
      _cauTraLoiControllers.add(TextEditingController());
      _cauTraLoiDapAn.add(false);
      _cauTraLoiIds.add(null);
    }

    // Nếu có quá nhiều đáp án (> 6), giữ lại 6 đáp án đầu tiên
    if (_cauTraLoiControllers.length > 6) {
      _cauTraLoiControllers = _cauTraLoiControllers.take(6).toList();
      _cauTraLoiDapAn = _cauTraLoiDapAn.take(6).toList();
      _cauTraLoiIds = _cauTraLoiIds.take(6).toList();
    }
  }

  /// SỬA: Auto-validation nâng cao
  String? _autoValidateAnswers() {
    if (_selectedLoaiCauHoi == 'essay') {
      // Câu hỏi tự luận không cần validate đáp án trắc nghiệm
      return null;
    }

    // Kiểm tra có ít nhất 2 đáp án được điền
    final filledAnswers = _cauTraLoiControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .length;

    if (filledAnswers < 2) {
      return 'Vui lòng nhập ít nhất 2 đáp án';
    }

    // Kiểm tra có ít nhất 1 đáp án đúng
    final correctAnswers = _cauTraLoiDapAn.where((isCorrect) => isCorrect).length;
    if (correctAnswers == 0) {
      return 'Vui lòng chọn ít nhất 1 đáp án đúng';
    }

    // Kiểm tra logic cho single choice
    if (_selectedLoaiCauHoi == 'single_choice' && correctAnswers > 1) {
      return 'Câu hỏi trắc nghiệm 1 đáp án chỉ được có 1 đáp án đúng';
    }

    return null; // Validation passed
  }

  /// SỬA: Mark form as changed and setup auto-save
  void _markAsChanged() {
    _hasUnsavedChanges = true;
    _lastAutoSave = DateTime.now();

    // Cancel existing timer
    _autoSaveTimer?.cancel();

    // Setup new auto-save timer (save draft after 3 seconds of inactivity)
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      _autoSaveDraft();
    });
  }

  /// SỬA: Auto-save draft functionality
  void _autoSaveDraft() {
    if (!_hasUnsavedChanges || !mounted) return;

    try {
      // Save to local storage or temporary state
      final draftData = {
        'noiDung': _noiDungController.text,
        'selectedMonHocId': _selectedMonHocId,
        'selectedChuongMucId': _selectedChuongMucId,
        'selectedDoKho': _selectedDoKho,
        'selectedLoaiCauHoi': _selectedLoaiCauHoi,
        'answers': _cauTraLoiControllers.map((c) => c.text).toList(),
        'correctAnswers': _cauTraLoiDapAn,
        'textAnswer': _textAnswerController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      debugPrint('💾 Auto-saved draft at ${DateTime.now()}');
      _hasUnsavedChanges = false;

      // TODO: Implement actual local storage save
      // SharedPreferences.setString('question_draft_${widget.cauHoiToEdit?.macauhoi ?? 'new'}', jsonEncode(draftData));

    } catch (e) {
      debugPrint('❌ Auto-save failed: $e');
    }
  }

  /// SỬA: Auto-complete suggestions for question content
  List<String> _getQuestionSuggestions(String input) {
    if (input.length < 3) return [];

    final suggestions = <String>[];
    final lowerInput = input.toLowerCase();

    // Common question patterns based on question type
    switch (_selectedLoaiCauHoi) {
      case 'single_choice':
        if (lowerInput.contains('nào')) {
          suggestions.addAll([
            'Câu nào sau đây là đúng?',
            'Phương án nào sau đây là chính xác?',
            'Khái niệm nào dưới đây là phù hợp?',
          ]);
        }
        if (lowerInput.contains('gì') || lowerInput.contains('là')) {
          suggestions.addAll([
            'Định nghĩa nào sau đây là chính xác?',
            'Khái niệm này có ý nghĩa gì?',
          ]);
        }
        break;

      case 'multiple_choice':
        suggestions.addAll([
          'Những phương án nào sau đây là đúng?',
          'Hãy chọn tất cả các đáp án chính xác:',
          'Các yếu tố nào ảnh hưởng đến...',
        ]);
        break;

      case 'essay':
        suggestions.addAll([
          'Hãy phân tích và đánh giá...',
          'Trình bày quan điểm của bạn về...',
          'So sánh và đối chiếu...',
          'Giải thích nguyên nhân và hậu quả của...',
        ]);
        break;
    }

    return suggestions.where((s) => s.toLowerCase().contains(lowerInput)).take(3).toList();
  }
}

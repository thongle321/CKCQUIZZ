/// Question Form Dialog for Adding/Editing Questions
/// 
/// This dialog provides a form for teachers to add or edit questions
/// with support for multiple choice answers, difficulty levels, and image upload

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/chuong_muc_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:ckcandr/providers/cau_hoi_api_provider.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/providers/chuong_muc_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/services/cau_hoi_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

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
  bool _isLoading = false;

  // Image upload
  File? _selectedImage;
  String? _imageUrl;
  String? _imageBase64; // Store base64 instead of URL
  final ImagePicker _imagePicker = ImagePicker();

  // Text input answer (for essay questions)
  final TextEditingController _textAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMonHocId = widget.monHocIdForDialog;
    
    if (widget.cauHoiToEdit != null) {
      // Edit mode
      final cauHoi = widget.cauHoiToEdit!;
      _noiDungController.text = cauHoi.noiDung;
      _selectedMonHocId = cauHoi.monHocId;
      _selectedChuongMucId = cauHoi.chuongMucId;
      _selectedDoKho = cauHoi.doKhoBackend;
      _selectedLoaiCauHoi = cauHoi.loaiCauHoiBackend;
      
      // Initialize answers
      for (int i = 0; i < cauHoi.cacLuaChon.length; i++) {
        _cauTraLoiControllers.add(TextEditingController(text: cauHoi.cacLuaChon[i].noiDung));
        _cauTraLoiDapAn.add(cauHoi.cacLuaChon[i].laDapAnDung ?? false);
      }
    } else {
      // Add mode - initialize with 4 empty answers
      for (int i = 0; i < 4; i++) {
        _cauTraLoiControllers.add(TextEditingController());
        _cauTraLoiDapAn.add(i == 0); // First answer is correct by default
      }
    }
  }

  @override
  void dispose() {
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
        return chapters.map((ch) => ChuongMuc(
          id: ch.machuong.toString(),
          monHocId: ch.mamonhoc.toString(),
          tenChuongMuc: ch.tenchuong,
          thuTu: ch.machuong, // Use machuong as order since no thutu field
        )).toList();
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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cauHoiToEdit == null ? 'Thêm câu hỏi mới' : 'Sửa câu hỏi',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Môn: ${monHoc.tenMonHoc}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                        value: _selectedMonHocId,
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
                          print('Selected MonHoc ID: $value');
                          setState(() {
                            _selectedMonHocId = value;
                            _selectedChuongMucId = null; // Reset chapter when subject changes
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
                              value: _selectedChuongMucId,
                              decoration: InputDecoration(
                                labelText: _selectedMonHocId == null
                                    ? 'Chọn môn học trước'
                                    : chuongMucListForSelectedMonHoc.isEmpty
                                        ? 'Không có chương (${chuongMucListForSelectedMonHoc.length})'
                                        : 'Chương (${chuongMucListForSelectedMonHoc.length})',
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
                                        : 'Chọn chương',
                                style: const TextStyle(fontSize: 14),
                              ),
                              items: _selectedMonHocId == null
                                  ? [const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('Chọn môn học trước', style: TextStyle(fontSize: 14)),
                                    )]
                                  : [
                                      const DropdownMenuItem<int>(
                                        value: null,
                                        child: Text('Không chọn', style: TextStyle(fontSize: 14)),
                                      ),
                                      ...chuongMucListForSelectedMonHoc.map((cm) {
                                        print('ChuongMuc: ${cm.tenChuongMuc}, ID: ${cm.id}');
                                        return DropdownMenuItem<int>(
                                          value: int.tryParse(cm.id),
                                          child: Text(cm.tenChuongMuc,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        );
                                      }),
                                    ],
                              onChanged: _selectedMonHocId == null ? null : (value) {
                                print('Selected ChuongMuc ID: $value');
                                setState(() {
                                  _selectedChuongMucId = value;
                                });
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
                            // Reset answers when changing type
                            if (_selectedLoaiCauHoi == 'single_choice') {
                              for (int i = 0; i < _cauTraLoiDapAn.length; i++) {
                                _cauTraLoiDapAn[i] = i == 0;
                              }
                            } else if (_selectedLoaiCauHoi == 'essay') {
                              // Clear multiple choice answers for essay
                              _cauTraLoiControllers.clear();
                              _cauTraLoiDapAn.clear();
                              _textAnswerController.clear();
                            }
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
      });
    }
  }

  void _removeAnswer() {
    if (_cauTraLoiControllers.length > 2) {
      setState(() {
        _cauTraLoiControllers.removeLast().dispose();
        _cauTraLoiDapAn.removeLast();
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
        // Convert image to base64
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = image.mimeType ?? 'image/jpeg';
        final dataUrl = 'data:$mimeType;base64,$base64String';

        setState(() {
          _selectedImage = File(image.path);
          _imageBase64 = dataUrl; // Store as base64 data URL
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

    // Validate answers based on question type
    if (_selectedLoaiCauHoi != 'essay') {
      if (_cauTraLoiControllers.isEmpty || !_cauTraLoiDapAn.any((element) => element)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm đáp án và chọn ít nhất một đáp án đúng')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Temporarily disable image upload completely due to database column size limit
      String? imageData = null; // Disable all image uploads for now
      // TODO: Enable after database column is updated to NVARCHAR(MAX)
      // String? imageData = _imageUrl; // Keep existing URL if editing
      // if (_imageBase64 != null) {
      //   imageData = _imageBase64; // Use base64 data URL
      // }

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
                return LuaChonDapAn(
                  id: (index + 1).toString(),
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
}

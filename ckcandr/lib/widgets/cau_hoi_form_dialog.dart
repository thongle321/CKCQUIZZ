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
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/services/cau_hoi_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

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
      orElse: () => MonHoc(id: '', tenMonHoc: 'N/A', maMonHoc: '', soTinChi: 0),
    );

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.cauHoiToEdit == null ? 'Thêm câu hỏi mới' : 'Sửa câu hỏi',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              'Môn: ${monHoc.tenMonHoc}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question content
                      TextFormField(
                        controller: _noiDungController,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung câu hỏi *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.quiz),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung câu hỏi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Chapter and Difficulty
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedChuongMucId,
                              decoration: const InputDecoration(
                                labelText: 'Chương',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.book),
                              ),
                              hint: const Text('Chọn chương'),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Không chọn chương'),
                                ),
                                ...widget.chuongMucList.map((cm) {
                                  return DropdownMenuItem<int>(
                                    value: int.tryParse(cm.id),
                                    child: Text(cm.tenChuongMuc, overflow: TextOverflow.ellipsis),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedChuongMucId = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedDoKho,
                              decoration: const InputDecoration(
                                labelText: 'Độ khó *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.trending_up),
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Dễ', style: TextStyle(color: Colors.green))),
                                DropdownMenuItem(value: 2, child: Text('Trung bình', style: TextStyle(color: Colors.orange))),
                                DropdownMenuItem(value: 3, child: Text('Khó', style: TextStyle(color: Colors.red))),
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
                      const SizedBox(height: 16),
                      
                      // Question type
                      DropdownButtonFormField<String>(
                        value: _selectedLoaiCauHoi,
                        decoration: const InputDecoration(
                          labelText: 'Loại câu hỏi *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.quiz_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'single_choice', child: Text('Trắc nghiệm (1 đáp án)')),
                          DropdownMenuItem(value: 'multiple_choice', child: Text('Trắc nghiệm (nhiều đáp án)')),
                          DropdownMenuItem(value: 'essay', child: Text('Tự luận (nhập text)')),
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
                      const SizedBox(height: 16),

                      // Image upload section
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.image, color: theme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Hình ảnh câu hỏi (tùy chọn)',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_selectedImage != null) ...[
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Thay đổi'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _imageUrl = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            ] else if (_imageUrl != null) ...[
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Thay đổi'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _imageUrl = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            ] else ...[
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Thêm hình ảnh'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

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
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.cauHoiToEdit == null ? 'Thêm' : 'Cập nhật'),
                ),
              ],
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
      // Upload image if selected
      String? imageUrl = _imageUrl; // Keep existing URL if editing
      if (_selectedImage != null) {
        try {
          // Create XFile from File for upload
          final xFile = XFile(_selectedImage!.path);

          // Upload image via API
          final uploadResponse = await ref.read(cauHoiServiceProvider).uploadImage(xFile);
          if (uploadResponse.isSuccess && uploadResponse.data != null) {
            imageUrl = uploadResponse.data;
          } else {
            throw Exception('Upload ảnh thất bại: ${uploadResponse.error}');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi upload ảnh: $e')),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Create CauHoi object
      final cauHoi = CauHoi(
        macauhoi: widget.cauHoiToEdit?.macauhoi,
        id: widget.cauHoiToEdit?.id ?? '',
        monHocId: _selectedMonHocId!,
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
        hinhanhUrl: imageUrl,
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

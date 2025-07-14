import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/core/widgets/error_dialog.dart';

class MonHocFormDialog extends ConsumerStatefulWidget {
  final ApiMonHoc? monHoc; // null = create, not null = edit
  
  const MonHocFormDialog({
    super.key,
    this.monHoc,
  });

  @override
  ConsumerState<MonHocFormDialog> createState() => _MonHocFormDialogState();
}

class _MonHocFormDialogState extends ConsumerState<MonHocFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _maMonHocController = TextEditingController();
  final _tenMonHocController = TextEditingController();
  final _soTinChiController = TextEditingController();
  final _soTietLyThuyetController = TextEditingController();
  final _soTietThucHanhController = TextEditingController();
  bool _trangThai = true;
  bool _isLoading = false;

  bool get isEditing => widget.monHoc != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _maMonHocController.text = widget.monHoc!.maMonHoc.toString();
      _tenMonHocController.text = widget.monHoc!.tenMonHoc;
      _soTinChiController.text = widget.monHoc!.soTinChi.toString();
      _soTietLyThuyetController.text = widget.monHoc!.soTietLyThuyet.toString();
      _soTietThucHanhController.text = widget.monHoc!.soTietThucHanh.toString();
      _trangThai = widget.monHoc!.trangThai;
    }
  }

  @override
  void dispose() {
    _maMonHocController.dispose();
    _tenMonHocController.dispose();
    _soTinChiController.dispose();
    _soTietLyThuyetController.dispose();
    _soTietThucHanhController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(isEditing ? 'Sửa môn học' : 'Thêm môn học mới'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mã môn học
                TextFormField(
                  controller: _maMonHocController,
                  decoration: const InputDecoration(
                    labelText: 'Mã môn học *',
                    hintText: 'Ví dụ: 101',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: !isEditing, // Không cho sửa mã môn khi edit
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã môn học';
                    }
                    final intValue = int.tryParse(value.trim());
                    if (intValue == null || intValue <= 0) {
                      return 'Mã môn học phải là số nguyên dương';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Tên môn học
                TextFormField(
                  controller: _tenMonHocController,
                  decoration: const InputDecoration(
                    labelText: 'Tên môn học *',
                    hintText: 'Ví dụ: Lập trình căn bản',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên môn học';
                    }
                    if (value.trim().length < 3) {
                      return 'Tên môn học phải có ít nhất 3 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Số tín chỉ
                TextFormField(
                  controller: _soTinChiController,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ *',
                    hintText: 'Ví dụ: 3',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số tín chỉ';
                    }
                    final intValue = int.tryParse(value.trim());
                    if (intValue == null || intValue <= 0 || intValue > 10) {
                      return 'Số tín chỉ phải từ 1 đến 10';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Số tiết lý thuyết
                TextFormField(
                  controller: _soTietLyThuyetController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiết lý thuyết *',
                    hintText: 'Ví dụ: 30',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số tiết lý thuyết';
                    }
                    final intValue = int.tryParse(value.trim());
                    if (intValue == null || intValue < 0) {
                      return 'Số tiết lý thuyết phải >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Số tiết thực hành
                TextFormField(
                  controller: _soTietThucHanhController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiết thực hành *',
                    hintText: 'Ví dụ: 15',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số tiết thực hành';
                    }
                    final intValue = int.tryParse(value.trim());
                    if (intValue == null || intValue < 0) {
                      return 'Số tiết thực hành phải >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Trạng thái
                Row(
                  children: [
                    const Text('Trạng thái: '),
                    const SizedBox(width: 8),
                    Switch(
                      value: _trangThai,
                      onChanged: (value) {
                        setState(() {
                          _trangThai = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(_trangThai ? 'Hoạt động' : 'Không hoạt động'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      
      if (isEditing) {
        // Update existing subject
        final request = UpdateMonHocRequestDTO(
          tenMonHoc: _tenMonHocController.text.trim(),
          soTinChi: int.parse(_soTinChiController.text.trim()),
          soTietLyThuyet: int.parse(_soTietLyThuyetController.text.trim()),
          soTietThucHanh: int.parse(_soTietThucHanhController.text.trim()),
          trangThai: _trangThai,
        );
        
        success = await ref.read(monHocProvider.notifier).updateSubject(
          widget.monHoc!.maMonHoc,
          request,
        );
      } else {
        // Create new subject
        final request = CreateMonHocRequestDTO(
          maMonHoc: int.parse(_maMonHocController.text.trim()),
          tenMonHoc: _tenMonHocController.text.trim(),
          soTinChi: int.parse(_soTinChiController.text.trim()),
          soTietLyThuyet: int.parse(_soTietLyThuyetController.text.trim()),
          soTietThucHanh: int.parse(_soTietThucHanhController.text.trim()),
          trangThai: _trangThai,
        );
        
        success = await ref.read(monHocProvider.notifier).createSubject(request);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          await SuccessDialog.show(
            context,
            message: isEditing
                ? 'Cập nhật môn học thành công!'
                : 'Thêm môn học thành công!',
          );
        } else {
          final error = ref.read(monHocProvider).error;
          await ErrorDialog.show(
            context,
            message: error ?? 'Có lỗi xảy ra khi xử lý môn học',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Đã xảy ra lỗi: ${e.toString()}',
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

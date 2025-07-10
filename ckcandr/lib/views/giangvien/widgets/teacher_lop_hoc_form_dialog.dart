import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/chuong_provider.dart';

class TeacherLopHocFormDialog extends ConsumerStatefulWidget {
  final LopHoc? lopHoc; // null = thêm mới, có giá trị = chỉnh sửa

  const TeacherLopHocFormDialog({super.key, this.lopHoc});

  @override
  ConsumerState<TeacherLopHocFormDialog> createState() => _TeacherLopHocFormDialogState();
}

class _TeacherLopHocFormDialogState extends ConsumerState<TeacherLopHocFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenLopController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final _namHocController = TextEditingController();
  final _hocKyController = TextEditingController();

  int? _selectedMonHocId;
  bool _trangThai = true;
  bool _hienThi = true;
  bool _isLoading = false;
  List<MonHocDTO> _monHocList = [];

  @override
  void initState() {
    super.initState();
    _loadMonHocList();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.lopHoc != null) {
      // Chế độ chỉnh sửa
      final lopHoc = widget.lopHoc!;
      _tenLopController.text = lopHoc.tenlop;
      _ghiChuController.text = lopHoc.ghichu ?? '';
      _namHocController.text = lopHoc.namhoc?.toString() ?? '';
      _hocKyController.text = lopHoc.hocky?.toString() ?? '';
      _trangThai = lopHoc.trangthai ?? true;
      _hienThi = lopHoc.hienthi ?? true;
      // Note: _selectedMonHocId sẽ được set sau khi load xong danh sách môn học
    } else {
      // Chế độ thêm mới - set giá trị mặc định
      _namHocController.text = DateTime.now().year.toString();
      _hocKyController.text = '1';
    }
  }

  Future<void> _loadMonHocList() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      // Chỉ lấy môn học được phân công cho giảng viên
      final response = await apiService.getAssignedSubjects();

      if (mounted) {
        setState(() {
          _monHocList = response;

          // Nếu đang chỉnh sửa, tìm và set môn học hiện tại
          if (widget.lopHoc != null && _monHocList.isNotEmpty) {
            // Tìm môn học dựa trên tên (vì API trả về tên môn học trong lopHoc.monhocs)
            final currentMonHoc = _monHocList.firstWhere(
              (monhoc) => widget.lopHoc!.monhocs.contains(monhoc.tenmonhoc),
              orElse: () => _monHocList.first,
            );
            _selectedMonHocId = currentMonHoc.mamonhoc;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách môn học được phân công: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tenLopController.dispose();
    _ghiChuController.dispose();
    _namHocController.dispose();
    _hocKyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
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
              children: [
                Icon(
                  widget.lopHoc == null ? Icons.add : Icons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.lopHoc == null ? 'Thêm lớp học mới' : 'Chỉnh sửa lớp học',
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
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Tên lớp
                TextFormField(
                  controller: _tenLopController,
                  decoration: const InputDecoration(
                    labelText: 'Tên lớp học *',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên lớp học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Môn học (chỉ hiển thị môn được phân công)
                DropdownButtonFormField<int>(
                  value: _selectedMonHocId,
                  decoration: const InputDecoration(
                    labelText: 'Môn học được phân công *',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    helperText: 'Chỉ hiển thị môn học bạn được phân công',
                  ),
                  isExpanded: true,
                  items: _monHocList.map((monhoc) {
                    return DropdownMenuItem<int>(
                      value: monhoc.mamonhoc,
                      child: Text(
                        '${monhoc.mamonhoc} - ${monhoc.tenmonhoc}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonHocId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn môn học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Giảng viên (chỉ hiển thị, không cho chỉnh sửa)
                TextFormField(
                  initialValue: currentUser?.hoVaTen ?? 'Giảng viên hiện tại',
                  decoration: const InputDecoration(
                    labelText: 'Giảng viên',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.lock, color: Colors.grey),
                  ),
                  enabled: false, // Khóa field này
                ),
                const SizedBox(height: 16),

                // Năm học và Học kỳ
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _namHocController,
                        decoration: const InputDecoration(
                          labelText: 'Năm học',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final year = int.tryParse(value);
                            if (year == null || year < 2000 || year > 2100) {
                              return 'Năm học không hợp lệ';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _hocKyController,
                        decoration: const InputDecoration(
                          labelText: 'Học kỳ',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final semester = int.tryParse(value);
                            if (semester == null || semester < 1 || semester > 3) {
                              return 'Học kỳ phải từ 1-3';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ghi chú
                TextFormField(
                  controller: _ghiChuController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 12),

                // Trạng thái
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Hoạt động', style: TextStyle(fontSize: 14)),
                          value: _trangThai,
                          onChanged: (value) {
                            setState(() {
                              _trangThai = value ?? true;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Hiển thị', style: TextStyle(fontSize: 14)),
                          value: _hienThi,
                          onChanged: (value) {
                            setState(() {
                              _hienThi = value ?? true;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom action buttons
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.lopHoc == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    ],
  ),
),
);
}

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final namHoc = _namHocController.text.isNotEmpty 
          ? int.parse(_namHocController.text) 
          : null;
      final hocKy = _hocKyController.text.isNotEmpty 
          ? int.parse(_hocKyController.text) 
          : null;

      final currentUser = ref.read(currentUserProvider);
      final giangVienId = currentUser?.mssv; // Luôn sử dụng ID của giảng viên hiện tại

      if (widget.lopHoc == null) {
        // Thêm mới
        final request = CreateLopRequestDTO(
          tenlop: _tenLopController.text.trim(),
          ghichu: _ghiChuController.text.trim().isEmpty
              ? null
              : _ghiChuController.text.trim(),
          namhoc: namHoc,
          hocky: hocKy,
          trangthai: _trangThai,
          hienthi: _hienThi,
          mamonhoc: _selectedMonHocId!,
          magiangvien: giangVienId,
        );

        await ref.read(lopHocListProvider.notifier).addLopHoc(request);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm lớp học thành công!')),
          );
          // Invalidate provider để refresh danh sách
          ref.invalidate(lopHocListProvider);
        }
      } else {
        // Cập nhật
        final request = UpdateLopRequestDTO(
          tenlop: _tenLopController.text.trim(),
          ghichu: _ghiChuController.text.trim().isEmpty
              ? null
              : _ghiChuController.text.trim(),
          namhoc: namHoc,
          hocky: hocKy,
          trangthai: _trangThai,
          hienthi: _hienThi,
          mamonhoc: _selectedMonHocId!,
          magiangvien: null, // Giảng viên không thể thay đổi người được assign
        );

        await ref.read(lopHocListProvider.notifier)
            .updateLopHoc(widget.lopHoc!.malop, request);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật lớp học thành công!')),
          );
          // Invalidate provider để refresh danh sách
          ref.invalidate(lopHocListProvider);
        }
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

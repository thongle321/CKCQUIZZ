import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/models/api_models.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

class LopHocFormDialog extends ConsumerStatefulWidget {
  final LopHoc? lopHoc; // null = thêm mới, có giá trị = chỉnh sửa

  const LopHocFormDialog({super.key, this.lopHoc});

  @override
  ConsumerState<LopHocFormDialog> createState() => _LopHocFormDialogState();
}

class _LopHocFormDialogState extends ConsumerState<LopHocFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenLopController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final _namHocController = TextEditingController();
  final _hocKyController = TextEditingController();

  int? _selectedMonHocId;
  String? _selectedGiangVienId;
  bool _trangThai = true;
  bool _hienThi = true;
  bool _isLoading = false;
  List<ApiMonHoc> _monHocList = [];
  List<GetNguoiDungDTO> _teacherList = [];

  @override
  void initState() {
    super.initState();
    _loadMonHocList();
    _loadTeacherList();
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
      _selectedGiangVienId = lopHoc.magiangvien;
      // Note: _selectedMonHocId sẽ được set sau khi load xong danh sách môn học
    } else {
      // Chế độ thêm mới - set giá trị mặc định
      _namHocController.text = DateTime.now().year.toString();
      _hocKyController.text = '1';

      // Nếu là Teacher role, auto-assign cho current user
      final currentUser = ref.read(currentUserProvider);
      if (currentUser?.quyen == UserRole.giangVien) {
        _selectedGiangVienId = currentUser?.mssv;
      }
    }
  }

  Future<void> _loadMonHocList() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final monHocList = await apiService.getSubjects();
      setState(() {
        _monHocList = monHocList;

        // Nếu đang chỉnh sửa, tìm môn học tương ứng
        if (widget.lopHoc != null && widget.lopHoc!.monhocs.isNotEmpty) {
          final tenMonHoc = widget.lopHoc!.monhocs.first;
          final monHoc = _monHocList.firstWhere(
            (mh) => mh.tenMonHoc == tenMonHoc,
            orElse: () => _monHocList.first,
          );
          _selectedMonHocId = monHoc.maMonHoc;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách môn học: $e')),
        );
      }
    }
  }

  Future<void> _loadTeacherList() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final teacherList = await apiService.getTeachers();
      setState(() {
        _teacherList = teacherList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách giảng viên: $e')),
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

  Widget _buildTeacherField() {
    final currentUser = ref.watch(currentUserProvider);

    // Admin: Show dropdown to select any teacher
    if (currentUser?.quyen == UserRole.admin) {
      return DropdownButtonFormField<String>(
        value: _selectedGiangVienId,
        decoration: const InputDecoration(
          labelText: 'Giảng viên *',
          border: OutlineInputBorder(),
        ),
        items: _teacherList.map((teacher) {
          return DropdownMenuItem<String>(
            value: teacher.mssv,
            child: Text(
              teacher.hoten,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGiangVienId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn giảng viên';
          }
          return null;
        },
      );
    }

    // Teacher: Show read-only field with current user
    else if (currentUser?.quyen == UserRole.giangVien) {
      return TextFormField(
        initialValue: currentUser?.hoVaTen ?? 'Chưa xác định',
        decoration: const InputDecoration(
          labelText: 'Giảng viên',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      );
    }

    // Fallback: Empty container
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lopHoc == null ? 'Thêm lớp học mới' : 'Chỉnh sửa lớp học'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tên lớp
                TextFormField(
                  controller: _tenLopController,
                  decoration: const InputDecoration(
                    labelText: 'Tên lớp học *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên lớp học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Môn học dropdown
                DropdownButtonFormField<int>(
                  value: _selectedMonHocId,
                  decoration: const InputDecoration(
                    labelText: 'Môn học *',
                    border: OutlineInputBorder(),
                  ),
                  items: _monHocList.map((monHoc) {
                    return DropdownMenuItem<int>(
                      value: monHoc.maMonHoc,
                      child: Text(
                        monHoc.tenMonHoc,
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
                const SizedBox(height: 16),

                // Teacher selection - role-based visibility
                _buildTeacherField(),
                const SizedBox(height: 16),

                // Năm học và học kỳ
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _namHocController,
                        decoration: const InputDecoration(
                          labelText: 'Năm học',
                          border: OutlineInputBorder(),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _hocKyController,
                        decoration: const InputDecoration(
                          labelText: 'Học kỳ',
                          border: OutlineInputBorder(),
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
                const SizedBox(height: 16),

                // Ghi chú
                TextFormField(
                  controller: _ghiChuController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Trạng thái và hiển thị
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Hoạt động'),
                        value: _trangThai,
                        onChanged: (value) {
                          setState(() {
                            _trangThai = value ?? true;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Hiển thị'),
                        value: _hienThi,
                        onChanged: (value) {
                          setState(() {
                            _hienThi = value ?? true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.lopHoc == null ? 'Thêm' : 'Cập nhật'),
        ),
      ],
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

      // Determine teacher assignment
      String? giangVienId = _selectedGiangVienId;
      final currentUser = ref.read(currentUserProvider);

      // If Teacher role and no explicit selection, use current user
      if (currentUser?.quyen == UserRole.giangVien && giangVienId == null) {
        giangVienId = currentUser?.mssv;
      }

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
          magiangvien: currentUser?.quyen == UserRole.admin ? giangVienId : null, // Only Admin can change teacher
        );

        await ref.read(lopHocListProvider.notifier)
            .updateLopHoc(widget.lopHoc!.malop, request);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật lớp học thành công!')),
          );
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

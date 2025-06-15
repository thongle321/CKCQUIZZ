import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';

class AdminLopHocFormDialog extends ConsumerStatefulWidget {
  final LopHoc? lopHoc;

  const AdminLopHocFormDialog({super.key, this.lopHoc});

  @override
  ConsumerState<AdminLopHocFormDialog> createState() => _AdminLopHocFormDialogState();
}

class _AdminLopHocFormDialogState extends ConsumerState<AdminLopHocFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenLopController = TextEditingController();
  final _moTaController = TextEditingController();
  final _siSoController = TextEditingController();
  
  String? _selectedMonHocId;
  String? _selectedGiangVienId;
  int _namHoc = DateTime.now().year;
  int _hocKy = 1;
  TrangThaiLop _trangThai = TrangThaiLop.hoatDong;

  @override
  void initState() {
    super.initState();
    if (widget.lopHoc != null) {
      _tenLopController.text = widget.lopHoc!.tenLop;
      _moTaController.text = widget.lopHoc!.moTa;
      _siSoController.text = widget.lopHoc!.siSo.toString();
      _selectedMonHocId = widget.lopHoc!.monHocId;
      _selectedGiangVienId = widget.lopHoc!.giangVienId;
      _namHoc = widget.lopHoc!.namHoc;
      _hocKy = widget.lopHoc!.hocKy;
      _trangThai = widget.lopHoc!.trangThai;
    }
  }

  @override
  void dispose() {
    _tenLopController.dispose();
    _moTaController.dispose();
    _siSoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danhSachMonHoc = ref.watch(monHocListProvider);
    final danhSachUser = ref.watch(userListProvider);
    final danhSachGiangVien = danhSachUser
        .where((user) => user.quyen == UserRole.giangVien)
        .toList();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.lopHoc == null ? 'Thêm lớp học mới' : 'Sửa thông tin lớp học',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      
                      DropdownButtonFormField<String>(
                        value: _selectedMonHocId,
                        decoration: const InputDecoration(
                          labelText: 'Môn học *',
                          border: OutlineInputBorder(),
                        ),
                        items: danhSachMonHoc.map((monHoc) {
                          return DropdownMenuItem(
                            value: monHoc.id,
                            child: Text('${monHoc.tenMonHoc} (${monHoc.maMonHoc})'),
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
                      
                      DropdownButtonFormField<String>(
                        value: _selectedGiangVienId,
                        decoration: const InputDecoration(
                          labelText: 'Giảng viên *',
                          border: OutlineInputBorder(),
                        ),
                        items: danhSachGiangVien.map((giangVien) {
                          return DropdownMenuItem(
                            value: giangVien.id,
                            child: Text('${giangVien.hoVaTen} (${giangVien.mssv})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGiangVienId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn giảng viên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _namHoc,
                              decoration: const InputDecoration(
                                labelText: 'Năm học *',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(5, (index) {
                                final year = DateTime.now().year - 2 + index;
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _namHoc = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _hocKy,
                              decoration: const InputDecoration(
                                labelText: 'Học kỳ *',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Học kỳ 1')),
                                DropdownMenuItem(value: 2, child: Text('Học kỳ 2')),
                                DropdownMenuItem(value: 3, child: Text('Học kỳ hè')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _hocKy = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _siSoController,
                        decoration: const InputDecoration(
                          labelText: 'Sĩ số tối đa *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập sĩ số';
                          }
                          final siSo = int.tryParse(value);
                          if (siSo == null || siSo <= 0) {
                            return 'Sĩ số phải là số nguyên dương';
                          }
                          if (siSo > 100) {
                            return 'Sĩ số không được vượt quá 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<TrangThaiLop>(
                        value: _trangThai,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái *',
                          border: OutlineInputBorder(),
                        ),
                        items: TrangThaiLop.values.map((trangThai) {
                          return DropdownMenuItem(
                            value: trangThai,
                            child: Text(_getTrangThaiText(trangThai)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _trangThai = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _moTaController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveLopHoc,
                  child: Text(widget.lopHoc == null ? 'Thêm' : 'Cập nhật'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTrangThaiText(TrangThaiLop trangThai) {
    switch (trangThai) {
      case TrangThaiLop.hoatDong:
        return 'Hoạt động';
      case TrangThaiLop.tamDung:
        return 'Tạm dừng';
      case TrangThaiLop.ketThuc:
        return 'Kết thúc';
    }
  }

  void _saveLopHoc() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final danhSachMonHoc = ref.read(monHocListProvider);
    final danhSachUser = ref.read(userListProvider);
    
    final monHoc = danhSachMonHoc.firstWhere((mh) => mh.id == _selectedMonHocId);
    final giangVien = danhSachUser.firstWhere((user) => user.id == _selectedGiangVienId);
    
    final lopHocNotifier = ref.read(lopHocListProvider.notifier);
    
    if (widget.lopHoc == null) {
      // Thêm mới
      final newLopHoc = LopHoc(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tenLop: _tenLopController.text.trim(),
        maLop: lopHocNotifier.generateMaLop(),
        moTa: _moTaController.text.trim(),
        giangVienId: giangVien.id,
        giangVienTen: giangVien.hoVaTen,
        monHocId: monHoc.id,
        monHocTen: monHoc.tenMonHoc,
        namHoc: _namHoc,
        hocKy: _hocKy,
        siSo: int.parse(_siSoController.text),
        trangThai: _trangThai,
        ngayTao: DateTime.now(),
        ngayCapNhat: DateTime.now(),
      );
      
      lopHocNotifier.addLopHoc(newLopHoc);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm lớp học "${newLopHoc.tenLop}"')),
      );
    } else {
      // Cập nhật
      final updatedLopHoc = widget.lopHoc!.copyWith(
        tenLop: _tenLopController.text.trim(),
        moTa: _moTaController.text.trim(),
        giangVienId: giangVien.id,
        giangVienTen: giangVien.hoVaTen,
        monHocId: monHoc.id,
        monHocTen: monHoc.tenMonHoc,
        namHoc: _namHoc,
        hocKy: _hocKy,
        siSo: int.parse(_siSoController.text),
        trangThai: _trangThai,
        ngayCapNhat: DateTime.now(),
      );
      
      lopHocNotifier.updateLopHoc(updatedLopHoc);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật lớp học "${updatedLopHoc.tenLop}"')),
      );
    }
  }
}

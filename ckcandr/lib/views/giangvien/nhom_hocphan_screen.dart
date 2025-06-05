import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Not used
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart'; // Import provider mới
import 'package:ckcandr/models/mon_hoc_model.dart'; // Import model MonHoc
import 'package:ckcandr/providers/hoat_dong_provider.dart'; // Added
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart'; // Added
import 'package:ckcandr/providers/nhom_hocphan_provider.dart'; // Import provider mới
import 'package:intl/intl.dart'; // For DateFormat
// import 'package:ckcandr/models/nhom_hocphan_model.dart'; // Using local mock
// import 'package:ckcandr/services/nhom_hocphan_service.dart'; // Not used for mock
// import 'package:ckcandr/services/mon_hoc_service.dart'; // Not used for mock
// import 'package:intl/intl.dart'; // Not used directly in this version

// Model cho Nhóm Học Phần. Nên được đặt trong file riêng (ví dụ: models/nhom_hocphan_model.dart)
class NhomHocPhan {
  final String id;
  final String monHocId;
  final String tenMonHoc;
  final String tenNhomHocPhan;
  final String hocKy; // String
  final String namHoc;
  final DateTime ngayTao;
  int soLuongSV;

  NhomHocPhan({
    required this.id,
    required this.monHocId,
    required this.tenMonHoc,
    required this.tenNhomHocPhan,
    required this.hocKy,
    required this.namHoc,
    required this.ngayTao,
    this.soLuongSV = 0,
  });

  NhomHocPhan copyWith({
    String? id,
    String? monHocId,
    String? tenMonHoc,
    String? tenNhomHocPhan,
    String? hocKy,
    String? namHoc,
    DateTime? ngayTao,
    int? soLuongSV,
  }) {
    return NhomHocPhan(
      id: id ?? this.id,
      monHocId: monHocId ?? this.monHocId,
      tenMonHoc: tenMonHoc ?? this.tenMonHoc,
      tenNhomHocPhan: tenNhomHocPhan ?? this.tenNhomHocPhan,
      hocKy: hocKy ?? this.hocKy,
      namHoc: namHoc ?? this.namHoc,
      ngayTao: ngayTao ?? this.ngayTao,
      soLuongSV: soLuongSV ?? this.soLuongSV,
    );
  }
}

// Provider để quản lý danh sách nhóm học phần người dùng tạo ra.
// Khởi tạo rỗng theo yêu cầu của người dùng.
// final tempNhomHocPhanListProvider = StateProvider<List<NhomHocPhan>>((ref) => []); // Comment out or remove old
final nhomHocPhanListProvider = StateProvider<List<NhomHocPhan>>((ref) => []); // New consistent name

class NhomHocPhanScreen extends ConsumerStatefulWidget {
  const NhomHocPhanScreen({super.key});

  @override
  ConsumerState<NhomHocPhanScreen> createState() => _NhomHocPhanScreenState();
}

class _NhomHocPhanScreenState extends ConsumerState<NhomHocPhanScreen> {
  String? _selectedHocKyFilter = 'Tất cả';
  String? _selectedNamHocFilter;
  List<String> _academicYearOptions = [];
  final TextEditingController _searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  MonHoc? _selectedMonHocDialog;
  final TextEditingController _groupNameController = TextEditingController();
  String? _selectedHocKyDialog;
  String? _selectedNamHocDialog;

  @override
  void initState() {
    super.initState();
    _generateAcademicYears();
    _selectedNamHocFilter = _academicYearOptions.isNotEmpty ? _academicYearOptions.first : null;
    // Initialize dialog defaults
    _selectedHocKyDialog = 'Học kỳ 1';
    _selectedNamHocDialog = _academicYearOptions.isNotEmpty ? _academicYearOptions.first : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subjects = ref.read(monHocListProvider);
      if (mounted && subjects.isNotEmpty) {
        setState(() {
          _selectedMonHocDialog = subjects.first;
        });
      }
    });
  }

  void _generateAcademicYears() {
    int currentYear = DateTime.now().year;
    _academicYearOptions.clear();
    for (int i = currentYear - 3; i < currentYear + 5; i++) {
      _academicYearOptions.add('${i}-${i + 1}');
    }
     if (mounted) {
      setState(() {
        if (_selectedNamHocFilter == null && _academicYearOptions.isNotEmpty) {
          _selectedNamHocFilter = _academicYearOptions.first;
        }
        if (_selectedNamHocDialog == null && _academicYearOptions.isNotEmpty) {
          _selectedNamHocDialog = _academicYearOptions.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  List<NhomHocPhan> _getFilteredNhomHocPhan(List<NhomHocPhan> allGroups) {
    return allGroups.where((group) {
      final matchHocKy = _selectedHocKyFilter == 'Tất cả' || group.hocKy == _selectedHocKyFilter;
      final matchNamHoc = _selectedNamHocFilter == null || _selectedNamHocFilter == 'Tất cả năm' || group.namHoc == _selectedNamHocFilter;
      final matchSearch = _searchController.text.isEmpty ||
          group.tenNhomHocPhan.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          group.tenMonHoc.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchHocKy && matchNamHoc && matchSearch;
    }).toList();
  }

  void _resetDialogState() {
    final subjects = ref.read(monHocListProvider);
     if (mounted) {
      setState(() {
        _selectedMonHocDialog = subjects.isNotEmpty ? subjects.first : null;
        _groupNameController.clear();
        _selectedHocKyDialog = 'Học kỳ 1';
        _selectedNamHocDialog = _academicYearOptions.isNotEmpty ? _academicYearOptions.first : null;
      });
    }
  }

  void _showCreateGroupDialog(BuildContext context, {NhomHocPhan? groupToEdit}) {
    final List<MonHoc> subjects = ref.watch(monHocListProvider);
    bool isEditing = groupToEdit != null;

    if (isEditing) {
      _groupNameController.text = groupToEdit.tenNhomHocPhan;
      _selectedHocKyDialog = groupToEdit.hocKy;
      _selectedNamHocDialog = groupToEdit.namHoc;
      try {
        _selectedMonHocDialog = subjects.firstWhere((s) => s.id == groupToEdit.monHocId);
      } catch (e) { // Element not found
        _selectedMonHocDialog = subjects.isNotEmpty ? subjects.first : null; // Fallback
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Môn học gốc của nhóm này không còn tồn tại, đã chọn môn học đầu tiên có sẵn.')),
          );
        }
      }
    } else {
      _resetDialogState(); 
    }

    if (subjects.isEmpty && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm Môn học ở tab Môn học trước khi tạo nhóm.')),
      );
      return;
    }
    
    // Ensure dialog specific states are fresh for StatefulBuilder
    MonHoc? currentDialogMonHoc = _selectedMonHocDialog;
    String? currentDialogHocKy = _selectedHocKyDialog;
    String? currentDialogNamHoc = _selectedNamHocDialog;


    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          // On first build of dialog, if adding and subjects are available, ensure one is selected
          if (!isEditing && currentDialogMonHoc == null && subjects.isNotEmpty) {
              currentDialogMonHoc = subjects.first;
          }

          return AlertDialog(
            title: Text(isEditing ? 'Chỉnh sửa Nhóm học phần' : 'Tạo nhóm học phần mới'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (subjects.isNotEmpty)
                      DropdownButtonFormField<MonHoc>(
                        value: currentDialogMonHoc,
                        decoration: const InputDecoration(labelText: 'Môn học'),
                        items: subjects.map<DropdownMenuItem<MonHoc>>((MonHoc subject) {
                          return DropdownMenuItem<MonHoc>(
                            value: subject,
                            child: Text(subject.tenMonHoc, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (MonHoc? newValue) {
                          stfSetState(() {
                            currentDialogMonHoc = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Vui lòng chọn môn học' : null,
                      )
                    else if (!isEditing) 
                      const Text('Không có môn học nào. Vui lòng thêm môn học trước.'),
                    TextFormField(
                      controller: _groupNameController,
                      decoration: const InputDecoration(labelText: 'Tên nhóm'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên nhóm';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: currentDialogHocKy,
                      decoration: const InputDecoration(labelText: 'Học kỳ'),
                      items: ['Học kỳ 1', 'Học kỳ 2', 'Học kỳ hè'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (String? newValue) {
                        stfSetState(() {
                          currentDialogHocKy = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Vui lòng chọn học kỳ' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: currentDialogNamHoc,
                      decoration: const InputDecoration(labelText: 'Năm học'),
                      items: _academicYearOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (String? newValue) {
                        stfSetState(() {
                          currentDialogNamHoc = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Vui lòng chọn năm học' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _resetDialogState(); // Reset controllers and outer state
                },
              ),
              ElevatedButton(
                child: Text(isEditing ? 'Lưu thay đổi' : 'Tạo nhóm'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (currentDialogMonHoc == null && subjects.isNotEmpty) {
                       ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Môn học không được để trống.')),
                      );
                      return;
                    }

                    final tenNhomHocPhanLog = _groupNameController.text.trim();
                    
                    // Update the screen state variables before processing
                    _selectedMonHocDialog = currentDialogMonHoc;
                    _selectedHocKyDialog = currentDialogHocKy;
                    _selectedNamHocDialog = currentDialogNamHoc;


                    if (!isEditing) {
                       if (_selectedMonHocDialog == null || _selectedHocKyDialog == null || _selectedNamHocDialog == null) {
                         // This case should be prevented by validators
                         ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')));
                         return;
                       }
                        final newGroup = NhomHocPhan(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          monHocId: _selectedMonHocDialog!.id,
                          tenMonHoc: _selectedMonHocDialog!.tenMonHoc,
                          tenNhomHocPhan: tenNhomHocPhanLog,
                          hocKy: _selectedHocKyDialog!,
                          namHoc: _selectedNamHocDialog!,
                          ngayTao: DateTime.now(),
                        );
                        ref.read(nhomHocPhanListProvider.notifier).update((state) => [newGroup, ...state]);
                        logHoatDong(
                          ref,
                          'Đã tạo nhóm HP: $tenNhomHocPhanLog (${_selectedMonHocDialog!.tenMonHoc})',
                          LoaiHoatDong.THEM_NHOM_HP,
                          HoatDongNotifier.getIconForLoai(LoaiHoatDong.THEM_NHOM_HP),
                          idDoiTuongLienQuan: newGroup.id,
                        );
                    } else {
                        if (groupToEdit == null || _selectedMonHocDialog == null || _selectedHocKyDialog == null || _selectedNamHocDialog == null) return;
                        final updatedGroup = groupToEdit.copyWith(
                            monHocId: _selectedMonHocDialog!.id,
                            tenMonHoc: _selectedMonHocDialog!.tenMonHoc,
                            tenNhomHocPhan: tenNhomHocPhanLog,
                            hocKy: _selectedHocKyDialog!,
                            namHoc: _selectedNamHocDialog!,
                        );
                        ref.read(nhomHocPhanListProvider.notifier).update((state) {
                          return state.map((g) => g.id == updatedGroup.id ? updatedGroup : g).toList();
                        });
                        logHoatDong(
                            ref,
                            'Đã sửa nhóm HP: $tenNhomHocPhanLog (${_selectedMonHocDialog!.tenMonHoc})',
                            LoaiHoatDong.SUA_NHOM_HP,
                            HoatDongNotifier.getIconForLoai(LoaiHoatDong.SUA_NHOM_HP),
                            idDoiTuongLienQuan: updatedGroup.id,
                        );
                    }
                    Navigator.of(dialogContext).pop();
                     _resetDialogState();
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Đã cập nhật nhóm học phần' : 'Đã tạo nhóm học phần mới')),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allNhomHocPhan = ref.watch(nhomHocPhanListProvider);
    final filteredNhomHocPhan = _getFilteredNhomHocPhan(allNhomHocPhan);
    final theme = Theme.of(context);
    // final subjects = ref.watch(monHocListProvider); // For dialog init

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách nhóm học phần',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 30,
                    tooltip: 'Tạo nhóm học phần mới',
                    onPressed: () => _showCreateGroupDialog(context),
                    color: theme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedHocKyFilter,
                      decoration: const InputDecoration(labelText: 'Học kỳ', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                       isExpanded: true,
                      items: ['Tất cả', 'Học kỳ 1', 'Học kỳ 2', 'Học kỳ hè'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedHocKyFilter = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedNamHocFilter,
                      decoration: const InputDecoration(labelText: 'Năm học', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      hint: const Text('Tất cả năm', style: TextStyle(fontSize: 14)),
                      isExpanded: true,
                      items: [ 'Tất cả năm', ..._academicYearOptions].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedNamHocFilter = value == 'Tất cả năm' ? null : value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên nhóm hoặc môn học...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => setState(() {}), 
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:12.0),
            child: filteredNhomHocPhan.isEmpty
                ? Center(
                    child: Text(
                      'Không có nhóm học phần nào.', 
                      style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic)
                    )
                  )
                : ListView.builder(
                    itemCount: filteredNhomHocPhan.length,
                    itemBuilder: (context, index) {
                      final nhomHocPhan = filteredNhomHocPhan[index];
                      return _NhomHocPhanCard(
                        nhomHocPhan: nhomHocPhan,
                        onEdit: () => _showCreateGroupDialog(context, groupToEdit: nhomHocPhan),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _NhomHocPhanCard extends ConsumerWidget {
  final NhomHocPhan nhomHocPhan;
  final VoidCallback onEdit; 

  const _NhomHocPhanCard({required this.nhomHocPhan, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nhomHocPhan.tenNhomHocPhan,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(); 
                    } else if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text('Bạn có chắc chắn muốn xóa nhóm "${nhomHocPhan.tenNhomHocPhan}"? Hành động này không thể hoàn tác.'),
                          actions: [
                            TextButton(
                              child: const Text('Hủy'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(ctx).pop(); 
                                final tenNhomHocPhanLog = nhomHocPhan.tenNhomHocPhan;
                                MonHoc? monHoc;
                                try {
                                  monHoc = ref.read(monHocListProvider).firstWhere((mh) => mh.id == nhomHocPhan.monHocId);
                                } catch (e) {
                                  // monHoc will be null if not found
                                }
                                
                                ref.read(nhomHocPhanListProvider.notifier).update((state) => 
                                    state.where((g) => g.id != nhomHocPhan.id).toList());
                                logHoatDong(
                                  ref,
                                  'Đã xóa nhóm HP: $tenNhomHocPhanLog (${monHoc?.tenMonHoc ?? "Không rõ môn"})',
                                  LoaiHoatDong.XOA_NHOM_HP,
                                  HoatDongNotifier.getIconForLoai(LoaiHoatDong.XOA_NHOM_HP, isDeletion: true),
                                  idDoiTuongLienQuan: nhomHocPhan.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã xóa nhóm học phần: ${nhomHocPhan.tenNhomHocPhan}')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 8), Text('Chỉnh sửa')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Môn học: ${nhomHocPhan.tenMonHoc}', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${nhomHocPhan.hocKy} - ${nhomHocPhan.namHoc}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                Text('Số SV: ${nhomHocPhan.soLuongSV}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)), 
              ],
            ),
            const SizedBox(height: 8),
            Text('Ngày tạo: ${DateFormat('dd/MM/yyyy').format(nhomHocPhan.ngayTao)}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(icon: Icons.people_alt_outlined, label: 'Sinh viên', onPressed: () { /* TODO */ }),
                _ActionButton(icon: Icons.quiz_outlined, label: 'Đề thi', onPressed: () { /* TODO */ }),
                _ActionButton(icon: Icons.bar_chart_outlined, label: 'Thống kê', onPressed: () { /* TODO */ }),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 36), // Adjust height
      ),
      onPressed: onPressed,
    );
  }
}

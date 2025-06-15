import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';

class MonHocScreen extends ConsumerStatefulWidget {
  const MonHocScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonHocScreen> createState() => _MonHocScreenState();
}

class _MonHocScreenState extends ConsumerState<MonHocScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showInactiveSubjects = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monHocList = ref.watch(monHocListProvider);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    // Lọc danh sách môn học theo từ khóa tìm kiếm
    List<MonHoc> filteredSubjects = monHocList.where((subject) {
      // Lọc theo từ khóa tìm kiếm (mã môn hoặc tên môn)
      final searchQuery = _searchController.text.toLowerCase().trim();
      final searchMatches = searchQuery.isEmpty ||
          subject.maMonHoc.toLowerCase().contains(searchQuery) ||
          subject.tenMonHoc.toLowerCase().contains(searchQuery);

      // Lọc theo trạng thái môn học nếu có thuộc tính trạng thái
      final statusMatches = _showInactiveSubjects || subject.trangThai;

      return searchMatches && statusMatches;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quản lý môn học',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditSubjectDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm môn học'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Thanh tìm kiếm
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Tìm kiếm môn học',
                  hintText: 'Nhập mã hoặc tên môn học',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),

              // Checkbox hiển thị môn học không hoạt động
              Row(
                children: [
                  Checkbox(
                    value: _showInactiveSubjects,
                    onChanged: (value) {
                      setState(() {
                        _showInactiveSubjects = value ?? false;
                      });
                    },
                  ),
                  const Text('Hiển thị cả môn học không hoạt động'),
                ],
              ),
            ],
          ),
        ),

        // Bảng hiển thị môn học
        Expanded(
          child: filteredSubjects.isEmpty
              ? Center(
                  child: Text(
                    'Không tìm thấy môn học nào',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : isSmallScreen
                  // Hiển thị dạng card cho màn hình nhỏ
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = filteredSubjects[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subject.tenMonHoc,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                          onPressed: () => _showAddEditSubjectDialog(context, subject: subject),
                                          tooltip: 'Chỉnh sửa',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                          onPressed: () => _confirmDeleteSubject(context, subject),
                                          tooltip: 'Xóa',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildSubjectInfoRow('Mã môn học:', subject.maMonHoc),
                                _buildSubjectInfoRow('Số tín chỉ:', subject.soTinChi.toString()),
                                _buildSubjectInfoRow('Số giờ LT:', subject.soGioLT.toString()),
                                _buildSubjectInfoRow('Số giờ TH:', subject.soGioTH.toString()),
                                if (subject.moTa != null && subject.moTa!.isNotEmpty) 
                                  _buildSubjectInfoRow('Mô tả:', subject.moTa!),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Trạng thái: ${subject.trangThai ? "Hoạt động" : "Khóa"}'),
                                    Switch(
                                      value: subject.trangThai,
                                      onChanged: (value) {
                                        _updateSubjectStatus(subject, value);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  // Hiển thị dạng bảng cho màn hình lớn
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(
                            theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          columns: const [
                            DataColumn(label: Text('Mã môn học')),
                            DataColumn(label: Text('Tên môn học')),
                            DataColumn(label: Text('Số tín chỉ')),
                            DataColumn(label: Text('Số giờ lý thuyết')),
                            DataColumn(label: Text('Số giờ thực hành')),
                            DataColumn(label: Text('Trạng thái')),
                            DataColumn(label: Text('Hành động')),
                          ],
                          rows: filteredSubjects.map((subject) {
                            return DataRow(
                              cells: [
                                DataCell(Text(subject.maMonHoc)),
                                DataCell(Text(subject.tenMonHoc)),
                                DataCell(Text(subject.soTinChi.toString())),
                                DataCell(Text(subject.soGioLT.toString())),
                                DataCell(Text(subject.soGioTH.toString())),
                                DataCell(
                                  Switch(
                                    value: subject.trangThai,
                                    onChanged: (value) {
                                      _updateSubjectStatus(subject, value);
                                    },
                                  ),
                                ),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showAddEditSubjectDialog(context, subject: subject),
                                      tooltip: 'Chỉnh sửa',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDeleteSubject(context, subject),
                                      tooltip: 'Xóa',
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  void _updateSubjectStatus(MonHoc subject, bool newStatus) {
    final updatedSubject = subject.copyWith(
      trangThai: newStatus,
    );

    ref.read(monHocListProvider.notifier).updateMonHoc(updatedSubject);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã ${newStatus ? "kích hoạt" : "vô hiệu hóa"} môn học: ${subject.tenMonHoc}'),
      ),
    );
  }

  Future<void> _showAddEditSubjectDialog(BuildContext context, {MonHoc? subject}) async {
    final isEditing = subject != null;

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: AddEditSubjectForm(
          isEditing: isEditing,
          initialSubject: subject,
        ),
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, MonHoc subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${subject.tenMonHoc}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(monHocListProvider.notifier).deleteMonHoc(subject.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa môn học: ${subject.tenMonHoc}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper widget để hiển thị thông tin môn học trên card
  Widget _buildSubjectInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class AddEditSubjectForm extends ConsumerStatefulWidget {
  final bool isEditing;
  final MonHoc? initialSubject;

  const AddEditSubjectForm({
    Key? key,
    required this.isEditing,
    this.initialSubject,
  }) : super(key: key);

  @override
  ConsumerState<AddEditSubjectForm> createState() => _AddEditSubjectFormState();
}

class _AddEditSubjectFormState extends ConsumerState<AddEditSubjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _maMonHocController = TextEditingController();
  final _tenMonHocController = TextEditingController();
  final _soTinChiController = TextEditingController();
  final _soGioLTController = TextEditingController();
  final _soGioTHController = TextEditingController();
  bool _trangThai = true;
  final _moTaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.initialSubject != null) {
      // Đổ dữ liệu môn học vào form nếu đang chỉnh sửa
      final subject = widget.initialSubject!;
      _maMonHocController.text = subject.maMonHoc;
      _tenMonHocController.text = subject.tenMonHoc;
      _soTinChiController.text = subject.soTinChi.toString();
      _soGioLTController.text = subject.soGioLT.toString();
      _soGioTHController.text = subject.soGioTH.toString();
      _trangThai = subject.trangThai;
      _moTaController.text = subject.moTa ?? '';
    }
  }

  @override
  void dispose() {
    _maMonHocController.dispose();
    _tenMonHocController.dispose();
    _soTinChiController.dispose();
    _soGioLTController.dispose();
    _soGioTHController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Container(
      width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.6,
      constraints: BoxConstraints(maxWidth: 600, maxHeight: isSmallScreen ? 650 : 600),
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Chỉnh sửa môn học' : 'Thêm môn học mới',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Mã môn học
              TextFormField(
                controller: _maMonHocController,
                decoration: const InputDecoration(
                  labelText: 'Mã môn học',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã môn học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tên môn học
              TextFormField(
                controller: _tenMonHocController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên môn học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Số tín chỉ, giờ lý thuyết, giờ thực hành
              isSmallScreen
                // Hiển thị theo chiều dọc trên màn hình nhỏ
                ? Column(
                    children: [
                      TextFormField(
                        controller: _soTinChiController,
                        decoration: const InputDecoration(
                          labelText: 'Số tín chỉ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập số tín chỉ';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Phải là số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _soGioLTController,
                        decoration: const InputDecoration(
                          labelText: 'Giờ lý thuyết',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập giờ LT';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Phải là số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _soGioTHController,
                        decoration: const InputDecoration(
                          labelText: 'Giờ thực hành',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập giờ TH';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Phải là số';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                // Hiển thị theo hàng ngang trên màn hình lớn
                : Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _soTinChiController,
                          decoration: const InputDecoration(
                            labelText: 'Số tín chỉ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nhập số tín chỉ';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Phải là số';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _soGioLTController,
                          decoration: const InputDecoration(
                            labelText: 'Giờ lý thuyết',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nhập giờ LT';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Phải là số';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _soGioTHController,
                          decoration: const InputDecoration(
                            labelText: 'Giờ thực hành',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nhập giờ TH';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Phải là số';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 16),

              // Mô tả (không bắt buộc)
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (không bắt buộc)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Trạng thái
              SwitchListTile(
                title: const Text('Trạng thái hoạt động'),
                value: _trangThai,
                onChanged: (value) {
                  setState(() {
                    _trangThai = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Nút Hủy và Lưu
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveSubject,
                    child: Text(widget.isEditing ? 'Cập nhật' : 'Tạo mới'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSubject() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final now = DateTime.now();

    if (widget.isEditing && widget.initialSubject != null) {
      // Cập nhật môn học hiện có
      final updatedSubject = widget.initialSubject!.copyWith(
        maMonHoc: _maMonHocController.text,
        tenMonHoc: _tenMonHocController.text,
        soTinChi: int.parse(_soTinChiController.text),
        soGioLT: int.parse(_soGioLTController.text),
        soGioTH: int.parse(_soGioTHController.text),
        trangThai: _trangThai,
        moTa: _moTaController.text.isEmpty ? null : _moTaController.text,
      );

      ref.read(monHocListProvider.notifier).updateMonHoc(updatedSubject);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật môn học: ${updatedSubject.tenMonHoc}')),
      );
    } else {
      // Tạo môn học mới
      final newSubject = MonHoc(
        id: now.millisecondsSinceEpoch.toString(),
        maMonHoc: _maMonHocController.text,
        tenMonHoc: _tenMonHocController.text,
        soTinChi: int.parse(_soTinChiController.text),
        soGioLT: int.parse(_soGioLTController.text),
        soGioTH: int.parse(_soGioTHController.text),
        trangThai: _trangThai,
        moTa: _moTaController.text.isEmpty ? null : _moTaController.text,
      );

      ref.read(monHocListProvider.notifier).addMonHoc(newSubject);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm môn học mới: ${newSubject.tenMonHoc}')),
      );
    }
  }
} 
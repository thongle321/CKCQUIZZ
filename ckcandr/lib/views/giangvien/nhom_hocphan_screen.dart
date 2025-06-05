import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Not used
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart'; // Import provider mới
import 'package:ckcandr/models/mon_hoc_model.dart'; // Import model MonHoc
// import 'package:ckcandr/models/nhom_hocphan_model.dart'; // Using local mock
// import 'package:ckcandr/services/nhom_hocphan_service.dart'; // Not used for mock
// import 'package:ckcandr/services/mon_hoc_service.dart'; // Not used for mock
// import 'package:intl/intl.dart'; // Not used directly in this version

// Model cho Nhóm Học Phần. Nên được đặt trong file riêng (ví dụ: models/nhom_hocphan_model.dart)
class NhomHocPhan {
  final String id;
  final String tenNhom;
  final String monHocId;
  final String tenMonHoc; // Lưu lại tên môn học để tiện hiển thị
  final String namHoc;
  final int hocKy;
  final int soSinhVien;
  final DateTime ngayTao;

  NhomHocPhan({
    required this.id,
    required this.tenNhom,
    required this.monHocId,
    required this.tenMonHoc,
    required this.namHoc,
    required this.hocKy,
    required this.soSinhVien,
    required this.ngayTao,
  });
}

// Provider để quản lý danh sách nhóm học phần người dùng tạo ra.
// Khởi tạo rỗng theo yêu cầu của người dùng.
final tempNhomHocPhanListProvider = StateProvider<List<NhomHocPhan>>((ref) => []);

class NhomHocPhanScreen extends ConsumerStatefulWidget {
  const NhomHocPhanScreen({super.key});

  @override
  ConsumerState<NhomHocPhanScreen> createState() => _NhomHocPhanScreenState();
}

class _NhomHocPhanScreenState extends ConsumerState<NhomHocPhanScreen> {
  int? _selectedHocKyFilter;
  String? _selectedNamHocFilter;
  List<String> _namHocOptions = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namHocOptions = _generateNamHocOptions();
    // Đặt năm học mặc định là "2023-2024" hoặc năm đầu tiên trong danh sách
    const String defaultSchoolYear = '2023-2024';
    if (_namHocOptions.contains(defaultSchoolYear)) {
      _selectedNamHocFilter = defaultSchoolYear;
    } else if (_namHocOptions.isNotEmpty) {
      _selectedNamHocFilter = _namHocOptions.first;
    }
  }

  List<String> _generateNamHocOptions() {
    List<String> years = [];
    for (int i = 2020; i <= 2035 - 1; i++) {
      years.add('$i-${i + 1}');
    }
    return years;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NhomHocPhan> _getFilteredNhomHocPhan(List<NhomHocPhan> allNhomHocPhan) {
    return allNhomHocPhan.where((nhom) {
      final hocKyMatch = _selectedHocKyFilter == null || nhom.hocKy == _selectedHocKyFilter;
      final namHocMatch = _selectedNamHocFilter == null || nhom.namHoc == _selectedNamHocFilter;
      final searchMatch = _searchController.text.isEmpty ||
          nhom.tenNhom.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          nhom.tenMonHoc.toLowerCase().contains(_searchController.text.toLowerCase());
      return hocKyMatch && namHocMatch && searchMatch;
    }).toList();
  }

  void _showCreateGroupDialog() {
    final List<MonHoc> subjects = ref.watch(monHocListProvider);
    MonHoc? selectedMonHocObject = subjects.isNotEmpty ? subjects.first : null;
    String? selectedTenNhom;
    int? selectedHocKyDialog = 1;
    String? selectedNamHocDialog = _selectedNamHocFilter ?? (_namHocOptions.isNotEmpty ? _namHocOptions.first : null);
    final formKey = GlobalKey<FormState>();

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm môn học trong tab "Môn học" trước.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tạo nhóm học phần mới'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DropdownButtonFormField<MonHoc>(
                        decoration: const InputDecoration(labelText: 'Môn học'),
                        value: selectedMonHocObject,
                        items: subjects.map((MonHoc monHoc) {
                          return DropdownMenuItem<MonHoc>(
                            value: monHoc,
                            child: Text(monHoc.tenMonHoc, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (MonHoc? newValue) {
                          setDialogState(() {
                            selectedMonHocObject = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Vui lòng chọn môn học' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Tên nhóm'),
                        onChanged: (value) => selectedTenNhom = value.trim(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên nhóm';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Học kỳ'),
                              value: selectedHocKyDialog,
                              items: const [
                                DropdownMenuItem<int>(value: 1, child: Text('Học kỳ 1')),
                                DropdownMenuItem<int>(value: 2, child: Text('Học kỳ 2')),
                              ],
                              onChanged: (int? newValue) {
                                setDialogState(() {
                                  selectedHocKyDialog = newValue;
                                });
                              },
                              validator: (value) => value == null ? 'Vui lòng chọn học kỳ' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Năm học'),
                              value: selectedNamHocDialog,
                              items: _namHocOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setDialogState(() {
                                  selectedNamHocDialog = newValue;
                                });
                              },
                              validator: (value) => value == null ? 'Vui lòng chọn năm học' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Tạo nhóm'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedMonHocObject == null) return; // Should be caught by validator

                      final newGroup = NhomHocPhan(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        tenNhom: selectedTenNhom!,
                        monHocId: selectedMonHocObject!.id,
                        tenMonHoc: selectedMonHocObject!.tenMonHoc,
                        hocKy: selectedHocKyDialog!,
                        namHoc: selectedNamHocDialog!,
                        soSinhVien: 0,
                        ngayTao: DateTime.now(),
                      );
                      ref.read(tempNhomHocPhanListProvider.notifier).update((state) => [...state, newGroup]);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã tạo nhóm: ${newGroup.tenNhom}')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allNhomHocPhan = ref.watch(tempNhomHocPhanListProvider);
    final filteredNhomHocPhan = _getFilteredNhomHocPhan(allNhomHocPhan);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý nhóm học phần',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 30,
                tooltip: 'Tạo nhóm học phần mới',
                onPressed: _showCreateGroupDialog,
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nhóm học phần...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildFilterButton(context, 'Học kỳ 1', 1),
                      _buildFilterButton(context, 'Học kỳ 2', 2),
                      SizedBox(
                        width: isSmallScreen ? double.infinity : 200,
                        child: DropdownButtonFormField<String>(
                          value: _selectedNamHocFilter,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: theme.primaryColor, width: 2),
                            ),
                          ),
                          hint: const Text('Năm học'),
                          isExpanded: true,
                          items: _namHocOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: isSmallScreen ? 14 : 15)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedNamHocFilter = newValue;
                            });
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return _namHocOptions.map<Widget>((String item) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: filteredNhomHocPhan.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có nhóm học phần nào. Hãy thêm nhóm mới hoặc kiểm tra lại bộ lọc.',
                            style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredNhomHocPhan.length,
                          itemBuilder: (context, index) {
                            return _NhomHocPhanCard(nhomHocPhan: filteredNhomHocPhan[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context, String text, int hocKy) {
    final bool isSelected = _selectedHocKyFilter == hocKy;
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? theme.primaryColor : theme.cardColor,
        foregroundColor: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: () {
        setState(() {
          if (_selectedHocKyFilter == hocKy) {
            _selectedHocKyFilter = null;
          } else {
            _selectedHocKyFilter = hocKy;
          }
        });
      },
      child: Text(text),
    );
  }
}

class _NhomHocPhanCard extends ConsumerWidget { // Chuyển sang ConsumerWidget nếu không có state cục bộ
  final NhomHocPhan nhomHocPhan;

  const _NhomHocPhanCard({required this.nhomHocPhan});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Thêm WidgetRef
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    nhomHocPhan.tenNhom,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 18 : 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                  onSelected: (value) {
                    if (value == 'edit') {
                      print('Edit: ${nhomHocPhan.tenNhom}');
                      // TODO: Implement edit dialog/screen for NhomHocPhan
                    } else if (value == 'delete') {
                      // Xác nhận trước khi xóa
                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text('Bạn có chắc chắn muốn xóa nhóm "${nhomHocPhan.tenNhom}"?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(tempNhomHocPhanListProvider.notifier).update(
                                      (state) => state.where((item) => item.id != nhomHocPhan.id).toList(),
                                    );
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã xóa nhóm: ${nhomHocPhan.tenNhom}')),
                                );
                              },
                              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Chỉnh sửa'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Xóa'),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              nhomHocPhan.tenMonHoc,
              style: textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontSize: isSmallScreen ? 15 : 16),
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(context, Icons.calendar_today, '${nhomHocPhan.namHoc}, HK${nhomHocPhan.hocKy}', isSmallScreen),
            _buildInfoRow(context, Icons.group, '${nhomHocPhan.soSinhVien} sinh viên', isSmallScreen),
            _buildInfoRow(context, Icons.access_time, 'Ngày tạo: ${nhomHocPhan.ngayTao.day.toString().padLeft(2, '0')}/${nhomHocPhan.ngayTao.month.toString().padLeft(2, '0')}/${nhomHocPhan.ngayTao.year}', isSmallScreen),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildActionButton(context, 'SV', Icons.people_alt_outlined, Colors.green, () {}),
                _buildActionButton(context, 'Đề thi', Icons.assignment_outlined, Colors.orange, () {}),
                _buildActionButton(context, 'Thống kê', Icons.bar_chart_outlined, Colors.purple, () {}),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, bool isSmallScreen) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? 16 : 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
          const SizedBox(width: 8.0),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(fontSize: isSmallScreen ? 13 : 14))),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return ElevatedButton.icon(
      icon: Icon(icon, size: isSmallScreen ? 16 : 18),
      label: Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12, vertical: isSmallScreen ? 6 : 8),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onPressed: onPressed,
    );
  }
}

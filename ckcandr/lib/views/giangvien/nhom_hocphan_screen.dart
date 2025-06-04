import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/nhom_hocphan_model.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/services/nhom_hocphan_service.dart';
import 'package:ckcandr/services/mon_hoc_service.dart';
import 'package:intl/intl.dart';

class NhomHocPhanScreen extends ConsumerStatefulWidget {
  const NhomHocPhanScreen({super.key});

  @override
  ConsumerState<NhomHocPhanScreen> createState() => _NhomHocPhanScreenState();
}

class _NhomHocPhanScreenState extends ConsumerState<NhomHocPhanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nhomHocPhanAsyncValue = ref.watch(nhomHocPhanListProvider);
    final monHocAsyncValue = ref.watch(monHocListProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với tiêu đề và nút thêm mới
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý nhóm học phần',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddNhomHocPhanDialog(context, ref);
                },
                icon: const Icon(Icons.add),
                label: const Text('Tạo nhóm học phần mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nhóm học phần...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          // Filters
          const SizedBox(height: 16),
          _buildFilterOptions(isDarkMode),
          
          // Danh sách nhóm học phần
          const SizedBox(height: 16),
          Expanded(
            child: nhomHocPhanAsyncValue.when(
              data: (nhomHocPhanList) => nhomHocPhanList.isEmpty
                ? _buildEmptyState()
                : _buildNhomHocPhanList(
                    nhomHocPhanList, 
                    monHocAsyncValue,
                    isDarkMode,
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => SelectableText.rich(
                TextSpan(
                  text: 'Lỗi: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  children: [
                    TextSpan(
                      text: error.toString(),
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(bool isDarkMode) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Học kỳ 1'),
          selected: false,
          onSelected: (selected) {
            // TODO: Áp dụng filter
          },
          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
        ),
        FilterChip(
          label: const Text('Học kỳ 2'),
          selected: false,
          onSelected: (selected) {
            // TODO: Áp dụng filter
          },
          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
        ),
        FilterChip(
          label: const Text('Năm 2023-2024'),
          selected: true,
          onSelected: (selected) {
            // TODO: Áp dụng filter
          },
          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
          selectedColor: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Chưa có nhóm học phần nào',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy tạo nhóm học phần mới để bắt đầu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNhomHocPhanList(
    List<NhomHocPhan> nhomHocPhanList,
    AsyncValue<List<MonHoc>> monHocAsyncValue,
    bool isDarkMode,
  ) {
    // Lọc theo search query
    final filteredList = _searchQuery.isEmpty
        ? nhomHocPhanList
        : nhomHocPhanList
            .where((nhom) => 
                nhom.tenNhom.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhóm học phần "$_searchQuery"',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return monHocAsyncValue.when(
      data: (monHocList) {
        // Tạo map từ ID môn học tới tên môn học
        final Map<String, String> monHocMap = {
          for (var monHoc in monHocList) monHoc.id: monHoc.tenMonHoc
        };

        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final nhom = filteredList[index];
            final tenMonHoc = monHocMap[nhom.monHocId] ?? 'Không xác định';

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Điều hướng đến chi tiết nhóm
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nhom.tenNhom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tenMonHoc,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              _showNhomHocPhanOptions(context, nhom, ref);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.calendar_today, '${nhom.namHoc}, ${nhom.hocKy}'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.group, '${nhom.soSV} sinh viên'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.access_time,
                        'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(nhom.ngayTao)}',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Hiển thị danh sách SV
                            },
                            icon: const Icon(Icons.people, size: 18),
                            label: const Text('SV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 12),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Hiển thị danh sách đề thi
                            },
                            icon: const Icon(Icons.assignment, size: 18),
                            label: const Text('Đề thi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 12),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Hiển thị thống kê
                            },
                            icon: const Icon(Icons.analytics, size: 18),
                            label: const Text('Thống kê'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 12),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Lỗi khi tải thông tin môn học')),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showNhomHocPhanOptions(BuildContext context, NhomHocPhan nhom, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Chỉnh sửa'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditNhomHocPhanDialog(context, nhom, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Quản lý sinh viên'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mở màn hình quản lý sinh viên
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Quản lý đề thi'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mở màn hình quản lý đề thi
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa nhóm học phần', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, nhom);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddNhomHocPhanDialog(BuildContext context, WidgetRef ref) {
    final tenNhomController = TextEditingController();
    final namHocController = TextEditingController(text: '2023-2024');
    String selectedMonHoc = '';
    String selectedHocKy = 'HK1';
    final formKey = GlobalKey<FormState>();

    final monHocAsyncValue = ref.watch(monHocListProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo nhóm học phần mới'),
        content: monHocAsyncValue.when(
          data: (monHocList) {
            if (monHocList.isEmpty) {
              return const Text('Không có môn học nào. Vui lòng tạo môn học trước.');
            }
            selectedMonHoc = monHocList[0].id;
            
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Môn học',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMonHoc,
                      items: monHocList.map((monHoc) {
                        return DropdownMenuItem<String>(
                          value: monHoc.id,
                          child: Text(monHoc.tenMonHoc),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedMonHoc = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn môn học';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: tenNhomController,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhóm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên nhóm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Học kỳ',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedHocKy,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'HK1',
                                child: Text('Học kỳ 1'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'HK2',
                                child: Text('Học kỳ 2'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'HK3',
                                child: Text('Học kỳ hè'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                selectedHocKy = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: namHocController,
                            decoration: const InputDecoration(
                              labelText: 'Năm học',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập năm học';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Text(
            'Lỗi khi tải danh sách môn học. Vui lòng thử lại sau.',
            style: TextStyle(color: Colors.red),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          monHocAsyncValue.maybeWhen(
            data: (monHocList) {
              if (monHocList.isEmpty) {
                return TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                );
              }
              
              return ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final nhomHocPhan = NhomHocPhan(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      tenNhom: tenNhomController.text,
                      monHocId: selectedMonHoc,
                      namHoc: namHocController.text,
                      hocKy: selectedHocKy,
                      giangVienId: 'current_user_id', // TODO: Lấy ID giảng viên hiện tại
                      ngayTao: DateTime.now(),
                    );

                    // TODO: Gọi API để tạo nhóm học phần mới
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tạo nhóm học phần thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Tạo nhóm'),
              );
            },
            orElse: () => const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showEditNhomHocPhanDialog(BuildContext context, NhomHocPhan nhom, WidgetRef ref) {
    final tenNhomController = TextEditingController(text: nhom.tenNhom);
    final namHocController = TextEditingController(text: nhom.namHoc);
    String selectedMonHoc = nhom.monHocId;
    String selectedHocKy = nhom.hocKy;
    final formKey = GlobalKey<FormState>();

    final monHocAsyncValue = ref.watch(monHocListProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa nhóm học phần'),
        content: monHocAsyncValue.when(
          data: (monHocList) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Môn học',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMonHoc,
                      items: monHocList.map((monHoc) {
                        return DropdownMenuItem<String>(
                          value: monHoc.id,
                          child: Text(monHoc.tenMonHoc),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedMonHoc = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: tenNhomController,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhóm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên nhóm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Học kỳ',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedHocKy,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'HK1',
                                child: Text('Học kỳ 1'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'HK2',
                                child: Text('Học kỳ 2'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'HK3',
                                child: Text('Học kỳ hè'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                selectedHocKy = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: namHocController,
                            decoration: const InputDecoration(
                              labelText: 'Năm học',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập năm học';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Text(
            'Lỗi khi tải danh sách môn học. Vui lòng thử lại sau.',
            style: TextStyle(color: Colors.red),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          monHocAsyncValue.maybeWhen(
            data: (_) => ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedNhom = nhom.copyWith(
                    tenNhom: tenNhomController.text,
                    monHocId: selectedMonHoc,
                    namHoc: namHocController.text,
                    hocKy: selectedHocKy,
                  );

                  // TODO: Gọi API để cập nhật nhóm học phần
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật nhóm học phần thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Cập nhật'),
            ),
            orElse: () => const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, NhomHocPhan nhom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhóm học phần "${nhom.tenNhom}"? Tất cả dữ liệu liên quan như sinh viên, đề thi sẽ bị xóa và không thể khôi phục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Gọi API để xóa nhóm học phần
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa nhóm học phần thành công'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

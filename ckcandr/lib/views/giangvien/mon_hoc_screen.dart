import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/services/mon_hoc_service.dart';

class MonHocScreen extends ConsumerWidget {
  const MonHocScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monHocAsyncValue = ref.watch(monHocListProvider);
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    
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
                'Danh sách môn học',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddMonHocDialog(context, ref);
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm môn học'),
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
            decoration: InputDecoration(
              hintText: 'Tìm kiếm môn học...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          
          // Danh sách môn học
          Expanded(
            child: monHocAsyncValue.when(
              data: (monHocList) => monHocList.isEmpty
                  ? _buildEmptyState()
                  : _buildMonHocGrid(monHocList, cardColor, screenSize, ref),
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Chưa có môn học nào',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm môn học mới để bắt đầu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMonHocGrid(List<MonHoc> monHocList, Color? cardColor, Size screenSize, WidgetRef ref) {
    // Responsive grid - điều chỉnh số cột dựa trên kích thước màn hình
    final crossAxisCount = screenSize.width < 600 ? 1 : screenSize.width < 900 ? 2 : 3;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: screenSize.width < 600 ? 2.5 : 2.2,
      ),
      itemCount: monHocList.length,
      itemBuilder: (context, index) {
        final monHoc = monHocList[index];
        return Card(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showMonHocDetailDialog(context, monHoc),
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
                        child: Text(
                          monHoc.tenMonHoc,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditMonHocDialog(context, monHoc, ref);
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(context, monHoc);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Xóa', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã môn học: ${monHoc.maMonHoc}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số tín chỉ: ${monHoc.soTinChi}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMonHocDetailDialog(BuildContext context, MonHoc monHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(monHoc.tenMonHoc),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${monHoc.id}'),
            const SizedBox(height: 8),
            Text('Mã môn học: ${monHoc.maMonHoc}'),
            const SizedBox(height: 8),
            Text('Số tín chỉ: ${monHoc.soTinChi}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAddMonHocDialog(BuildContext context, WidgetRef ref) {
    final maMonHocController = TextEditingController();
    final tenMonHocController = TextEditingController();
    final soTinChiController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm môn học mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: maMonHocController,
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
                TextFormField(
                  controller: tenMonHocController,
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
                TextFormField(
                  controller: soTinChiController,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tín chỉ';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Số tín chỉ phải là số nguyên';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Gọi API để thêm môn học mới
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thêm môn học thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditMonHocDialog(BuildContext context, MonHoc monHoc, WidgetRef ref) {
    final maMonHocController = TextEditingController(text: monHoc.maMonHoc);
    final tenMonHocController = TextEditingController(text: monHoc.tenMonHoc);
    final soTinChiController = TextEditingController(text: monHoc.soTinChi.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa môn học'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: maMonHocController,
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
                TextFormField(
                  controller: tenMonHocController,
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
                TextFormField(
                  controller: soTinChiController,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tín chỉ';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Số tín chỉ phải là số nguyên';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Gọi API để cập nhật môn học
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật môn học thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, MonHoc monHoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học ${monHoc.tenMonHoc}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Gọi API để xóa môn học
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa môn học thành công'),
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

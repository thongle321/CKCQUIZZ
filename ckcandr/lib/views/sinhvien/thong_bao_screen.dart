import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ThongBaoScreen extends ConsumerStatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  ConsumerState<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends ConsumerState<ThongBaoScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  
  // Data mẫu cho danh sách thông báo
  final List<ThongBao> _thongBaoList = [
    ThongBao(
      id: '1',
      tieuDe: 'Làm đề kiểm tra NMLT',
      doiTuongGui: 'Gửi cho nhóm học phần NMLT - HK1',
      thoiGian: DateTime(2024, 4, 1, 12, 0),
    ),
    // Có thể thêm các thông báo mẫu khác
  ];
  
  List<ThongBao> get _filteredThongBaoList {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _thongBaoList;
    }
    return _thongBaoList.where((thongBao) {
      return thongBao.tieuDe.toLowerCase().contains(query) || 
             thongBao.doiTuongGui.toLowerCase().contains(query);
    }).toList();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _createNotification() {
    // TODO: Implement create notification logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo thông báo mới'),
        content: const Text('Chức năng đang được phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _editNotification(ThongBao thongBao) {
    // TODO: Implement edit notification logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông báo'),
        content: Text('Chỉnh sửa thông báo: ${thongBao.tieuDe}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _deleteNotification(ThongBao thongBao) {
    // TODO: Implement delete notification logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: Text('Bạn có chắc chắn muốn xóa thông báo: ${thongBao.tieuDe}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _thongBaoList.remove(thongBao);
              });
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần tìm kiếm và nút tạo
            Row(
              children: [
                // Ô tìm kiếm
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thông báo',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Nút tạo thông báo mới
                ElevatedButton.icon(
                  onPressed: _createNotification,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo thông báo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Danh sách thông báo
            Expanded(
              child: ListView.builder(
                itemCount: _filteredThongBaoList.length,
                itemBuilder: (context, index) {
                  final thongBao = _filteredThongBaoList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề thông báo
                          Text(
                            thongBao.tieuDe,
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Đối tượng gửi
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                thongBao.doiTuongGui,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Thời gian và các nút tương tác
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Thời gian
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${DateFormat('HH:mm').format(thongBao.thoiGian)} ${DateFormat('dd/MM/yyyy').format(thongBao.thoiGian)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              // Các nút tương tác
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue.shade700,
                                    ),
                                    onPressed: () => _editNotification(thongBao),
                                    tooltip: 'Chỉnh sửa',
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    iconSize: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteNotification(thongBao),
                                    tooltip: 'Xóa',
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Phân trang
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1 
                    ? () => setState(() => _currentPage--)
                    : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentPage = 3),
                  child: const Text('3'),
                ),
                const Text('...'),
                TextButton(
                  onPressed: () => setState(() => _currentPage = 8),
                  child: const Text('8'),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _currentPage++),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Model cho thông báo
class ThongBao {
  final String id;
  final String tieuDe;
  final String doiTuongGui;
  final DateTime thoiGian;
  
  ThongBao({
    required this.id,
    required this.tieuDe,
    required this.doiTuongGui,
    required this.thoiGian,
  });
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DanhMucMonHocScreen extends ConsumerStatefulWidget {
  const DanhMucMonHocScreen({super.key});

  @override
  ConsumerState<DanhMucMonHocScreen> createState() => _DanhMucMonHocScreenState();
}

class _DanhMucMonHocScreenState extends ConsumerState<DanhMucMonHocScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  
  // Data mẫu cho danh sách môn học
  final List<MonHoc> _monHocList = [
    MonHoc(
      id: '3221001',
      ten: 'Vật lý đại cương',
      soTinChi: 4,
      soTietLyThuyet: 30,
      soTietThucHanh: 15,
    ),
    // Thêm các môn học mẫu khác ở đây
  ];
  
  List<MonHoc> get _filteredMonHocList {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _monHocList;
    }
    return _monHocList.where((monHoc) {
      return monHoc.ten.toLowerCase().contains(query) || 
             monHoc.id.toLowerCase().contains(query);
    }).toList();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách môn học'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần tìm kiếm và nút thêm
              Row(
                children: [
                  // Ô tìm kiếm
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm môn học',
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
                  // Nút thêm môn học mới
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Xử lý thêm môn học mới
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('THÊM MÔN HỌC MỚI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bảng danh sách môn học
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24.0,
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade100,
                      ),
                      columns: const [
                        DataColumn(label: Text('Mã môn', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tên môn', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Số tín chỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Số tiết lý thuyết', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Số tiết thực hành', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _filteredMonHocList.map((monHoc) {
                        return DataRow(
                          cells: [
                            DataCell(Text(monHoc.id)),
                            DataCell(Text(monHoc.ten)),
                            DataCell(Text(monHoc.soTinChi.toString())),
                            DataCell(Text(monHoc.soTietLyThuyet.toString())),
                            DataCell(Text(monHoc.soTietThucHanh.toString())),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Nút xem chi tiết
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue),
                                    onPressed: () {
                                      // TODO: Xử lý xem chi tiết
                                    },
                                    splashRadius: 20,
                                  ),
                                  // Nút chỉnh sửa
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.green),
                                    onPressed: () {
                                      // TODO: Xử lý chỉnh sửa
                                    },
                                    splashRadius: 20,
                                  ),
                                  // Nút xóa
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      // TODO: Xử lý xóa
                                    },
                                    splashRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              // Phân trang
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1 ? () {
                        setState(() {
                          _currentPage--;
                        });
                      } : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Text('$_currentPage'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _currentPage++;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.last_page),
                      onPressed: () {
                        setState(() {
                          _currentPage = (_monHocList.length / _itemsPerPage).ceil();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model cho môn học
class MonHoc {
  final String id;
  final String ten;
  final int soTinChi;
  final int soTietLyThuyet;
  final int soTietThucHanh;
  
  MonHoc({
    required this.id,
    required this.ten,
    required this.soTinChi,
    required this.soTietLyThuyet,
    required this.soTietThucHanh,
  });
} 
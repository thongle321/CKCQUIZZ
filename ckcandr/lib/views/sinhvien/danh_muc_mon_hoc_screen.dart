import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';

class DanhMucMonHocScreen extends ConsumerStatefulWidget {
  const DanhMucMonHocScreen({super.key});

  @override
  ConsumerState<DanhMucMonHocScreen> createState() => _DanhMucMonHocScreenState();
}

class _DanhMucMonHocScreenState extends ConsumerState<DanhMucMonHocScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _showInactiveSubjects = false;

  List<MonHoc> get _filteredMonHocList {
    try {
      final monHocList = ref.watch(monHocListProvider);
      if (monHocList.isEmpty) return <MonHoc>[];

      final query = _searchController.text.toLowerCase();

      return monHocList.where((monHoc) {
        try {
          // Lọc theo từ khóa tìm kiếm
          final searchMatches = query.isEmpty ||
              (monHoc.maMonHoc.isNotEmpty && monHoc.maMonHoc.toLowerCase().contains(query)) ||
              (monHoc.tenMonHoc.isNotEmpty && monHoc.tenMonHoc.toLowerCase().contains(query));

          // Lọc theo trạng thái
          final statusMatches = _showInactiveSubjects || monHoc.trangThai;

          return searchMatches && statusMatches && !monHoc.isDeleted;
        } catch (e) {
          debugPrint('Error filtering monHoc ${monHoc.id}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Error in _filteredMonHocList: $e');
      return <MonHoc>[];
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần tìm kiếm và bộ lọc
              Row(
                children: [
                  // Ô tìm kiếm
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm môn học (mã môn, tên môn)',
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
                      const Text('Hiển thị môn học không hoạt động'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bảng danh sách môn học
              Expanded(
                child: _filteredMonHocList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy môn học nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24.0,
                            headingRowHeight: 56,
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 56,
                            columns: const [
                              DataColumn(label: Text('Mã môn', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tên môn', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Số tín chỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Số giờ LT', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Số giờ TH', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _filteredMonHocList.map((monHoc) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(monHoc.maMonHoc)),
                                  DataCell(
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        monHoc.tenMonHoc,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(monHoc.soTinChi.toString())),
                                  DataCell(Text(monHoc.soGioLT.toString())),
                                  DataCell(Text(monHoc.soGioTH.toString())),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: monHoc.trangThai ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        monHoc.trangThai ? 'Hoạt động' : 'Không hoạt động',
                                        style: TextStyle(
                                          color: monHoc.trangThai ? Colors.green.shade700 : Colors.red.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Nút xem chi tiết
                                        IconButton(
                                          icon: const Icon(Icons.visibility, color: Colors.blue),
                                          onPressed: () {
                                            _showMonHocDetail(monHoc);
                                          },
                                          splashRadius: 20,
                                          tooltip: 'Xem chi tiết',
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
              if (_filteredMonHocList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hiển thị ${_filteredMonHocList.length} môn học',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Row(
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
                                _currentPage = (_filteredMonHocList.length / _itemsPerPage).ceil();
                              });
                            },
                          ),
                        ],
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

  // Hiển thị chi tiết môn học
  void _showMonHocDetail(MonHoc monHoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết môn học'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Mã môn học:', monHoc.maMonHoc),
                _buildDetailRow('Tên môn học:', monHoc.tenMonHoc),
                _buildDetailRow('Số tín chỉ:', monHoc.soTinChi.toString()),
                _buildDetailRow('Số giờ lý thuyết:', monHoc.soGioLT.toString()),
                _buildDetailRow('Số giờ thực hành:', monHoc.soGioTH.toString()),
                _buildDetailRow('Trạng thái:', monHoc.trangThai ? 'Hoạt động' : 'Không hoạt động'),
                if (monHoc.moTa != null && monHoc.moTa!.isNotEmpty)
                  _buildDetailRow('Mô tả:', monHoc.moTa!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
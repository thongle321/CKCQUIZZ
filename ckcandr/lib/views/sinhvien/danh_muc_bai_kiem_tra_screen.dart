import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DanhMucBaiKiemTraScreen extends ConsumerStatefulWidget {
  const DanhMucBaiKiemTraScreen({super.key});

  @override
  ConsumerState<DanhMucBaiKiemTraScreen> createState() => _DanhMucBaiKiemTraScreenState();
}

class _DanhMucBaiKiemTraScreenState extends ConsumerState<DanhMucBaiKiemTraScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Data mẫu cho danh sách bài kiểm tra
  final List<BaiKiemTra> _danhSachBaiKiemTra = [
    BaiKiemTra(
      id: '1',
      tenBaiKiemTra: 'Đề kiểm tra NMLT',
      nhomHocPhan: 'Giao cho nhóm học phần NMLT - HK1',
      trangThai: 'Đã đóng',
      thoiGianBatDau: 'Từ ngày 3/2/2024 12:00 AM',
      thoiGianKetThuc: 'đến 3/3/2024 12:00 AM',
    ),
    BaiKiemTra(
      id: '2',
      tenBaiKiemTra: 'Đề kiểm tra Toán',
      nhomHocPhan: 'Giao cho nhóm học phần Toán - HK1',
      trangThai: 'Đang mở',
      thoiGianBatDau: 'Từ ngày 10/2/2024 12:00 AM',
      thoiGianKetThuc: 'đến 10/3/2024 12:00 AM',
    ),
    BaiKiemTra(
      id: '3',
      tenBaiKiemTra: 'Đề kiểm tra Lập trình Web',
      nhomHocPhan: 'Giao cho nhóm học phần Web - HK1',
      trangThai: 'Sắp mở',
      thoiGianBatDau: 'Từ ngày 15/3/2024 12:00 AM',
      thoiGianKetThuc: 'đến 15/4/2024 12:00 AM',
    ),
  ];

  List<BaiKiemTra> get _filteredBaiKiemTra {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _danhSachBaiKiemTra;
    }
    return _danhSachBaiKiemTra.where((baiKiemTra) {
      return baiKiemTra.tenBaiKiemTra.toLowerCase().contains(query) || 
             baiKiemTra.nhomHocPhan.toLowerCase().contains(query);
    }).toList();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Xử lý khi bấm vào nút "Xem chi tiết"
  void _handleXemChiTiet(String id) {
    context.go('/sinhvien/bai-kiem-tra');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần tìm kiếm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm đề thi',
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
            
            // Dropdown lọc "Tất cả"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonHideUnderline(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: DropdownButton<String>(
                    value: 'all',
                    isExpanded: false,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(color: Colors.black),
                    items: <String>['all', 'open', 'closed', 'upcoming']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'all' ? 'Tất cả' : 
                          value == 'open' ? 'Đang mở' : 
                          value == 'closed' ? 'Đã đóng' : 'Sắp mở',
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // TODO: Implement filtering by status
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Danh sách bài kiểm tra
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filteredBaiKiemTra.length,
                itemBuilder: (context, index) {
                  final baiKiemTra = _filteredBaiKiemTra[index];
                  // Xác định màu cho trạng thái
                  Color statusColor;
                  if (baiKiemTra.trangThai == 'Đang mở') {
                    statusColor = Colors.green;
                  } else if (baiKiemTra.trangThai == 'Đã đóng') {
                    statusColor = Colors.red;
                  } else {
                    statusColor = Colors.blue;
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề và trạng thái
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  baiKiemTra.tenBaiKiemTra,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Trạng thái
                              Container(
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  baiKiemTra.trangThai,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Nhóm học phần
                          Text(
                            baiKiemTra.nhomHocPhan,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Thời gian
                          Row(
                            children: [
                              Icon(Icons.access_time_outlined, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${baiKiemTra.thoiGianBatDau} ${baiKiemTra.thoiGianKetThuc}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Nút xem chi tiết
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleXemChiTiet(baiKiemTra.id),
                              icon: const Icon(Icons.visibility),
                              label: const Text('Xem chi tiết'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Phân trang
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      // TODO: Previous page
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('2'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('8'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // TODO: Next page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model cho bài kiểm tra
class BaiKiemTra {
  final String id;
  final String tenBaiKiemTra;
  final String nhomHocPhan;
  final String trangThai;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;
  
  BaiKiemTra({
    required this.id,
    required this.tenBaiKiemTra,
    required this.nhomHocPhan,
    required this.trangThai,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
  });
} 
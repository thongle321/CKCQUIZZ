import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/models/de_kiem_tra_model.dart';
import 'package:ckcandr/providers/de_kiem_tra_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/core/widgets/loading_overlay.dart';

class DanhMucBaiKiemTraScreen extends ConsumerStatefulWidget {
  const DanhMucBaiKiemTraScreen({super.key});

  @override
  ConsumerState<DanhMucBaiKiemTraScreen> createState() => _DanhMucBaiKiemTraScreenState();
}

class _DanhMucBaiKiemTraScreenState extends ConsumerState<DanhMucBaiKiemTraScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'all';

  List<DeKiemTra> get _filteredBaiKiemTra {
    try {
      final deKiemTraList = ref.watch(deKiemTraListProvider);
      if (deKiemTraList.isEmpty) return <DeKiemTra>[];

      final query = _searchController.text.toLowerCase();

      return deKiemTraList.where((deKiemTra) {
        try {
          // Lọc theo từ khóa tìm kiếm
          final searchMatches = query.isEmpty ||
              (deKiemTra.tenDeThi.isNotEmpty && deKiemTra.tenDeThi.toLowerCase().contains(query));

          // Lọc theo trạng thái
          final currentStatus = deKiemTra.tinhTrangThai();
          final statusMatches = _selectedStatusFilter == 'all' ||
              (_selectedStatusFilter == 'open' && currentStatus == TrangThaiDeThi.dangDienRa) ||
              (_selectedStatusFilter == 'closed' && currentStatus == TrangThaiDeThi.daKetThuc) ||
              (_selectedStatusFilter == 'upcoming' && currentStatus == TrangThaiDeThi.moiTao);

          return searchMatches && statusMatches;
        } catch (e) {
          debugPrint('Error filtering deKiemTra ${deKiemTra.id}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Error in _filteredBaiKiemTra: $e');
      return <DeKiemTra>[];
    }
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
    return PageTransitionWrapper(
      child: Scaffold(
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
            
            // Dropdown lọc trạng thái
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
                    value: _selectedStatusFilter,
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
                      setState(() {
                        _selectedStatusFilter = newValue ?? 'all';
                      });
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Danh sách bài kiểm tra
            Expanded(
              child: _filteredBaiKiemTra.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy bài kiểm tra nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredBaiKiemTra.length,
                      itemBuilder: (context, index) {
                        final deKiemTra = _filteredBaiKiemTra[index];
                        final currentStatus = deKiemTra.tinhTrangThai();
                        final statusText = DeKiemTra.getTenTrangThai(currentStatus);

                        // Xác định màu cho trạng thái
                        Color statusColor;
                        switch (currentStatus) {
                          case TrangThaiDeThi.dangDienRa:
                            statusColor = Colors.green;
                            break;
                          case TrangThaiDeThi.daKetThuc:
                            statusColor = Colors.red;
                            break;
                          case TrangThaiDeThi.moiTao:
                            statusColor = Colors.blue;
                            break;
                          case TrangThaiDeThi.tam:
                            statusColor = Colors.orange;
                            break;
                        }

                        // Lấy thông tin nhóm học phần
                        final nhomHocPhanList = ref.watch(nhomHocPhanListProvider);
                        final nhomHocPhan = <dynamic>[];
                        try {
                          if (deKiemTra.danhSachNhomHPIds.isNotEmpty) {
                            nhomHocPhan.addAll(nhomHocPhanList.where((nhom) =>
                                deKiemTra.danhSachNhomHPIds.contains(nhom.id)).toList());
                          }
                        } catch (e) {
                          debugPrint('Error getting nhomHocPhan: $e');
                        }

                        // Lấy thông tin môn học
                        final monHocList = ref.watch(monHocListProvider);
                        dynamic monHoc;
                        try {
                          final monHocId = deKiemTra.monHocId;
                          if (monHocId != null && monHocId.isNotEmpty) {
                            final matchingMonHoc = monHocList.where((mon) => mon.id == monHocId);
                            monHoc = matchingMonHoc.isNotEmpty ? matchingMonHoc.first : null;
                          }
                        } catch (e) {
                          debugPrint('Error getting monHoc: $e');
                          monHoc = null;
                        }

                        final thoiGianKetThuc = deKiemTra.thoiGianBatDau.add(Duration(minutes: deKiemTra.thoiGianLamBai));

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
                                        deKiemTra.tenDeThi,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Trạng thái
                                    Container(
                                      decoration: BoxDecoration(
                                        color: statusColor == Colors.green
                                            ? Colors.green.shade100
                                            : statusColor == Colors.red
                                                ? Colors.red.shade100
                                                : statusColor == Colors.blue
                                                    ? Colors.blue.shade100
                                                    : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Môn học và nhóm học phần
                                if (monHoc != null)
                                  Text(
                                    'Môn học: ${monHoc.tenMonHoc} (${monHoc.maMonHoc})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (nhomHocPhan.isNotEmpty)
                                  Text(
                                    'Nhóm: ${nhomHocPhan.map((n) => n.tenNhom).join(', ')}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),

                                // Thời gian
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.access_time_outlined, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Từ ${DateFormat('dd/MM/yyyy HH:mm').format(deKiemTra.thoiGianBatDau)} đến ${DateFormat('dd/MM/yyyy HH:mm').format(thoiGianKetThuc)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Thời gian làm bài
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Thời gian làm bài: ${deKiemTra.thoiGianLamBai} phút',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Nút xem chi tiết
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _handleXemChiTiet(deKiemTra.id),
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
            
            // Thông tin tổng kết
            if (_filteredBaiKiemTra.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tổng số bài kiểm tra
                    Text(
                      'Tổng cộng: ${_filteredBaiKiemTra.length} bài kiểm tra',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Thống kê trạng thái - responsive
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildStatusCount('Đang mở', TrangThaiDeThi.dangDienRa, Colors.green),
                        _buildStatusCount('Đã đóng', TrangThaiDeThi.daKetThuc, Colors.red),
                        _buildStatusCount('Sắp mở', TrangThaiDeThi.moiTao, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildStatusCount(String label, TrangThaiDeThi status, Color color) {
    final count = _filteredBaiKiemTra.where((de) => de.tinhTrangThai() == status).length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
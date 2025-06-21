import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/nhom_hocphan_model.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/core/widgets/loading_overlay.dart';

class NhomHocPhanScreen extends ConsumerStatefulWidget {
  const NhomHocPhanScreen({super.key});

  @override
  ConsumerState<NhomHocPhanScreen> createState() => _NhomHocPhanScreenState();
}

class _NhomHocPhanScreenState extends ConsumerState<NhomHocPhanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMonHocFilter = 'all';
  String _selectedHocKyFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NhomHocPhan> get _filteredNhomHocPhan {
    try {
      final nhomHocPhanList = ref.watch(nhomHocPhanListProvider);
      if (nhomHocPhanList.isEmpty) return <NhomHocPhan>[];

      final query = _searchController.text.toLowerCase();

      return nhomHocPhanList.where((nhom) {
        try {
          // Lọc theo từ khóa tìm kiếm
          final searchMatches = query.isEmpty ||
              (nhom.tenNhom.isNotEmpty && nhom.tenNhom.toLowerCase().contains(query));

          // Lọc theo môn học
          final monHocMatches = _selectedMonHocFilter == 'all' ||
              nhom.monHocId == _selectedMonHocFilter;

          // Lọc theo học kỳ
          final hocKyMatches = _selectedHocKyFilter == 'all' ||
              nhom.hocKy == _selectedHocKyFilter;

          return searchMatches && monHocMatches && hocKyMatches && !nhom.isDeleted;
        } catch (e) {
          debugPrint('Error filtering nhomHocPhan ${nhom.id}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Error in _filteredNhomHocPhan: $e');
      return <NhomHocPhan>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xác định kích thước màn hình để điều chỉnh layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;

    // Số lượng cột hiển thị dựa trên kích thước màn hình
    int crossAxisCount = 4;
    if (isSmallScreen) {
      crossAxisCount = 1;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    }

    return PageTransitionWrapper(
      child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm và bộ lọc
          isSmallScreen
              ? Column(
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    const SizedBox(width: 16),
                    _buildFilters(),
                  ],
                ),

          const SizedBox(height: 24),

          // Tiêu đề
          Row(
            children: [
              const Text(
                'Danh sách nhóm học phần',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Tổng: ${_filteredNhomHocPhan.length} nhóm',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Danh sách nhóm học phần
          Expanded(
            child: _filteredNhomHocPhan.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_work_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy nhóm học phần nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : isSmallScreen
                    ? ListView.builder(
                        itemCount: _filteredNhomHocPhan.length,
                        itemBuilder: (context, index) {
                          final nhomHocPhan = _filteredNhomHocPhan[index];
                          final monHocList = ref.watch(monHocListProvider);
                          dynamic monHoc;
                          try {
                            if (nhomHocPhan.monHocId.isNotEmpty) {
                              final matchingMonHoc = monHocList.where((mon) => mon.id == nhomHocPhan.monHocId);
                              monHoc = matchingMonHoc.isNotEmpty ? matchingMonHoc.first : null;
                            }
                          } catch (e) {
                            debugPrint('Error getting monHoc for nhomHocPhan ${nhomHocPhan.id}: $e');
                            monHoc = null;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildGroupCard(
                              context,
                              nhomHocPhan,
                              monHoc,
                            ),
                          );
                        },
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: _filteredNhomHocPhan.length,
                        itemBuilder: (context, index) {
                          final nhomHocPhan = _filteredNhomHocPhan[index];
                          final monHocList = ref.watch(monHocListProvider);
                          dynamic monHoc;
                          try {
                            if (nhomHocPhan.monHocId.isNotEmpty) {
                              final matchingMonHoc = monHocList.where((mon) => mon.id == nhomHocPhan.monHocId);
                              monHoc = matchingMonHoc.isNotEmpty ? matchingMonHoc.first : null;
                            }
                          } catch (e) {
                            debugPrint('Error getting monHoc for nhomHocPhan ${nhomHocPhan.id}: $e');
                            monHoc = null;
                          }

                          return _buildGroupCard(
                            context,
                            nhomHocPhan,
                            monHoc,
                          );
                        },
                      ),
          ),
        ],
      ),
    )
    );
  }
  
  // Widget trường tìm kiếm
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm nhóm học phần...',
        prefixIcon: const Icon(Icons.search, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  // Widget bộ lọc
  Widget _buildFilters() {
    return Row(
      children: [
        // Lọc theo học kỳ
        DropdownButton<String>(
          value: _selectedHocKyFilter,
          hint: const Text('Học kỳ'),
          items: ['all', 'HK1', 'HK2', 'HK3'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == 'all' ? 'Tất cả HK' : value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedHocKyFilter = newValue ?? 'all';
            });
          },
        ),
      ],
    );
  }

  // Widget cho mỗi card nhóm
  Widget _buildGroupCard(BuildContext context, NhomHocPhan nhomHocPhan, dynamic monHoc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return InkWell(
      onTap: () {
        _showNhomHocPhanDetail(nhomHocPhan, monHoc);
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isSmallScreen ? 80 : 120,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 12),
        child: isSmallScreen
            ? Row(
                children: [
                  // Left side - Main info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nhomHocPhan.tenNhom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (monHoc != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            monHoc.tenMonHoc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right side - Stats
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${nhomHocPhan.soSV}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${nhomHocPhan.hocKy} - ${nhomHocPhan.namHoc}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nhomHocPhan.tenNhom,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (monHoc != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          monHoc.tenMonHoc,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Info section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Sĩ số: ${nhomHocPhan.soSV}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${nhomHocPhan.hocKy} - ${nhomHocPhan.namHoc}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // Hiển thị chi tiết nhóm học phần
  void _showNhomHocPhanDetail(NhomHocPhan nhomHocPhan, dynamic monHoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chi tiết nhóm học phần'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Tên nhóm:', nhomHocPhan.tenNhom),
                if (monHoc != null) ...[
                  _buildDetailRow('Môn học:', monHoc.tenMonHoc),
                  _buildDetailRow('Mã môn:', monHoc.maMonHoc),
                ],
                _buildDetailRow('Học kỳ:', nhomHocPhan.hocKy),
                _buildDetailRow('Năm học:', nhomHocPhan.namHoc),
                _buildDetailRow('Sĩ số:', nhomHocPhan.soSV.toString()),
                _buildDetailRow('Ngày tạo:', '${nhomHocPhan.ngayTao.day}/${nhomHocPhan.ngayTao.month}/${nhomHocPhan.ngayTao.year}'),
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
            width: 100,
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
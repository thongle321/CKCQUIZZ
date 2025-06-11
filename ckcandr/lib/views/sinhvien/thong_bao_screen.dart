import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/thong_bao_model.dart';
import 'package:ckcandr/providers/thong_bao_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';

class ThongBaoScreen extends ConsumerStatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  ConsumerState<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends ConsumerState<ThongBaoScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ThongBao> get _filteredThongBaoList {
    try {
      final thongBaoList = ref.watch(thongBaoListProvider);
      if (thongBaoList.isEmpty) return <ThongBao>[];

      final query = _searchController.text.toLowerCase();

      final filtered = thongBaoList.where((thongBao) {
        try {
          // Chỉ hiển thị thông báo đã được đăng
          if (!thongBao.isPublished) return false;

          // Lọc theo từ khóa tìm kiếm
          final searchMatches = query.isEmpty ||
              (thongBao.tieuDe.isNotEmpty && thongBao.tieuDe.toLowerCase().contains(query)) ||
              (thongBao.noiDung.isNotEmpty && thongBao.noiDung.toLowerCase().contains(query)) ||
              (thongBao.phamViMoTa.isNotEmpty && thongBao.phamViMoTa.toLowerCase().contains(query));

          return searchMatches;
        } catch (e) {
          debugPrint('Error filtering thongBao ${thongBao.id}: $e');
          return false;
        }
      }).toList();

      // Sắp xếp theo thời gian mới nhất
      try {
        filtered.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
      } catch (e) {
        debugPrint('Error sorting thongBao list: $e');
      }

      return filtered;
    } catch (e) {
      debugPrint('Error in _filteredThongBaoList: $e');
      return <ThongBao>[];
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  
  
  void _showThongBaoDetail(ThongBao thongBao) {
    final userList = ref.read(userListProvider);
    dynamic nguoiTao;
    try {
      if (thongBao.nguoiTaoId.isNotEmpty) {
        final matchingUsers = userList.where((user) => user.id == thongBao.nguoiTaoId);
        nguoiTao = matchingUsers.isNotEmpty ? matchingUsers.first : null;
      }
    } catch (e) {
      debugPrint('Error getting nguoiTao: $e');
      nguoiTao = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(thongBao.tieuDe),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thông tin người tạo
              if (nguoiTao != null) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Người tạo: ${nguoiTao.hoVaTen}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Phạm vi
              Row(
                children: [
                  Icon(Icons.group, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Phạm vi: ${thongBao.phamViMoTa}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Thời gian
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(thongBao.ngayTao)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nội dung
              const Text(
                'Nội dung:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                thongBao.noiDung,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
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
            
              ],
            ),
            const SizedBox(height: 20),
            
            // Danh sách thông báo
            Expanded(
              child: _filteredThongBaoList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có thông báo nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredThongBaoList.length,
                      itemBuilder: (context, index) {
                        final thongBao = _filteredThongBaoList[index];
                        final userList = ref.watch(userListProvider);
                        dynamic nguoiTao;
                        try {
                          if (thongBao.nguoiTaoId.isNotEmpty) {
                            final matchingUsers = userList.where((user) => user.id == thongBao.nguoiTaoId);
                            nguoiTao = matchingUsers.isNotEmpty ? matchingUsers.first : null;
                          }
                        } catch (e) {
                          debugPrint('Error getting nguoiTao for thongBao ${thongBao.id}: $e');
                          nguoiTao = null;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: InkWell(
                            onTap: () => _showThongBaoDetail(thongBao),
                            borderRadius: BorderRadius.circular(8),
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Nội dung (preview)
                                  Text(
                                    thongBao.noiDung,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  // Phạm vi và người tạo
                                  Row(
                                    children: [
                                      Icon(Icons.group_outlined, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          thongBao.phamViMoTa,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Thời gian và người tạo
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Thời gian
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('dd/MM/yyyy HH:mm').format(thongBao.ngayTao),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Người tạo
                                      if (nguoiTao != null)
                                        Row(
                                          children: [
                                            Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              nguoiTao.hoVaTen,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Thông tin tổng kết
            if (_filteredThongBaoList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng: ${_filteredThongBaoList.length} thông báo',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Có thể thêm các thống kê khác ở đây
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Nhấn vào thông báo để xem chi tiết',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
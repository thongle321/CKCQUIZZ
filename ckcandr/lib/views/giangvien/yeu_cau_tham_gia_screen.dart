import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/lop_hoc_model.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';

class GiangVienYeuCauThamGiaScreen extends ConsumerStatefulWidget {
  final LopHoc lopHoc;

  const GiangVienYeuCauThamGiaScreen({super.key, required this.lopHoc});

  @override
  ConsumerState<GiangVienYeuCauThamGiaScreen> createState() => _GiangVienYeuCauThamGiaScreenState();
}

class _GiangVienYeuCauThamGiaScreenState extends ConsumerState<GiangVienYeuCauThamGiaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danhSachYeuCau = ref.watch(yeuCauThamGiaLopProvider)
        .where((yeuCau) => yeuCau.lopHocId == widget.lopHoc.id)
        .toList();

    final yeuCauChoXuLy = danhSachYeuCau
        .where((yeuCau) => yeuCau.trangThai == TrangThaiYeuCau.choXuLy)
        .toList();
    final yeuCauChapNhan = danhSachYeuCau
        .where((yeuCau) => yeuCau.trangThai == TrangThaiYeuCau.chapNhan)
        .toList();
    final yeuCauTuChoi = danhSachYeuCau
        .where((yeuCau) => yeuCau.trangThai == TrangThaiYeuCau.tuChoi)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu tham gia'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Chờ xử lý (${yeuCauChoXuLy.length})'),
            Tab(text: 'Đã chấp nhận (${yeuCauChapNhan.length})'),
            Tab(text: 'Đã từ chối (${yeuCauTuChoi.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildYeuCauList(yeuCauChoXuLy, TrangThaiYeuCau.choXuLy),
          _buildYeuCauList(yeuCauChapNhan, TrangThaiYeuCau.chapNhan),
          _buildYeuCauList(yeuCauTuChoi, TrangThaiYeuCau.tuChoi),
        ],
      ),
    );
  }

  Widget _buildYeuCauList(List<YeuCauThamGiaLop> danhSachYeuCau, TrangThaiYeuCau trangThai) {
    if (danhSachYeuCau.isEmpty) {
      String message;
      switch (trangThai) {
        case TrangThaiYeuCau.choXuLy:
          message = 'Không có yêu cầu nào đang chờ xử lý';
          break;
        case TrangThaiYeuCau.chapNhan:
          message = 'Chưa có yêu cầu nào được chấp nhận';
          break;
        case TrangThaiYeuCau.tuChoi:
          message = 'Chưa có yêu cầu nào bị từ chối';
          break;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconByTrangThai(trangThai),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: danhSachYeuCau.length,
      itemBuilder: (context, index) {
        final yeuCau = danhSachYeuCau[index];
        return _buildYeuCauCard(yeuCau);
      },
    );
  }

  Widget _buildYeuCauCard(YeuCauThamGiaLop yeuCau) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(yeuCau.sinhVienTen[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yeuCau.sinhVienTen,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MSSV: ${yeuCau.sinhVienMSSV}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrangThaiChip(yeuCau.trangThai),
              ],
            ),
            const SizedBox(height: 12),
            if (yeuCau.lyDo.isNotEmpty) ...[
              const Text(
                'Lý do tham gia:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(yeuCau.lyDo),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Ngày yêu cầu: ${_formatDate(yeuCau.ngayYeuCau)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (yeuCau.trangThai == TrangThaiYeuCau.choXuLy) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                    onPressed: () => _showConfirmDialog(
                      yeuCau,
                      TrangThaiYeuCau.tuChoi,
                      'Từ chối yêu cầu',
                      'Bạn có chắc chắn muốn từ chối yêu cầu của ${yeuCau.sinhVienTen}?',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Chấp nhận'),
                    onPressed: () => _showConfirmDialog(
                      yeuCau,
                      TrangThaiYeuCau.chapNhan,
                      'Chấp nhận yêu cầu',
                      'Bạn có chắc chắn muốn chấp nhận yêu cầu của ${yeuCau.sinhVienTen}?',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrangThaiChip(TrangThaiYeuCau trangThai) {
    Color color;
    String text;
    switch (trangThai) {
      case TrangThaiYeuCau.choXuLy:
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case TrangThaiYeuCau.chapNhan:
        color = Colors.green;
        text = 'Chấp nhận';
        break;
      case TrangThaiYeuCau.tuChoi:
        color = Colors.red;
        text = 'Từ chối';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  IconData _getIconByTrangThai(TrangThaiYeuCau trangThai) {
    switch (trangThai) {
      case TrangThaiYeuCau.choXuLy:
        return Icons.pending_actions;
      case TrangThaiYeuCau.chapNhan:
        return Icons.check_circle;
      case TrangThaiYeuCau.tuChoi:
        return Icons.cancel;
    }
  }

  void _showConfirmDialog(
    YeuCauThamGiaLop yeuCau,
    TrangThaiYeuCau trangThai,
    String title,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _handleYeuCau(yeuCau, trangThai);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: trangThai == TrangThaiYeuCau.tuChoi ? Colors.red : Colors.blue,
            ),
            child: Text(trangThai == TrangThaiYeuCau.tuChoi ? 'Từ chối' : 'Chấp nhận'),
          ),
        ],
      ),
    );
  }

  void _handleYeuCau(YeuCauThamGiaLop yeuCau, TrangThaiYeuCau trangThai) {
    // Cập nhật trạng thái yêu cầu
    ref.read(yeuCauThamGiaLopProvider.notifier)
        .updateTrangThaiYeuCau(yeuCau.id, trangThai);

    // Nếu chấp nhận, thêm sinh viên vào lớp
    if (trangThai == TrangThaiYeuCau.chapNhan) {
      ref.read(lopHocListProvider.notifier)
          .addSinhVienToLop(yeuCau.lopHocId, yeuCau.sinhVienId);
    }

    final message = trangThai == TrangThaiYeuCau.chapNhan
        ? 'Đã chấp nhận yêu cầu của ${yeuCau.sinhVienTen}'
        : 'Đã từ chối yêu cầu của ${yeuCau.sinhVienTen}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

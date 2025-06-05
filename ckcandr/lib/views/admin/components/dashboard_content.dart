import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/cau_hoi_provider.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/cau_hoi_model.dart';
import 'package:intl/intl.dart';

class DashboardContent extends ConsumerWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userList = ref.watch(userListProvider);
    final monHocList = ref.watch(monHocListProvider);
    final cauHoiList = ref.watch(cauHoiListProvider);
    final hoatDongList = ref.watch(hoatDongGanDayListProvider);
    
    // Lấy số lượng người dùng theo từng loại
    final adminCount = userList.where((user) => user.quyen == UserRole.admin).length;
    final giangVienCount = userList.where((user) => user.quyen == UserRole.giangVien).length;
    final sinhVienCount = userList.where((user) => user.quyen == UserRole.sinhVien).length;
    
    // Kiểm tra kích thước màn hình để hiển thị responsive
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan hệ thống',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Các card thống kê
            GridView.count(
              crossAxisCount: isSmallScreen ? 1 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  context,
                  title: 'Tổng người dùng',
                  value: userList.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  title: 'Giảng viên',
                  value: giangVienCount.toString(),
                  icon: Icons.school,
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  title: 'Sinh viên',
                  value: sinhVienCount.toString(),
                  icon: Icons.person,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context,
                  title: 'Môn học',
                  value: monHocList.length.toString(),
                  icon: Icons.book,
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Phần nội dung chính - Dashboard
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần bên trái - Hoạt động gần đây
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hoạt động gần đây',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  // Refresh hoạt động
                                },
                                tooltip: 'Làm mới',
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: hoatDongList.length > 10 ? 10 : hoatDongList.length,
                            itemBuilder: (context, index) {
                              final hoatDong = hoatDongList[index];
                              return _buildHoatDongItem(context, hoatDong);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                if (!isSmallScreen) const SizedBox(width: 16),
                
                // Phần bên phải - Thống kê nhanh và info
                if (!isSmallScreen)
                  Expanded(
                    child: Column(
                      children: [
                        // Thống kê câu hỏi
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thống kê câu hỏi',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                _buildStatItem(
                                  context,
                                  title: 'Tổng số câu hỏi',
                                  value: cauHoiList.length.toString(),
                                ),
                                const SizedBox(height: 8),
                                _buildStatItem(
                                  context,
                                  title: 'Dễ',
                                  value: cauHoiList.where((q) => q.doKho == DoKho.de).length.toString(),
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 8),
                                _buildStatItem(
                                  context,
                                  title: 'Trung bình',
                                  value: cauHoiList.where((q) => q.doKho == DoKho.trungBinh).length.toString(),
                                  color: Colors.amber,
                                ),
                                const SizedBox(height: 8),
                                _buildStatItem(
                                  context,
                                  title: 'Khó',
                                  value: cauHoiList.where((q) => q.doKho == DoKho.kho).length.toString(),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Quick Links
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Truy cập nhanh',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                _buildQuickLinkButton(
                                  context,
                                  title: 'Thêm người dùng mới',
                                  icon: Icons.person_add,
                                  onPressed: () {
                                    // TODO: Navigate to add user screen
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildQuickLinkButton(
                                  context,
                                  title: 'Thêm môn học',
                                  icon: Icons.add_box,
                                  onPressed: () {
                                    // TODO: Navigate to add subject screen
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildQuickLinkButton(
                                  context,
                                  title: 'Cài đặt hệ thống',
                                  icon: Icons.settings,
                                  onPressed: () {
                                    // TODO: Navigate to settings screen
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            if (isSmallScreen) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Truy cập nhanh',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildQuickLinkButton(
                              context,
                              title: 'Thêm người dùng',
                              icon: Icons.person_add,
                              onPressed: () {
                                // TODO: Navigate to add user screen
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickLinkButton(
                              context,
                              title: 'Thêm môn học',
                              icon: Icons.add_box,
                              onPressed: () {
                                // TODO: Navigate to add subject screen
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget cho các card thống kê
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho các item hoạt động
  Widget _buildHoatDongItem(BuildContext context, HoatDongGanDay hoatDong) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _getColorForHoatDong(hoatDong.loaiHoatDong).withOpacity(0.2),
            child: Icon(
              hoatDong.icon ?? Icons.event_note,
              color: _getColorForHoatDong(hoatDong.loaiHoatDong),
              size: 20,
            ),
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hoatDong.noiDung,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(hoatDong.thoiGian),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho các dòng thống kê
  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Widget cho nút truy cập nhanh
  Widget _buildQuickLinkButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  // Lấy màu cho loại hoạt động
  Color _getColorForHoatDong(LoaiHoatDong loai) {
    switch (loai) {
      case LoaiHoatDong.MON_HOC:
        return Colors.green;
      case LoaiHoatDong.CAU_HOI:
        return Colors.blue;
      case LoaiHoatDong.DE_THI:
        return Colors.purple;
      case LoaiHoatDong.DANG_NHAP:
        return Colors.orange;
      case LoaiHoatDong.KHAC:
      default:
        return Colors.grey;
    }
  }
} 
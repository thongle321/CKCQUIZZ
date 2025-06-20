import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/views/giangvien/components/sidebar.dart';
import 'package:ckcandr/views/giangvien/components/custom_app_bar.dart';
import 'package:ckcandr/views/giangvien/components/dashboard_content.dart';
import 'package:ckcandr/views/giangvien/lop_hoc_screen.dart';
import 'package:ckcandr/views/giangvien/chuong_muc_screen.dart';
import 'package:ckcandr/views/giangvien/cau_hoi_screen.dart';

import 'package:ckcandr/views/giangvien/de_kiem_tra_screen.dart';
import 'package:ckcandr/providers/theme_provider.dart';

// Provider cho tab đang được chọn
// final selectedTabProvider = StateProvider<int>((ref) => 0); // Not currently used, local state _selectedIndex is used

// Global key cho Scaffold để có thể mở drawer từ bất kỳ đâu
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// Provider to manage sidebar visibility on larger screens
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

class GiangVienDashboardScreen extends ConsumerStatefulWidget {
  const GiangVienDashboardScreen({super.key});

  @override
  ConsumerState<GiangVienDashboardScreen> createState() => _GiangVienDashboardScreenState();
}

class _GiangVienDashboardScreenState extends ConsumerState<GiangVienDashboardScreen> {
  int _selectedIndex = 0;
  
  // Xử lý khi chọn mục trên sidebar
  void _handleItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Đóng drawer nếu đang mở
    if (isSmallScreen && scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }
  
  // Kiểm tra nếu là thiết bị nhỏ
  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final isSidebarVisible = ref.watch(sidebarVisibleProvider);
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[100];
    final contentBackgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    
    if (isSmallScreen) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(title: _getScreenTitle(_selectedIndex)),
        drawer: SafeArea(
          child: Drawer(
            elevation: 2.0,
            child: GiangVienSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleItemSelected,
            ),
          ),
        ),
        body: _buildContent(),
        // Thêm drawer scrim listener để đóng drawer khi chạm vào vùng trống
        drawerScrimColor: Colors.black54,
        drawerEdgeDragWidth: 60, // Tăng khu vực vuốt để mở drawer
      );
    }
    
    // Đối với màn hình lớn hơn, hiển thị sidebar bên cạnh
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: _getScreenTitle(_selectedIndex)),
      body: Row(
        children: [
          // Sidebar - chỉ hiển thị khi isSidebarVisible = true
          if (isSidebarVisible)
            GiangVienSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleItemSelected,
            ),
          // Main content area
          Expanded(
            child: Container(
              color: contentBackgroundColor,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Tổng quan';
      case 1:
        return 'Lớp học';
      case 2:
        return 'Chương mục';
      case 3:
        return 'Câu hỏi';
      case 4:
        return 'Đề kiểm tra';
      case 5:
        return 'Hồ sơ';
      case 6:
        return 'Đổi mật khẩu';
      default:
        return 'Tổng quan';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const TeacherLopHocScreen();
      case 2:
        return const ChuongMucScreen();
      case 3:
        return const CauHoiScreen();
      case 4:
        return const DeKiemTraScreen();
      case 5:
        return _buildProfileScreen();
      case 6:
        return _buildChangePasswordScreen();
      default:
        return const DashboardContent();
    }
  }

  Widget _buildProfileScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Hồ sơ cá nhân',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Chức năng đang được phát triển',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Đổi mật khẩu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Chức năng đang được phát triển',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 
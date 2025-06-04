import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/views/giangvien/components/sidebar.dart';
import 'package:ckcandr/views/giangvien/components/custom_app_bar.dart';
import 'package:ckcandr/views/giangvien/components/dashboard_content.dart';
import 'package:ckcandr/views/giangvien/mon_hoc_screen.dart';
import 'package:ckcandr/views/giangvien/nhom_hocphan_screen.dart';
import 'package:go_router/go_router.dart';

// Provider cho tab đang được chọn
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Global key cho Scaffold để có thể mở drawer từ bất kỳ đâu
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
        return 'Dashboard';
      case 1:
        return 'Nhóm học phần';
      case 2:
        return 'Câu hỏi';
      case 3:
        return 'Môn học';
      case 4:
        return 'Đề kiểm tra';
      case 5:
        return 'Thông báo';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const NhomHocPhanScreen();
      case 2:
        return const Center(child: Text('Câu hỏi - Đang phát triển'));
      case 3:
        return const MonHocScreen();
      case 4:
        return const Center(child: Text('Đề kiểm tra - Đang phát triển'));
      case 5:
        return const Center(child: Text('Thông báo - Đang phát triển'));
      default:
        return const DashboardContent();
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/views/sinhvien/components/sidebar.dart';
import 'package:ckcandr/views/sinhvien/components/custom_app_bar.dart';
import 'package:ckcandr/views/sinhvien/components/dashboard_content.dart';
import 'package:ckcandr/views/sinhvien/nhom_hoc_phan_screen.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_mon_hoc_screen.dart';
import 'package:ckcandr/views/sinhvien/danh_muc_bai_kiem_tra_screen.dart';

import 'package:ckcandr/views/sinhvien/lop_hoc_screen.dart';

// Global key cho Scaffold để có thể mở drawer từ bất kỳ đâu
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// Provider để quản lý hiển thị sidebar trên màn hình lớn
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

class SinhVienDashboardScreen extends ConsumerStatefulWidget {
  final int? initialTab;
  const SinhVienDashboardScreen({super.key, this.initialTab});

  @override
  ConsumerState<SinhVienDashboardScreen> createState() => _SinhVienDashboardScreenState();
}

class _SinhVienDashboardScreenState extends ConsumerState<SinhVienDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set initial tab if provided
    if (widget.initialTab != null) {
      _selectedIndex = widget.initialTab!;
      debugPrint('📱 SinhVienDashboard initialized with tab: ${widget.initialTab} -> $_selectedIndex');
    } else {
      debugPrint('📱 SinhVienDashboard initialized with default tab: $_selectedIndex');
    }
  }

  // Xử lý khi chọn mục trên sidebar
  void _handleItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Đóng drawer nếu đang mở trên thiết bị nhỏ
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

    // Layout cho thiết bị nhỏ (có drawer)
    if (isSmallScreen) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(title: _getScreenTitle(_selectedIndex)),
        drawer: SafeArea(
          child: Drawer(
            elevation: 2.0,
            child: SinhVienSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleItemSelected,
            ),
          ),
        ),
        body: SafeArea(
          child: _buildContent(),
        ),
        drawerScrimColor: Colors.black54,
        drawerEdgeDragWidth: 60, // Tăng khu vực vuốt để mở drawer
      );
    }

    // Layout cho thiết bị lớn (có sidebar bên cạnh)
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: _getScreenTitle(_selectedIndex)),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar - chỉ hiển thị khi isSidebarVisible = true
            if (isSidebarVisible)
              SinhVienSidebar(
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
        return 'Nhóm học phần';
      case 3:
        return 'Môn học';
      case 4:
        return 'Bài kiểm tra';
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
        return const SinhVienLopHocScreen();
      case 2:
        return const SinhVienNhomHocPhanScreen();
      case 3:
        return const DanhMucMonHocScreen();
      case 4:
        return const DanhMucBaiKiemTraScreen();
      case 5:
        // Điều hướng đến màn hình profile thực sự
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/profile');
        });
        return const Center(child: CircularProgressIndicator());
      case 6:
        return _buildChangePasswordScreen();
      default:
        return const DashboardContent();
    }
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
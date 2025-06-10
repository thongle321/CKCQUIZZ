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
import 'package:ckcandr/views/sinhvien/thong_bao_screen.dart';
import 'package:ckcandr/core/utils/responsive_helper.dart';

// Global key cho Scaffold để có thể mở drawer từ bất kỳ đâu
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// Provider để quản lý hiển thị sidebar trên màn hình lớn
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

class SinhVienDashboardScreen extends ConsumerStatefulWidget {
  const SinhVienDashboardScreen({super.key});

  @override
  ConsumerState<SinhVienDashboardScreen> createState() => _SinhVienDashboardScreenState();
}

class _SinhVienDashboardScreenState extends ConsumerState<SinhVienDashboardScreen> {

  // Xử lý khi chọn mục trên sidebar
  void _handleItemSelected(int index) {
    // Đóng drawer nếu đang mở trên thiết bị nhỏ
    if (isSmallScreen && scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }

    // Navigate to the corresponding route
    switch (index) {
      case 0:
        GoRouter.of(context).go('/sinhvien/dashboard');
        break;
      case 1:
        GoRouter.of(context).go('/sinhvien/nhom-hoc-phan');
        break;
      case 2:
        GoRouter.of(context).go('/sinhvien/danh-muc-mon-hoc');
        break;
      case 3:
        GoRouter.of(context).go('/sinhvien/danh-muc-bai-kiem-tra');
        break;
      case 4:
        GoRouter.of(context).go('/sinhvien/thong-bao');
        break;
    }
  }

  // Kiểm tra nếu là thiết bị nhỏ
  bool get isSmallScreen => ResponsiveHelper.shouldUseDrawer(context);

  // Xác định selectedIndex dựa trên URL hiện tại
  int get _selectedIndex {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.contains('/nhom-hoc-phan')) return 1;
    if (location.contains('/danh-muc-mon-hoc')) return 2;
    if (location.contains('/danh-muc-bai-kiem-tra')) return 3;
    if (location.contains('/thong-bao')) return 4;
    return 0; // dashboard
  }

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
        return 'Nhóm học phần';
      case 2:
        return 'Môn học';
      case 3:
        return 'Bài kiểm tra';
      case 4:
        return 'Thông báo';
      default:
        return 'Tổng quan';
    }
  }

  Widget _buildContent() {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.contains('/nhom-hoc-phan')) {
      return const NhomHocPhanScreen();
    } else if (location.contains('/danh-muc-mon-hoc')) {
      return const DanhMucMonHocScreen();
    } else if (location.contains('/danh-muc-bai-kiem-tra')) {
      return const DanhMucBaiKiemTraScreen();
    } else if (location.contains('/thong-bao')) {
      return const ThongBaoScreen();
    } else {
      return const DashboardContent();
    }
  }
}
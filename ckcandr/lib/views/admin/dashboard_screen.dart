import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/views/admin/components/sidebar.dart';
import 'package:ckcandr/views/admin/components/custom_app_bar.dart';
import 'package:ckcandr/views/admin/components/dashboard_content.dart';
import 'package:ckcandr/views/admin/mon_hoc_screen.dart';
import 'package:ckcandr/views/admin/user_screen.dart';

// Global key cho Scaffold để có thể mở drawer từ bất kỳ đâu
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// Provider để quản lý hiển thị sidebar trên màn hình lớn
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;
  
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
            child: AdminSidebar(
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
              AdminSidebar(
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
        return 'Người dùng';
      case 2: 
        return 'Môn học';
      default:
        return 'Tổng quan';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const UserScreen();
      case 2:
        return const MonHocScreen();
      default:
        return const DashboardContent();
    }
  }
} 
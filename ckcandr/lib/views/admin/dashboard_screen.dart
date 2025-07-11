import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/views/admin/components/sidebar.dart';
import 'package:ckcandr/views/admin/components/custom_app_bar.dart';
import 'package:ckcandr/views/admin/components/dashboard_content.dart';
import 'package:ckcandr/views/admin/test_subjects_screen.dart';
import 'package:ckcandr/views/admin/user_screen.dart';
import 'package:ckcandr/views/admin/api_user_screen.dart';
import 'package:ckcandr/views/admin/lop_hoc_screen.dart';
import 'package:ckcandr/views/admin/mon_hoc_screen.dart';
import 'package:ckcandr/views/admin/phan_cong_screen.dart';
import 'package:ckcandr/views/admin/thong_bao_screen.dart';
import 'package:ckcandr/views/admin/nhom_quyen_screen.dart';
import 'package:ckcandr/screens/admin/role_management_screen.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/views/sinhvien/settings_screen.dart';
import 'package:ckcandr/views/shared/ai_chat_screen.dart';
import 'package:ckcandr/views/shared/ai_settings_screen.dart';

// Global key cho Scaffold được chuyển thành instance variable để tránh conflict

// Provider để quản lý hiển thị sidebar trên màn hình lớn
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final int? initialTab;

  const AdminDashboardScreen({super.key, this.initialTab});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Set initial tab if provided
    if (widget.initialTab != null) {
      _selectedIndex = widget.initialTab!;
    }
  }

  // Xử lý khi chọn mục trên sidebar
  void _handleItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Đóng drawer nếu đang mở trên thiết bị nhỏ
    if (isSmallScreen) {
      try {
        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Ignore if scaffold not found
      }
    }
  }

  // Xử lý nút back
  void _handleBackButton() {
    // Nếu đang ở dashboard (index 0), thoát app
    if (_selectedIndex == 0) {
      // Có thể hiển thị dialog xác nhận thoát hoặc thoát trực tiếp
      Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
    } else {
      // Quay về dashboard
      setState(() {
        _selectedIndex = 0;
      });
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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBackButton();
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: backgroundColor,
          appBar: CustomAppBar(
            title: _getScreenTitle(_selectedIndex),
            scaffoldKey: _scaffoldKey,
          ),
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
        ),
      );
    }
    
    // Layout cho thiết bị lớn (có sidebar bên cạnh)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackButton();
        }
      },
      child: Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: _getScreenTitle(_selectedIndex),
      ),
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
      case 3:
        return 'Lớp học';
      case 4:
        return 'Phân công';
      case 5:
        return 'Thông báo';
      case 6:
        return 'Nhóm quyền';
      case 7:
        return 'AI Assistant';
      case 8:
        return 'Cài đặt';
      default:
        return 'Tổng quan';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const ApiUserScreen();
      case 2:
        return const MonHocScreen();
      case 3:
        return const AdminLopHocScreen();
      case 4:
        return const PhanCongScreen();
      case 5:
        return const ThongBaoScreen();
      case 6:
        return const RoleManagementScreen();
      case 7:
        return const AiChatScreen();
      case 8:
        return _buildSettingsScreen();
      default:
        return const DashboardContent();
    }
  }

  Widget _buildSettingsScreen() {
    return const StudentSettingsScreen();
  }
} 
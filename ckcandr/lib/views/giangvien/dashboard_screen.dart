import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/services/auth_service.dart';
import 'package:ckcandr/views/giangvien/components/sidebar.dart';
import 'package:ckcandr/views/giangvien/components/custom_app_bar.dart';
import 'package:ckcandr/views/giangvien/components/dashboard_content.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
import 'package:ckcandr/views/giangvien/lop_hoc_screen.dart';
import 'package:ckcandr/views/giangvien/chuong_muc_screen.dart';
import 'package:ckcandr/views/giangvien/cau_hoi_screen.dart';

import 'package:ckcandr/views/giangvien/de_kiem_tra_screen.dart';

import 'package:ckcandr/views/giangvien/thong_bao_teacher_screen.dart';
import 'package:ckcandr/views/sinhvien/settings_screen.dart';
import 'package:ckcandr/views/shared/ai_chat_screen.dart';
import 'package:ckcandr/providers/theme_provider.dart';

// Provider cho tab đang được chọn
// final selectedTabProvider = StateProvider<int>((ref) => 0); // Not currently used, local state _selectedIndex is used

// Global key cho Scaffold được chuyển thành instance variable để tránh conflict

// Provider to manage sidebar visibility on larger screens
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

// Provider để trigger thêm câu hỏi từ FloatingActionButton
final addQuestionTriggerProvider = StateProvider<int>((ref) => 0);

class GiangVienDashboardScreen extends ConsumerStatefulWidget {
  const GiangVienDashboardScreen({super.key});

  @override
  ConsumerState<GiangVienDashboardScreen> createState() => _GiangVienDashboardScreenState();
}

class _GiangVienDashboardScreenState extends ConsumerState<GiangVienDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Không sử dụng GlobalKey để tránh conflict - sử dụng Scaffold.of(context) thay thế

  // Xử lý khi chọn mục trên sidebar
  void _handleItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    debugPrint('🔧 _handleItemSelected: index=$index, isSmallScreen=$isSmallScreen, screenWidth=${MediaQuery.of(context).size.width}');

    // Đóng drawer nếu đang mở trên mobile - sử dụng GlobalKey
    if (isSmallScreen) {
      debugPrint('📱 Mobile: Trying to close drawer');
      try {
        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
          _scaffoldKey.currentState?.closeDrawer();
          debugPrint('✅ Mobile: Drawer closed');
        } else {
          debugPrint('❌ Mobile: Drawer not open');
        }
      } catch (e) {
        debugPrint('❌ Mobile: Error closing drawer: $e');
      }
    } else {
      debugPrint('🖥️ Desktop: Hiding sidebar');
      // Thu nhỏ sidebar trên desktop sau khi chọn menu item
      ref.read(sidebarVisibleProvider.notifier).state = false;
      debugPrint('✅ Desktop: Sidebar hidden');
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

  /// Build FloatingActionButton cho màn hình câu hỏi
  Widget? _buildFloatingActionButton() {
    // Chỉ hiển thị FAB khi đang ở tab câu hỏi (index 3)
    if (_selectedIndex != 3) return null;

    return FloatingActionButton(
      onPressed: () {
        // Gọi method thêm câu hỏi từ CauHoiScreen
        _showAddQuestionDialog();
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Hiển thị dialog thêm câu hỏi
  void _showAddQuestionDialog() {
    // Sử dụng provider để trigger thêm câu hỏi
    // Tạo một provider để giao tiếp với CauHoiScreen
    ref.read(addQuestionTriggerProvider.notifier).state = DateTime.now().millisecondsSinceEpoch;
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
          currentScreenKey: _getCurrentScreenKey(_selectedIndex),
        ),
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
        floatingActionButton: _buildFloatingActionButton(),
        // Thêm drawer scrim listener để đóng drawer khi chạm vào vùng trống
        drawerScrimColor: Colors.black54,
        drawerEdgeDragWidth: 60, // Tăng khu vực vuốt để mở drawer
        ),
      );
    }
    
    // Đối với màn hình lớn hơn, hiển thị sidebar bên cạnh
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
        currentScreenKey: _getCurrentScreenKey(_selectedIndex),
      ),
      body: Row(
        children: [
          // Sidebar - chỉ hiển thị khi isSidebarVisible = true
          if (isSidebarVisible)
            GiangVienSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleItemSelected,
            ),
          // Main content area với GestureDetector để đóng sidebar khi click
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Đóng sidebar khi click vào main content area (chỉ khi sidebar đang mở)
                if (isSidebarVisible) {
                  ref.read(sidebarVisibleProvider.notifier).state = false;
                }
              },
              child: Container(
                color: contentBackgroundColor,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
        return 'Thông báo';
      case 6:
        return 'AI Assistant';
      case 7:
        return 'Cài đặt';
      default:
        return 'Tổng quan';
    }
  }

  /// Lấy auto-refresh key cho màn hình hiện tại
  String? _getCurrentScreenKey(int index) {
    switch (index) {
      case 3: // Câu hỏi
        return AutoRefreshKeys.teacherQuestions;
      case 4: // Đề kiểm tra
        return AutoRefreshKeys.teacherExams;
      default:
        return null; // Không auto-refresh cho các màn hình khác
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
        return const ThongBaoTeacherScreen();
      case 6:
        return const AiChatScreen();
      case 7:
        return _buildSettingsScreen();
      default:
        return const DashboardContent();
    }
  }



  Widget _buildSettingsScreen() {
    return const StudentSettingsScreen();
  }
} 
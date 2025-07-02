import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/theme_provider.dart';
import 'package:ckcandr/views/sinhvien/components/sidebar.dart';
import 'package:ckcandr/views/sinhvien/components/custom_app_bar.dart';
import 'package:ckcandr/views/sinhvien/components/dashboard_content.dart';
import 'package:ckcandr/views/sinhvien/class_list_screen.dart';
import 'package:ckcandr/views/sinhvien/class_exams_screen.dart';
import 'package:ckcandr/views/sinhvien/student_notifications_screen.dart';
import 'package:ckcandr/views/sinhvien/settings_screen.dart';

import 'package:ckcandr/services/exam_reminder_service.dart';
import 'package:ckcandr/services/api_service.dart';
import 'package:ckcandr/services/realtime_notification_service.dart';


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
  ExamReminderService? _examReminderService;
  RealtimeNotificationService? _realtimeNotificationService;

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

    // Khởi tạo services (loại bỏ dialog tự động)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeExamReminder();
      _initializeRealtimeNotifications();
    });
  }

  @override
  void dispose() {
    _examReminderService?.stopExamReminders();
    _realtimeNotificationService?.dispose();
    super.dispose();
  }

  /// Khởi tạo exam reminder service
  Future<void> _initializeExamReminder() async {
    try {
      _examReminderService = ref.read(examReminderServiceProvider);

      // Lấy danh sách đề thi và bắt đầu theo dõi
      final apiService = ref.read(apiServiceProvider);
      final exams = await apiService.getAllExamsForStudent();

      _examReminderService?.updateTrackedExams(exams);
      _examReminderService?.startExamReminders();

      debugPrint('📢 Exam reminder service initialized with ${exams.length} exams');
    } catch (e) {
      debugPrint('Failed to initialize exam reminder service: $e');
    }
  }

  /// Khởi tạo real-time notification service
  Future<void> _initializeRealtimeNotifications() async {
    try {
      _realtimeNotificationService = ref.read(realtimeNotificationServiceProvider);

      // Đăng ký callback để hiển thị popup notification
      _realtimeNotificationService?.setNotificationCallback((notification) {
        if (mounted) {
          _realtimeNotificationService?.showNotificationPopup(context, notification);
        }
      });

      // Khởi tạo service
      _realtimeNotificationService?.initialize();

      debugPrint('🔔 Real-time notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize real-time notification service: $e');
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
        return 'Danh sách lớp';
      case 2:
        return 'Bài kiểm tra';
      case 3:
        return 'Thông báo';
      case 4:
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
        return const StudentClassListScreen();
      case 2:
        return const StudentClassExamsScreen();
      case 3:
        return const StudentNotificationsScreen();
      case 4:
        return _buildSettingsScreen();
      default:
        return const DashboardContent();
    }
  }



  Widget _buildSettingsScreen() {
    return const StudentSettingsScreen();
  }
}
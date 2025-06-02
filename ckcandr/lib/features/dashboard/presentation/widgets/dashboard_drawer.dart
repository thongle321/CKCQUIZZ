import 'package:ckcandr/config/routes/router_provider.dart';
import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardDrawer extends StatelessWidget {
  final bool isPermanent;

  const DashboardDrawer({
    super.key,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GoRouter router = GoRouter.of(context);

    // Hàm kiểm tra nếu route hiện tại là route của mục drawer
    bool _isCurrentRoute(String routeName) {
      // Sử dụng routerDelegate để truy cập thông tin route hiện tại một cách an toàn hơn
      final String currentPath = router.routerDelegate.currentConfiguration.uri.toString();
      
      // Đối với các route có tham số động, chỉ so sánh phần đầu của path
      if (routeName == AppRoutes.chiTietLopHocPhan) {
        return currentPath.contains('/lop_hoc_phan/chi_tiet_lop_hoc_phan');
      }
      
      // Với các route thông thường, so sánh path
      String targetPath;
      try {
        targetPath = router.namedLocation(routeName);
      } catch (e) {
        // Nếu route yêu cầu tham số mà không được cung cấp, xử lý đặc biệt
        return false;
      }
      return currentPath == targetPath;
    }

    Widget drawerContent = Column(
      children: <Widget>[
        Container(
          height: 120,
          color: isPermanent ? AppTheme.backgroundColor : AppTheme.primaryLightColor,
          alignment: Alignment.center,
          child: Text(
            'CKC QUIZ',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildDrawerItem(
                icon: Icons.grid_view_outlined,
                text: 'Tổng quan',
                context: context,
                route: AppRoutes.dashboard,
                isSelected: _isCurrentRoute(AppRoutes.dashboard),
                onTap: () {
                  router.goNamed(AppRoutes.dashboard);
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'QUẢN LÝ',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.folder_copy_outlined,
                text: 'Nhóm học phần',
                context: context,
                route: AppRoutes.lopHocPhan,
                isSelected: _isCurrentRoute(AppRoutes.lopHocPhan) ||
                    _isCurrentRoute(AppRoutes.themLopHocPhan) ||
                    _isCurrentRoute(AppRoutes.chiTietLopHocPhan),
                onTap: () {
                  router.goNamed(AppRoutes.lopHocPhan);
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.question_answer_outlined,
                text: 'Câu hỏi',
                context: context,
                route: AppRoutes.cauHoi,
                isSelected: _isCurrentRoute(AppRoutes.cauHoi),
                onTap: () {
                  router.goNamed(AppRoutes.cauHoi);
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.people_outline,
                text: 'Người dùng',
                context: context,
                route: AppRoutes.nguoiDung,
                isSelected: _isCurrentRoute(AppRoutes.nguoiDung),
                onTap: () {
                  router.goNamed(AppRoutes.nguoiDung);
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.assignment_outlined,
                text: 'Đề thi',
                context: context,
                route: AppRoutes.deThi,
                isSelected: _isCurrentRoute(AppRoutes.deThi),
                onTap: () {
                  router.goNamed(AppRoutes.deThi);
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.notifications_active_outlined,
                text: 'Thông báo',
                context: context,
                route: AppRoutes.thongBao,
                isSelected: _isCurrentRoute(AppRoutes.thongBao),
                onTap: () {
                  router.goNamed(AppRoutes.thongBao);
                  if (!isPermanent && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );

    if (isPermanent) {
      return Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: drawerContent,
      );
    }
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 1,
      child: drawerContent,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required BuildContext context,
    required VoidCallback onTap,
    required String route,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        size: 22,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tileColor: isSelected ? AppTheme.primaryLightColor : null,
      selected: isSelected,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minLeadingWidth: 20,
    );
  }
}
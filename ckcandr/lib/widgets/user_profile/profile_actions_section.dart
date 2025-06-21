import 'package:flutter/material.dart';

/// Widget hiển thị các hành động trong profile
class ProfileActionsSection extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onChangePassword;
  final VoidCallback? onSettings;
  final VoidCallback? onHelp;
  final VoidCallback? onAbout;

  const ProfileActionsSection({
    super.key,
    this.onLogout,
    this.onChangePassword,
    this.onSettings,
    this.onHelp,
    this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cài đặt & Hành động',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Danh sách hành động
            Column(
              children: [
                // Đổi mật khẩu
                if (onChangePassword != null)
                  _buildActionTile(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Thay đổi mật khẩu đăng nhập',
                    onTap: onChangePassword!,
                    iconColor: Colors.blue,
                  ),
                
                // Cài đặt
                if (onSettings != null) ...[
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt ứng dụng',
                    subtitle: 'Tùy chỉnh giao diện và thông báo',
                    onTap: onSettings!,
                    iconColor: Colors.grey[700]!,
                  ),
                ],
                
                // Trợ giúp
                if (onHelp != null) ...[
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Trợ giúp',
                    subtitle: 'Hướng dẫn sử dụng và FAQ',
                    onTap: onHelp!,
                    iconColor: Colors.green,
                  ),
                ],
                
                // Về ứng dụng
                if (onAbout != null) ...[
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Về ứng dụng',
                    subtitle: 'Thông tin phiên bản và nhà phát triển',
                    onTap: onAbout!,
                    iconColor: Colors.purple,
                  ),
                ],
                
                // Đăng xuất
                if (onLogout != null) ...[
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    subtitle: 'Thoát khỏi tài khoản hiện tại',
                    onTap: onLogout!,
                    iconColor: Colors.red,
                    isDestructive: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng tile hành động
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}

/// Widget nút hành động nhanh
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Widget grid các hành động nhanh
class QuickActionsGrid extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionsGrid({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionButton(
          icon: action.icon,
          label: action.label,
          onPressed: action.onPressed,
          backgroundColor: action.backgroundColor,
          foregroundColor: action.foregroundColor,
        );
      },
    );
  }
}

/// Model cho hành động nhanh
class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// Widget hiển thị thông tin phiên bản
class AppVersionInfo extends StatelessWidget {
  final String version;
  final String buildNumber;

  const AppVersionInfo({
    super.key,
    required this.version,
    required this.buildNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'CKC Quiz App',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Phiên bản $version (Build $buildNumber)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Cao Thắng Technical College',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

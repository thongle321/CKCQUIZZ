import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget wrapper để xử lý back button toàn cục cho tất cả role
/// Ưu tiên sử dụng navigation stack, fallback về dashboard tương ứng
class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Chặn back button mặc định
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        _handleBackButton(context);
      },
      child: child,
    );
  }

  void _handleBackButton(BuildContext context) {
    // Ưu tiên sử dụng navigation stack
    if (context.canPop()) {
      debugPrint('🔙 BackButtonHandler: Using context.pop()');
      context.pop();
    } else if (fallbackRoute != null) {
      debugPrint('🔙 BackButtonHandler: Using fallback route: $fallbackRoute');
      context.go(fallbackRoute!);
    } else {
      // Fallback mặc định dựa trên route hiện tại
      final currentRoute = GoRouterState.of(context).uri.path;
      final fallback = _determineFallbackRoute(currentRoute);
      debugPrint('🔙 BackButtonHandler: Using determined fallback: $fallback');
      context.go(fallback);
    }
  }

  String _determineFallbackRoute(String currentRoute) {
    if (currentRoute.startsWith('/admin')) {
      return '/admin';
    } else if (currentRoute.startsWith('/giangvien')) {
      return '/giangvien';
    } else if (currentRoute.startsWith('/sinhvien')) {
      return '/sinhvien';
    } else {
      return '/'; // Default fallback
    }
  }
}

/// Extension để tạo AppBar với back button được xử lý đúng cách
extension AppBarBackButton on AppBar {
  static AppBar withBackButton({
    required String title,
    required Color backgroundColor,
    Color? foregroundColor,
    String? fallbackRoute,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    double? elevation,
  }) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 0,
      bottom: bottom,
      actions: actions,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              debugPrint('🔙 AppBar: Using context.pop()');
              context.pop();
            } else if (fallbackRoute != null) {
              debugPrint('🔙 AppBar: Using fallback route: $fallbackRoute');
              context.go(fallbackRoute);
            } else {
              // Fallback mặc định
              final currentRoute = GoRouterState.of(context).uri.path;
              String fallback;
              if (currentRoute.startsWith('/admin')) {
                fallback = '/admin';
              } else if (currentRoute.startsWith('/giangvien')) {
                fallback = '/giangvien';
              } else if (currentRoute.startsWith('/sinhvien')) {
                fallback = '/sinhvien';
              } else {
                fallback = '/';
              }
              debugPrint('🔙 AppBar: Using determined fallback: $fallback');
              context.go(fallback);
            }
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mixin để xử lý back button cho tất cả màn hình
mixin BackButtonMixin {
  /// Xử lý back button với fallback route
  void handleBackButton(BuildContext context, {String? fallbackRoute}) {
    if (context.canPop()) {
      debugPrint('🔙 BackButtonMixin: Using context.pop()');
      context.pop();
    } else if (fallbackRoute != null) {
      debugPrint('🔙 BackButtonMixin: Using fallback route: $fallbackRoute');
      context.go(fallbackRoute);
    } else {
      // Fallback mặc định dựa trên route hiện tại
      final currentRoute = GoRouterState.of(context).uri.path;
      final fallback = _determineFallbackRoute(currentRoute);
      debugPrint('🔙 BackButtonMixin: Using determined fallback: $fallback');
      context.go(fallback);
    }
  }

  /// Xác định fallback route dựa trên route hiện tại
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

  /// Tạo PopScope widget với xử lý back button
  Widget wrapWithBackHandler({
    required Widget child,
    String? fallbackRoute,
  }) {
    return Builder(
      builder: (context) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          handleBackButton(context, fallbackRoute: fallbackRoute);
        },
        child: child,
      ),
    );
  }

  /// Tạo AppBar với back button được xử lý đúng cách
  AppBar createAppBarWithBackButton({
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
          onPressed: () => handleBackButton(context, fallbackRoute: fallbackRoute),
        ),
      ),
    );
  }
}

/// Extension để thêm back button handling cho BuildContext
extension BackButtonContext on BuildContext {
  /// Xử lý back button với fallback route
  void handleBack({String? fallbackRoute}) {
    if (canPop()) {
      debugPrint('🔙 Context: Using context.pop()');
      pop();
    } else if (fallbackRoute != null) {
      debugPrint('🔙 Context: Using fallback route: $fallbackRoute');
      go(fallbackRoute);
    } else {
      // Fallback mặc định dựa trên route hiện tại
      final currentRoute = GoRouterState.of(this).uri.path;
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
      debugPrint('🔙 Context: Using determined fallback: $fallback');
      go(fallback);
    }
  }
}

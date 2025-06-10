import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Screen type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // Responsive values
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop ?? tablet ?? mobile;
  }
  
  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  // Responsive font sizes
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 4;
  }
  
  // Responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth - 32; // Full width minus padding
    } else if (isTablet(context)) {
      return (screenWidth - 64) / 2; // Two columns
    } else {
      return 300; // Fixed width for desktop
    }
  }
  
  // Responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.8; // 80% of screen width
    } else if (isTablet(context)) {
      return 280;
    } else {
      return 300;
    }
  }
  
  // Responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else {
      return kToolbarHeight + 8;
    }
  }
  
  // Responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    return getResponsiveValue(
      context,
      mobile: baseSize,
      tablet: baseSize + 2,
      desktop: baseSize + 4,
    );
  }
  
  // Check if should use drawer (mobile) or sidebar (desktop)
  static bool shouldUseDrawer(BuildContext context) {
    return isMobile(context);
  }
  
  // Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
  
  // Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return BorderRadius.circular(8);
    } else if (isTablet(context)) {
      return BorderRadius.circular(12);
    } else {
      return BorderRadius.circular(16);
    }
  }
  
  // Get responsive elevation
  static double getResponsiveElevation(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 4;
    } else {
      return 6;
    }
  }
}

// Extension for easier access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get shouldUseDrawer => ResponsiveHelper.shouldUseDrawer(this);
  
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
  BorderRadius get responsiveBorderRadius => ResponsiveHelper.getResponsiveBorderRadius(this);
  double get responsiveElevation => ResponsiveHelper.getResponsiveElevation(this);
}

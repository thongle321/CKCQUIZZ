import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/providers/user_provider.dart';

/// Base screen với theme theo role
class RoleThemedScreen extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const RoleThemedScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return RoleThemedWidget(
      role: role,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: RoleTheme.getPrimaryColor(role),
          foregroundColor: Colors.white,
          actions: actions,
          bottom: bottom,
          automaticallyImplyLeading: showBackButton,
          elevation: 2,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

/// Card component thống nhất
class UnifiedCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const UnifiedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: RoleTheme.getAccentColor(role),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Status chip thống nhất
class UnifiedStatusChip extends ConsumerWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const UnifiedStatusChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor ?? RoleTheme.getPrimaryColor(role),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

/// Progress indicator thống nhất
class UnifiedProgressIndicator extends ConsumerWidget {
  final double value;
  final String? label;

  const UnifiedProgressIndicator({
    super.key,
    required this.value,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],
        LinearProgressIndicator(
          value: value,
          backgroundColor: RoleTheme.getAccentColor(role),
          valueColor: AlwaysStoppedAnimation<Color>(
            RoleTheme.getPrimaryColor(role),
          ),
          minHeight: 6,
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: RoleTheme.getPrimaryColor(role),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Button thống nhất
class UnifiedButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isText;

  const UnifiedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    if (isText) {
      return TextButton.icon(
        icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
        label: Text(text),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: RoleTheme.getPrimaryColor(role),
        ),
      );
    }

    if (isOutlined) {
      return OutlinedButton.icon(
        icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
        label: Text(text),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: RoleTheme.getPrimaryColor(role),
          side: BorderSide(color: RoleTheme.getPrimaryColor(role)),
        ),
      );
    }

    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: RoleTheme.getPrimaryColor(role),
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Stats card thống nhất
class UnifiedStatsCard extends ConsumerWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  const UnifiedStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return UnifiedCard(
      child: Column(
        children: [
          Icon(
            icon,
            color: RoleTheme.getPrimaryColor(role),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: RoleTheme.getPrimaryColor(role),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Search bar thống nhất
class UnifiedSearchBar extends ConsumerWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const UnifiedSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;

    return Container(
      padding: const EdgeInsets.all(16),
      color: RoleTheme.getAccentColor(role),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            Icons.search,
            color: RoleTheme.getPrimaryColor(role),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: RoleTheme.getSecondaryColor(role)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: RoleTheme.getPrimaryColor(role), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/auth_service.dart' as auth_service;
import 'package:ckcandr/providers/chuong_provider.dart';
import 'package:ckcandr/providers/lop_hoc_provider.dart';
import 'package:ckcandr/providers/api_user_provider.dart';
import 'package:ckcandr/providers/mon_hoc_provider.dart';
import 'package:ckcandr/providers/nhom_hocphan_provider.dart';
import 'package:ckcandr/providers/de_kiem_tra_provider.dart';
import 'package:ckcandr/providers/de_thi_provider.dart';
import 'package:ckcandr/services/thong_bao_service.dart';

class AdminSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.admin;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final primaryColor = RoleTheme.getPrimaryColor(role);
    final accentColor = RoleTheme.getAccentColor(role);
    
    return Container(
      width: isSmallScreen ? double.infinity : 250,
      color: accentColor,
      child: SafeArea(
        child: Column(
          children: [
            // User info header
            if (isSmallScreen)
              UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(
                  currentUser?.hoVaTen ?? 'Administrator',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                accountEmail: Text(
                  currentUser?.email ?? 'admin@ckcquiz.com',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.8),
                  child: Text(
                    currentUser?.hoVaTen.isNotEmpty == true
                        ? currentUser!.hoVaTen[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryColor.withOpacity(0.8),
                      child: Text(
                        currentUser?.hoVaTen.isNotEmpty == true
                            ? currentUser!.hoVaTen[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUser?.hoVaTen ?? 'Administrator',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      currentUser?.email ?? 'admin@ckcquiz.com',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        RoleTheme.getRoleName(role),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(color: Colors.grey[300]),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    index: 0,
                    title: 'Tổng quan',
                    icon: Icons.dashboard,
                    selected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  _buildMenuItem(
                    context,
                    index: 1,
                    title: 'Người dùng',
                    icon: Icons.people,
                    selected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  _buildMenuItem(
                    context,
                    index: 2,
                    title: 'Môn học',
                    icon: Icons.book,
                    selected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  _buildMenuItem(
                    context,
                    index: 3,
                    title: 'Lớp học',
                    icon: Icons.class_outlined,
                    selected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                  _buildMenuItem(
                    context,
                    index: 4,
                    title: 'Phân công',
                    icon: Icons.assignment_ind,
                    selected: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                  _buildMenuItem(
                    context,
                    index: 5,
                    title: 'Thông báo',
                    icon: Icons.notifications,
                    selected: selectedIndex == 5,
                    onTap: () => onItemSelected(5),
                  ),
                  Divider(color: Colors.grey[300]),

                  _buildMenuItem(
                    context,
                    index: 6,
                    title: 'Cài đặt',
                    icon: Icons.settings,
                    selected: selectedIndex == 6,
                    onTap: () => onItemSelected(6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUser = ref.watch(currentUserProvider);
        final role = currentUser?.quyen ?? UserRole.admin;
        final primaryColor = RoleTheme.getPrimaryColor(role);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: selected ? primaryColor : Colors.grey[600],
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? primaryColor : Colors.grey[800],
              ),
            ),
            selected: selected,
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
} 
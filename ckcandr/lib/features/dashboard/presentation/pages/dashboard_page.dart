import 'package:ckcandr/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // 0 for Tổng quan, 1 for Nhóm học phần, etc.

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
      // TODO: Navigate to different views or update content based on index
      // For now, just close the drawer if open
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.of(context).pop();
      }
    });
    // Placeholder for navigation or content change
    // Example: if (index == 1) Navigator.pushNamed(context, AppRoutes.lopHocPhan);
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0: // Tổng quan
        return const Center(child: Text('Trang Tổng quan (chưa triển khai)'));
      // Add cases for other sections like Nhóm học phần, Câu hỏi, etc.
      // case 1: return LopHocPhanPage(); // Placeholder
      default:
        return Center(child: Text('Nội dung cho mục ${_selectedIndex + 1}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CKC QUIZ'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined), // Placeholder for user avatar
            onSelected: (value) {
              // TODO: Handle profile, settings, logout
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Hồ sơ'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Đăng xuất'),
              ),
            ],
          ),
        ],
      ),
      drawer: DashboardDrawer(onSelectItem: _onSelectItem, selectedIndex: _selectedIndex),
      body: Row(
        children: <Widget>[
          // Desktop/Tablet layout: Keep drawer visible
          if (MediaQuery.of(context).size.width >= 600)
            DashboardDrawer(onSelectItem: _onSelectItem, selectedIndex: _selectedIndex, isPermanent: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _getSelectedView(), // Content area
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          alignment: Alignment.center,
          child: const Text(
            'Copyright 2023 © CKCQUIZZ. All rights reserved',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }
} 
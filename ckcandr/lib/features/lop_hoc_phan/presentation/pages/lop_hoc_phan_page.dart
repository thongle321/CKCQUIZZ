import 'package:ckcandr/config/routes/app_routes.dart';
import 'package:ckcandr/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';

class LopHocPhanPage extends StatefulWidget {
  const LopHocPhanPage({super.key});

  @override
  State<LopHocPhanPage> createState() => _LopHocPhanPageState();
}

class _LopHocPhanPageState extends State<LopHocPhanPage> {
  int _selectedDrawerIndex = 1; // "Nhóm học phần" is at index 1 in the drawer

  final List<Map<String, dynamic>> hocKyGroups = [
    {
      'tenHocKy': 'Lập trình hướng đối tượng - Năm Học 2024 - HK1',
      'lopHocPhans': [
        {'id': 'LHP001', 'tenLop': 'Nhóm 1', 'siSo': 0},
        {'id': 'LHP002', 'tenLop': 'Nhóm 2', 'siSo': 0},
      ]
    },
    // Add more semester groups here
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    // Handle navigation based on index if needed, e.g.:
    if (index == 0) { // Assuming "Tổng quan" is at index 0
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
    // Other items in the drawer might navigate to different routes or do nothing
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CKC QUIZ'),
        automaticallyImplyLeading: false, // Remove hamburger icon for consistency
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              // Handle notification tap
            },
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              // backgroundImage: NetworkImage('USER_AVATAR_URL'), // Replace with actual avatar
              child: Icon(Icons.person), // Placeholder if no avatar
            ),
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Hồ sơ'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Cài đặt'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Đăng xuất'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? DashboardDrawer(
              onSelectItem: _onSelectItem,
              selectedIndex: _selectedDrawerIndex,
              isPermanent: false,
            )
          : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600)
            DashboardDrawer(
              onSelectItem: _onSelectItem,
              selectedIndex: _selectedDrawerIndex,
              isPermanent: true,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm lớp học phần...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('THÊM LỚP HỌC PHẦN'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.themLopHocPhan);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...hocKyGroups.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['tenHocKy'],
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // As per the image, seems like 2 cards per row
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.5, // Adjust aspect ratio as needed
                          ),
                          itemCount: group['lopHocPhans'].length,
                          itemBuilder: (context, index) {
                            final lopHocPhan = group['lopHocPhans'][index];
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: theme.dividerColor.withOpacity(0.5))
                              ),
                              color: theme.cardColor, // Use theme card color
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.chiTietLopHocPhan,
                                    arguments: lopHocPhan['id'],
                                  );
                                },
                                borderRadius: BorderRadius.circular(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lopHocPhan['tenLop'],
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Sĩ số: ${lopHocPhan['siSo']}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600 ? null : const BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Copyright 2025 © CKCQUIZZ. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
} 
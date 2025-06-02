import 'package:ckcandr/config/routes/router_provider.dart';
import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LopHocPhanPage extends StatefulWidget {
  const LopHocPhanPage({super.key});

  @override
  State<LopHocPhanPage> createState() => _LopHocPhanPageState();
}

class _LopHocPhanPageState extends State<LopHocPhanPage> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header area
          const Text(
            'CKC QUIZ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Search and Add button
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
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text('THÊM LỚP HỌC PHẦN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  context.pushNamed(AppRoutes.themLopHocPhan);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Learning groups section
          ...hocKyGroups.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['tenHocKy'],
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid layout
                    int crossAxisCount = constraints.maxWidth > 900 ? 3 : 
                                        (constraints.maxWidth > 600 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3.0,
                      ),
                      itemCount: group['lopHocPhans'].length,
                      itemBuilder: (context, index) {
                        final lopHocPhan = group['lopHocPhans'][index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.chiTietLopHocPhan,
                                pathParameters: {'id': lopHocPhan['id']},
                              );
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lopHocPhan['tenLop'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sĩ số: ${lopHocPhan['siSo']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
} 
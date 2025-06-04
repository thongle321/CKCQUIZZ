import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NhomHocPhanScreen extends ConsumerWidget {
  const NhomHocPhanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Xác định kích thước màn hình để điều chỉnh layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    
    // Số lượng cột hiển thị dựa trên kích thước màn hình
    int crossAxisCount = 4;
    if (isSmallScreen) {
      crossAxisCount = 1;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm và nút thêm
          isSmallScreen
              ? Column(
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 16),
                    _buildAddButton(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    const SizedBox(width: 16),
                    _buildAddButton(),
                  ],
                ),
          
          const SizedBox(height: 24),
          
          // Tên học phần
          const Text(
            'Lập trình hướng đối tượng - Năm Học 2024 - HK1',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Danh sách nhóm học phần
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isSmallScreen ? 3 : 1.5,
              ),
              itemCount: 8, // Số lượng nhóm mẫu
              itemBuilder: (context, index) {
                return _buildGroupCard(
                  context, 
                  'Nhóm ${index + 1}', 
                  'Sĩ số: ${10 + index}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget trường tìm kiếm
  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm lớp, môn học...',
        prefixIcon: const Icon(Icons.search, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
  
  // Widget nút thêm lớp học phần
  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement add group functionality
      },
      icon: const Icon(Icons.add, size: 18),
      label: const Text('THÊM LỚP HỌC PHẦN'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Widget cho mỗi card nhóm
  Widget _buildGroupCard(BuildContext context, String title, String subtitle) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to group details
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
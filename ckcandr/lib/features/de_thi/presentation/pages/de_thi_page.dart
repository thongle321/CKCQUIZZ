import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

class DeThiPage extends StatefulWidget {
  const DeThiPage({super.key});

  @override
  State<DeThiPage> createState() => _DeThiPageState();
}

class _DeThiPageState extends State<DeThiPage> {
  final List<Map<String, dynamic>> mockExams = [
    {
      'id': 'E001',
      'title': 'Kiểm tra giữa kỳ - Lập trình hướng đối tượng',
      'subject': 'Lập trình hướng đối tượng',
      'questionCount': 30,
      'duration': 60,
      'status': 'Đã xuất bản',
      'date': '20/09/2024',
    },
    {
      'id': 'E002',
      'title': 'Kiểm tra cuối kỳ - Cơ sở dữ liệu',
      'subject': 'Cơ sở dữ liệu',
      'questionCount': 40,
      'duration': 90,
      'status': 'Nháp',
      'date': '25/09/2024',
    },
    {
      'id': 'E003',
      'title': 'Kiểm tra thường xuyên - Mạng máy tính',
      'subject': 'Mạng máy tính',
      'questionCount': 20,
      'duration': 30,
      'status': 'Đã xuất bản',
      'date': '15/09/2024',
    },
    {
      'id': 'E004',
      'title': 'Kiểm tra thực hành - Lập trình web',
      'subject': 'Lập trình web',
      'questionCount': 15,
      'duration': 120,
      'status': 'Đã xuất bản',
      'date': '18/09/2024',
    },
    {
      'id': 'E005',
      'title': 'Kiểm tra cuối kỳ - Cấu trúc dữ liệu và giải thuật',
      'subject': 'Cấu trúc dữ liệu và giải thuật',
      'questionCount': 25,
      'duration': 60,
      'status': 'Nháp',
      'date': '30/09/2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header area
          const Text(
            'Đề thi',
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
                    hintText: 'Tìm kiếm đề thi...',
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
                label: const Text('TẠO ĐỀ THI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // TODO: Xử lý tạo đề thi
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Danh sách đề thi
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: mockExams.length,
            itemBuilder: (context, index) {
              final exam = mockExams[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Xử lý xem chi tiết đề thi
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: exam['status'] == 'Đã xuất bản' 
                                    ? Colors.green.withOpacity(0.1) 
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                exam['status'],
                                style: TextStyle(
                                  color: exam['status'] == 'Đã xuất bản' 
                                      ? Colors.green 
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (value) {
                                // TODO: Xử lý các hành động
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Chỉnh sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text('Nhân bản'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exam['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exam['subject'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${exam['questionCount']} câu hỏi',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${exam['duration']} phút',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ngày: ${exam['date']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
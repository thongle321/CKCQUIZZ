import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CauHoiPage extends StatefulWidget {
  const CauHoiPage({super.key});

  @override
  State<CauHoiPage> createState() => _CauHoiPageState();
}

class _CauHoiPageState extends State<CauHoiPage> {
  final List<Map<String, dynamic>> mockQuestions = [
    {
      'id': 'Q001',
      'content': 'Đâu là đặc điểm của lập trình hướng đối tượng?',
      'type': 'Trắc nghiệm',
      'subject': 'Lập trình hướng đối tượng',
      'createdAt': '15/08/2024',
    },
    {
      'id': 'Q002',
      'content': 'Giải thích khái niệm về tính kế thừa trong OOP.',
      'type': 'Tự luận',
      'subject': 'Lập trình hướng đối tượng',
      'createdAt': '16/08/2024',
    },
    {
      'id': 'Q003',
      'content': 'Java là ngôn ngữ lập trình hướng đối tượng?',
      'type': 'Đúng/Sai',
      'subject': 'Lập trình Java',
      'createdAt': '17/08/2024',
    },
    {
      'id': 'Q004',
      'content': 'Các đặc điểm của mạng máy tính là gì?',
      'type': 'Trắc nghiệm',
      'subject': 'Mạng máy tính',
      'createdAt': '18/08/2024',
    },
    {
      'id': 'Q005',
      'content': 'Phân tích ưu và nhược điểm của thuật toán sắp xếp nổi bọt.',
      'type': 'Tự luận',
      'subject': 'Cấu trúc dữ liệu và giải thuật',
      'createdAt': '19/08/2024',
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
            'Câu hỏi',
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
                    hintText: 'Tìm kiếm câu hỏi...',
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
                label: const Text('THÊM CÂU HỎI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // TODO: Xử lý thêm câu hỏi
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Danh sách câu hỏi
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Nội dung',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Loại',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Môn học',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Ngày tạo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockQuestions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final question = mockQuestions[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(question['id']),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              question['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(question['type']),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(question['subject']),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(question['createdAt']),
                          ),
                          SizedBox(
                            width: 50,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 20,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
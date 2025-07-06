/// Demo các trạng thái empty state cho exam results
/// 
/// File này demo các trường hợp hiển thị khi không có dữ liệu

import 'package:flutter/material.dart';

class EmptyStateDemo extends StatefulWidget {
  const EmptyStateDemo({super.key});

  @override
  State<EmptyStateDemo> createState() => _EmptyStateDemoState();
}

class _EmptyStateDemoState extends State<EmptyStateDemo> {
  int _selectedState = 0;

  final List<Map<String, dynamic>> _states = [
    {
      'title': 'Lớp rỗng - Không có sinh viên',
      'description': 'Trường hợp lớp không có sinh viên nào',
      'widget': _buildEmptyClassState(),
    },
    {
      'title': 'Không có ai làm bài',
      'description': 'Có sinh viên nhưng chưa ai làm bài thi',
      'widget': _buildNoSubmissionsState(),
    },
    {
      'title': 'Lỗi không tìm thấy dữ liệu',
      'description': 'API trả về 404 hoặc không tìm thấy',
      'widget': _buildNotFoundState(),
    },
    {
      'title': 'Lỗi server',
      'description': 'Lỗi 500 hoặc lỗi kết nối',
      'widget': _buildServerErrorState(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empty State Demo'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn trạng thái để xem:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_states.length, (index) {
                    final isSelected = _selectedState == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedState = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.purple : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          _states[index]['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _states[_selectedState]['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Preview
          Expanded(
            child: _states[_selectedState]['widget'],
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyClassState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Lớp rỗng',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có sinh viên nào trong lớp này\nhoặc chưa có ai làm bài thi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Có thể do:',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Lớp chưa được gán sinh viên\n'
                  '• Đề thi chưa được gán cho lớp\n'
                  '• Sinh viên chưa làm bài thi',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNoSubmissionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có bài nộp',
            style: TextStyle(
              fontSize: 24,
              color: Colors.orange[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Có sinh viên trong lớp nhưng\nchưa có ai làm bài thi này',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Không tìm thấy dữ liệu',
            style: TextStyle(
              fontSize: 24,
              color: Colors.orange[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đề thi này có thể chưa được gán cho lớp nào\nhoặc chưa có sinh viên làm bài',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildServerErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 24,
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Lỗi server. Vui lòng thử lại sau.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

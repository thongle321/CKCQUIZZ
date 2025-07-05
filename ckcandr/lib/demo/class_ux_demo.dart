/// Demo các cải tiến UX cho class management
/// 
/// File này demo:
/// 1. Status indicator với dấu chấm thay vì text
/// 2. Multiple selection trong add student dialog

import 'package:flutter/material.dart';

class ClassUXDemo extends StatefulWidget {
  const ClassUXDemo({super.key});

  @override
  State<ClassUXDemo> createState() => _ClassUXDemoState();
}

class _ClassUXDemoState extends State<ClassUXDemo> {
  int _selectedDemo = 0;

  final List<Map<String, dynamic>> _demos = [
    {
      'title': 'Status Indicator - Dấu chấm',
      'description': 'Hiển thị trạng thái bằng dấu chấm màu thay vì text',
      'widget': _buildStatusIndicatorDemo(),
    },
    {
      'title': 'Multiple Selection',
      'description': 'Chọn nhiều sinh viên cùng lúc',
      'widget': _buildMultipleSelectionDemo(),
    },
    {
      'title': 'Student List Layout',
      'description': 'Layout tối ưu cho danh sách sinh viên',
      'widget': _buildStudentListDemo(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class UX Demo'),
        backgroundColor: Colors.blue,
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
                  'Chọn demo để xem:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_demos.length, (index) {
                    final isSelected = _selectedDemo == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDemo = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          _demos[index]['title'],
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
                  _demos[_selectedDemo]['description'],
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
            child: _demos[_selectedDemo]['widget'],
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusIndicatorDemo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Indicators:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Old style
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cũ - Sử dụng text:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildOldStudentItem('Nguyễn Văn A', 'student001@email.com', true),
                  _buildOldStudentItem('Trần Thị B', 'student002@email.com', false),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // New style
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mới - Sử dụng dấu chấm:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildNewStudentItem('Nguyễn Văn A', 'student001@email.com', true),
                  _buildNewStudentItem('Trần Thị B', 'student002@email.com', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildOldStudentItem(String name, String email, bool isActive) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(email),
      trailing: Chip(
        label: Text(
          isActive ? 'Hoạt động' : 'Khóa',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: isActive ? Colors.green : Colors.red,
      ),
    );
  }

  static Widget _buildNewStudentItem(String name, String email, bool isActive) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(email),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  static Widget _buildMultipleSelectionDemo() {
    return _MultipleSelectionWidget();
  }

  static Widget _buildStudentListDemo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimized Student List Layout:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final students = [
                  {'name': 'Đinh Xuân Hoàng', 'email': 'dinhxuanh09@gmail.com', 'mssv': 'student000'},
                  {'name': 'Trần Văn B', 'email': 'student1@caothang.edu.vn', 'mssv': 'student001'},
                  {'name': 'Trần Văn C', 'email': 'student2@caothang.edu.vn', 'mssv': 'student002'},
                  {'name': 'Trần Văn D', 'email': 'student3@caothang.edu.vn', 'mssv': 'student003'},
                  {'name': 'Trần Văn E', 'email': 'student4@caothang.edu.vn', 'mssv': 'student004'},
                ];
                
                final student = students[index];
                final isActive = index % 2 == 0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        student['name']![0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(student['name']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MSSV: ${student['mssv']}'),
                        Text(
                          student['email']!,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {},
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa khỏi lớp'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MultipleSelectionWidget extends StatefulWidget {
  @override
  State<_MultipleSelectionWidget> createState() => _MultipleSelectionWidgetState();
}

class _MultipleSelectionWidgetState extends State<_MultipleSelectionWidget> {
  Set<String> _selectedStudents = {};
  
  final List<Map<String, String>> _students = [
    {'name': 'Trần Văn C', 'email': 'student2@caothang.edu.vn', 'mssv': 'student002'},
    {'name': 'Trần Văn D', 'email': 'student3@caothang.edu.vn', 'mssv': 'student003'},
    {'name': 'Trần Văn E', 'email': 'student4@caothang.edu.vn', 'mssv': 'student004'},
    {'name': 'Trần Văn M', 'email': 'student5@caothang.edu.vn', 'mssv': 'student006'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Multiple Selection Demo:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Selected students info
          if (_selectedStudents.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đã chọn ${_selectedStudents.length} sinh viên',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedStudents.clear();
                          });
                        },
                        child: const Text('Bỏ chọn tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _selectedStudents.map((mssv) {
                      final student = _students.firstWhere((s) => s['mssv'] == mssv);
                      return Chip(
                        label: Text(
                          student['name']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedStudents.remove(mssv);
                          });
                        },
                        backgroundColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Select all button
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (_selectedStudents.length == _students.length) {
                      _selectedStudents.clear();
                    } else {
                      _selectedStudents.addAll(_students.map((s) => s['mssv']!));
                    }
                  });
                },
                icon: Icon(
                  _selectedStudents.length == _students.length
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.blue,
                ),
                label: Text(
                  _selectedStudents.length == _students.length
                      ? 'Bỏ chọn tất cả'
                      : 'Chọn tất cả',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              const Spacer(),
              Text(
                '${_students.length} sinh viên có thể thêm',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Students list
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final isSelected = _selectedStudents.contains(student['mssv']);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey,
                      child: Text(
                        student['name']![0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      student['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MSSV: ${student['mssv']}'),
                        Text(
                          student['email']!,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedStudents.remove(student['mssv']);
                        } else {
                          _selectedStudents.add(student['mssv']!);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedStudents.isNotEmpty ? () {} : null,
                  child: Text(_selectedStudents.length > 1 
                      ? 'Thêm ${_selectedStudents.length} sinh viên'
                      : 'Thêm vào lớp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

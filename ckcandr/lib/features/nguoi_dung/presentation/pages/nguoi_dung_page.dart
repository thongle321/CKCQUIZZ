import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

class NguoiDungPage extends StatefulWidget {
  const NguoiDungPage({super.key});

  @override
  State<NguoiDungPage> createState() => _NguoiDungPageState();
}

class _NguoiDungPageState extends State<NguoiDungPage> {
  final List<Map<String, dynamic>> mockUsers = [
    {
      'id': 'U001',
      'name': 'Nguyễn Văn A',
      'email': 'nguyenvana@gmail.com',
      'role': 'Sinh viên',
      'status': 'Hoạt động',
    },
    {
      'id': 'U002',
      'name': 'Trần Thị B',
      'email': 'tranthib@gmail.com',
      'role': 'Giảng viên',
      'status': 'Hoạt động',
    },
    {
      'id': 'U003',
      'name': 'Lê Văn C',
      'email': 'levanc@gmail.com',
      'role': 'Sinh viên',
      'status': 'Hoạt động',
    },
    {
      'id': 'U004',
      'name': 'Phạm Thị D',
      'email': 'phamthid@gmail.com',
      'role': 'Sinh viên',
      'status': 'Tạm khóa',
    },
    {
      'id': 'U005',
      'name': 'Hoàng Văn E',
      'email': 'hoangvane@gmail.com',
      'role': 'Quản trị viên',
      'status': 'Hoạt động',
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
            'Người dùng',
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
                    hintText: 'Tìm kiếm người dùng...',
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
                label: const Text('THÊM NGƯỜI DÙNG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // TODO: Xử lý thêm người dùng
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Danh sách người dùng
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
                        flex: 3,
                        child: Text(
                          'Họ và tên',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Vai trò',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Trạng thái',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 100),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockUsers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = mockUsers[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(user['id']),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(user['name']),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(user['email']),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(user['role']),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: user['status'] == 'Hoạt động' 
                                        ? Colors.green 
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(user['status']),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
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
                                  icon: const Icon(
                                    Icons.delete_outline, 
                                    size: 18, 
                                    color: Colors.red
                                  ),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 20,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    user['status'] == 'Hoạt động'
                                        ? Icons.lock_outline
                                        : Icons.lock_open_outlined,
                                    size: 18,
                                    color: user['status'] == 'Hoạt động'
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
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
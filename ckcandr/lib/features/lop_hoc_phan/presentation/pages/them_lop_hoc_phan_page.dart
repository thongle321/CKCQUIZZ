import 'package:ckcandr/features/auth/presentation/widgets/auth_button.dart';
import 'package:ckcandr/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class ThemLopHocPhanPage extends StatefulWidget {
  const ThemLopHocPhanPage({super.key});

  @override
  State<ThemLopHocPhanPage> createState() => _ThemLopHocPhanPageState();
}

class _ThemLopHocPhanPageState extends State<ThemLopHocPhanPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tenNhomController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  // Sample data for dropdowns - replace with actual data
  String? _selectedMonHoc;
  final List<String> _monHocItems = ['Lập trình hướng đối tượng', 'Cấu trúc dữ liệu', 'Toán rời rạc'];
  String? _selectedNamHoc;
  final List<String> _namHocItems = ['2023-2024', '2024-2025', '2025-2026'];
  String? _selectedHocKy;
  final List<String> _hocKyItems = ['HK1', 'HK2', 'HK Hè'];

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu lớp học phần (chưa triển khai)')),
      );
      Navigator.of(context).pop();
    }
  }

 @override
  void dispose() {
    _tenNhomController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Lớp Học Phần'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSectionTitle(context, 'Tên nhóm'),
              AuthTextField(
                controller: _tenNhomController,
                labelText: 'Nhập tên nhóm',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên nhóm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildSectionTitle(context, 'Ghi chú'),
              AuthTextField(
                controller: _ghiChuController,
                labelText: 'Nhập ghi chú',
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              _buildSectionTitle(context, 'Môn học'),
              _buildDropdown<String>(
                value: _selectedMonHoc,
                items: _monHocItems,
                hint: 'Chọn môn học',
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMonHoc = newValue;
                  });
                },
                validator: (value) => value == null ? 'Vui lòng chọn môn học' : null,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Năm học'),
                        _buildDropdown<String>(
                          value: _selectedNamHoc,
                          items: _namHocItems,
                          hint: 'Chọn năm học',
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedNamHoc = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Vui lòng chọn năm học' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Học kỳ'),
                        _buildDropdown<String>(
                          value: _selectedHocKy,
                          items: _hocKyItems,
                          hint: 'Học kỳ',
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedHocKy = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Vui lòng chọn học kỳ' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Align(
                alignment: Alignment.bottomRight,
                child: AuthButton(
                  onPressed: _handleSave,
                  text: 'LƯU',
                  icon: Icons.add,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
    FormFieldValidator<T>? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0)
      ),
      items: items.map<DropdownMenuItem<T>>((T itemValue) {
        return DropdownMenuItem<T>(
          value: itemValue,
          child: Text(itemValue.toString()), // Assumes T can be converted to String for display
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:ckcandr/models/exam_permissions_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';

/// Demo screen để test các scenario permissions khác nhau
class ExamPermissionsDemoScreen extends StatefulWidget {
  const ExamPermissionsDemoScreen({super.key});

  @override
  State<ExamPermissionsDemoScreen> createState() => _ExamPermissionsDemoScreenState();
}

class _ExamPermissionsDemoScreenState extends State<ExamPermissionsDemoScreen> {
  ExamPermissions _currentPermissions = ExamPermissions.defaultPermissions();
  
  final ExamForStudent _sampleExam = const ExamForStudent(
    examId: 1,
    examName: 'Bài kiểm tra Lập trình C++',
    subjectName: 'Lập trình C/C++',
    totalQuestions: 20,
    status: 'DaKetThuc',
    resultId: 123,
  );

  @override
  Widget build(BuildContext context) {
    final examWithPermissions = _sampleExam.copyWithPermissions(_currentPermissions);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Exam Permissions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cài đặt quyền của Giảng viên:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    CheckboxListTile(
                      title: const Text('Cho phép xem điểm số'),
                      value: _currentPermissions.showScore,
                      onChanged: (value) {
                        setState(() {
                          _currentPermissions = _currentPermissions.copyWith(
                            showScore: value ?? false,
                          );
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Cho phép xem bài làm'),
                      value: _currentPermissions.showExamPaper,
                      onChanged: (value) {
                        setState(() {
                          _currentPermissions = _currentPermissions.copyWith(
                            showExamPaper: value ?? false,
                          );
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Cho phép xem đáp án'),
                      value: _currentPermissions.showAnswers,
                      onChanged: (value) {
                        setState(() {
                          _currentPermissions = _currentPermissions.copyWith(
                            showAnswers: value ?? false,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Scenarios
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scenarios nhanh:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _setScenario('none'),
                          child: const Text('Không cho phép gì'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _setScenario('score_only'),
                          child: const Text('Chỉ điểm số'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _setScenario('all'),
                          child: const Text('Tất cả'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kết quả cho Sinh viên:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildResultItem(
                      'Có thể xem kết quả?',
                      examWithPermissions.canViewResult,
                    ),
                    _buildResultItem(
                      'Có thể xem điểm số?',
                      examWithPermissions.canViewScore,
                    ),
                    _buildResultItem(
                      'Có thể xem bài làm?',
                      examWithPermissions.canViewExamPaper,
                    ),
                    _buildResultItem(
                      'Có thể xem đáp án?',
                      examWithPermissions.canViewAnswers,
                    ),
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mô tả quyền:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(_currentPermissions.permissionDescription),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, bool allowed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            color: allowed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: allowed ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _setScenario(String scenario) {
    setState(() {
      switch (scenario) {
        case 'none':
          _currentPermissions = ExamPermissions.defaultPermissions();
          break;
        case 'score_only':
          _currentPermissions = const ExamPermissions(
            showExamPaper: false,
            showScore: true,
            showAnswers: false,
          );
          break;
        case 'all':
          _currentPermissions = const ExamPermissions(
            showExamPaper: true,
            showScore: true,
            showAnswers: true,
          );
          break;
      }
    });
  }
}

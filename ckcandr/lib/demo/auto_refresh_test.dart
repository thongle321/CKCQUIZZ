/// Test file để kiểm tra logic auto-refresh mới
/// 
/// File này test xem auto-refresh có bỏ qua đúng các trang theo role không

import 'package:flutter/material.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';
import 'package:ckcandr/models/user_model.dart';

void testAutoRefreshLogic() {
  debugPrint('🧪 Testing Auto-Refresh Logic');
  debugPrint('================================');

  // Test Admin role
  debugPrint('\n👑 Testing ADMIN role:');
  debugPrint('Should BLOCK: adminUsers, adminAssignments, adminClasses, adminSubjects');
  debugPrint('Should ALLOW: other keys');
  
  final adminBlockedKeys = [
    AutoRefreshKeys.adminUsers,
    AutoRefreshKeys.adminAssignments, 
    AutoRefreshKeys.adminClasses,
    AutoRefreshKeys.adminSubjects,
  ];
  
  final adminAllowedKeys = [
    AutoRefreshKeys.adminNotifications,
    AutoRefreshKeys.teacherClasses,
    AutoRefreshKeys.studentExams,
  ];
  
  for (final key in adminBlockedKeys) {
    final allowed = AutoRefreshService.isKeyAllowedForRole(key, UserRole.admin);
    debugPrint('  $key: ${allowed ? "❌ ALLOWED (WRONG)" : "✅ BLOCKED (CORRECT)"}');
  }
  
  for (final key in adminAllowedKeys) {
    final allowed = AutoRefreshService.isKeyAllowedForRole(key, UserRole.admin);
    debugPrint('  $key: ${allowed ? "✅ ALLOWED (CORRECT)" : "❌ BLOCKED (WRONG)"}');
  }

  // Test Teacher role
  debugPrint('\n👨‍🏫 Testing TEACHER role:');
  debugPrint('Should BLOCK: teacherClasses, teacherQuestions, teacherExams');
  debugPrint('Should ALLOW: other keys');
  
  final teacherBlockedKeys = [
    AutoRefreshKeys.teacherClasses,
    AutoRefreshKeys.teacherQuestions,
    AutoRefreshKeys.teacherExams,
  ];
  
  final teacherAllowedKeys = [
    AutoRefreshKeys.teacherExamResults,
    AutoRefreshKeys.adminUsers,
    AutoRefreshKeys.studentExams,
  ];
  
  for (final key in teacherBlockedKeys) {
    final allowed = AutoRefreshService.isKeyAllowedForRole(key, UserRole.giangVien);
    debugPrint('  $key: ${allowed ? "❌ ALLOWED (WRONG)" : "✅ BLOCKED (CORRECT)"}');
  }
  
  for (final key in teacherAllowedKeys) {
    final allowed = AutoRefreshService.isKeyAllowedForRole(key, UserRole.giangVien);
    debugPrint('  $key: ${allowed ? "✅ ALLOWED (CORRECT)" : "❌ BLOCKED (WRONG)"}');
  }

  // Test Student role
  debugPrint('\n👨‍🎓 Testing STUDENT role:');
  debugPrint('Should BLOCK: studentClasses, studentExams');
  debugPrint('Should ALLOW: other keys');
  
  final studentBlockedKeys = [
    AutoRefreshKeys.studentClasses,
    AutoRefreshKeys.studentExams,
  ];
  
  final studentAllowedKeys = [
    AutoRefreshKeys.studentNotifications,
    AutoRefreshKeys.adminUsers,
    AutoRefreshKeys.teacherClasses,
  ];
  
  for (final key in studentBlockedKeys) {
    final allowed = AutoRefreshService.isKeyAllowedForRole(key, UserRole.sinhVien);
    debugPrint('  $key: ${allowed ? "❌ ALLOWED (WRONG)" : "✅ BLOCKED (CORRECT)"}');
  }
  
  for (final key in studentAllowedKeys) {
    final allowed = AutoRefreshService.isKeyAllowedForRole(key, UserRole.sinhVien);
    debugPrint('  $key: ${allowed ? "✅ ALLOWED (CORRECT)" : "❌ BLOCKED (WRONG)"}');
  }

  debugPrint('\n🎯 Test Summary:');
  debugPrint('- Admin: BLOCKS user, assignments, classes, subjects management');
  debugPrint('- Teacher: BLOCKS classes, questions, exams management');  
  debugPrint('- Student: BLOCKS classes and exam taking');
  debugPrint('================================');
}

/// Widget demo để test auto-refresh với các role khác nhau
class AutoRefreshTestWidget extends StatefulWidget {
  final UserRole testRole;
  final String testKey;
  
  const AutoRefreshTestWidget({
    super.key,
    required this.testRole,
    required this.testKey,
  });

  @override
  State<AutoRefreshTestWidget> createState() => _AutoRefreshTestWidgetState();
}

class _AutoRefreshTestWidgetState extends State<AutoRefreshTestWidget> {
  final AutoRefreshService _service = AutoRefreshService();
  int _refreshCount = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    debugPrint('🧪 Testing auto-refresh for ${widget.testRole} with key: ${widget.testKey}');
    
    _service.startAutoRefresh(
      key: widget.testKey,
      callback: () {
        setState(() {
          _refreshCount++;
        });
        debugPrint('🔄 Refresh callback called: $_refreshCount');
      },
      userRole: widget.testRole,
      intervalSeconds: 5, // Fast interval for testing
    );
    
    setState(() {
      _isRefreshing = _service.isAutoRefreshing(widget.testKey);
    });
  }

  @override
  void dispose() {
    _service.stopAutoRefresh(widget.testKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAllowed = AutoRefreshService.isKeyAllowedForRole(widget.testKey, widget.testRole);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${widget.testRole}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Key: ${widget.testKey}'),
            Text('Expected: ${isAllowed ? "ALLOWED" : "BLOCKED"}'),
            Text('Actually Refreshing: ${_isRefreshing ? "YES" : "NO"}'),
            Text('Refresh Count: $_refreshCount'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isAllowed ? Icons.check_circle : Icons.block,
                  color: isAllowed ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isAllowed ? 'Should refresh' : 'Should NOT refresh',
                  style: TextStyle(
                    color: isAllowed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

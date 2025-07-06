/// Demo để test auto submit khi hết thời gian
/// 
/// File này demo các tình huống auto submit:
/// 1. Hết thời gian diễn ra bài thi (exam end time)
/// 2. Hết thời gian làm bài (duration)
/// 3. Unfocus quá nhiều lần

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';

class AutoSubmitDemo extends StatefulWidget {
  const AutoSubmitDemo({super.key});

  @override
  State<AutoSubmitDemo> createState() => _AutoSubmitDemoState();
}

class _AutoSubmitDemoState extends State<AutoSubmitDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Submit Demo'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto Submit Test Scenarios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildScenario1(),
            const SizedBox(height: 20),
            
            _buildScenario2(),
            const SizedBox(height: 20),
            
            _buildScenario3(),
            const SizedBox(height: 20),
            
            _buildCurrentTimeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildScenario1() {
    // Scenario 1: Exam end time đã qua
    final now = TimezoneHelper.nowInVietnam();
    final examEndTime = now.subtract(const Duration(minutes: 5)); // 5 phút trước
    final examEndTimeUtc = TimezoneHelper.toUtc(examEndTime);
    
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer_off, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Scenario 1: Hết thời gian diễn ra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text('Current time (GMT+7): ${_formatTime(now)}'),
            Text('Exam end time (GMT+7): ${_formatTime(examEndTime)}'),
            Text('Exam end time (GMT+0 - DB): ${_formatTime(examEndTimeUtc)}'),
            
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '❌ Exam đã hết thời gian diễn ra 5 phút trước\n→ Phải auto submit ngay lập tức',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenario2() {
    // Scenario 2: Exam vẫn trong thời gian diễn ra nhưng duration hết
    final now = TimezoneHelper.nowInVietnam();
    final examEndTime = now.add(const Duration(hours: 1)); // Còn 1 tiếng
    final examEndTimeUtc = TimezoneHelper.toUtc(examEndTime);
    
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Scenario 2: Hết thời gian làm bài',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text('Current time (GMT+7): ${_formatTime(now)}'),
            Text('Exam end time (GMT+7): ${_formatTime(examEndTime)}'),
            Text('Exam end time (GMT+0 - DB): ${_formatTime(examEndTimeUtc)}'),
            Text('Duration: 60 phút (đã hết)'),
            
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '⚠️ Exam vẫn trong thời gian diễn ra nhưng đã hết 60 phút làm bài\n→ Auto submit vì hết duration',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenario3() {
    return Card(
      color: Colors.purple.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.visibility_off, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Scenario 3: Unfocus quá nhiều',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            const Text('Unfocus count: 3/2 (vượt quá giới hạn)'),
            
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '🚫 Sinh viên đã rời khỏi app quá nhiều lần\n→ Auto submit vì vi phạm quy định',
                style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeInfo() {
    final now = TimezoneHelper.nowInVietnam();
    final utcNow = DateTime.now().toUtc();
    
    return Card(
      color: Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Current Time Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text('Device time: ${_formatTime(DateTime.now())}'),
            Text('UTC time: ${_formatTime(utcNow)}'),
            Text('Vietnam time (GMT+7): ${_formatTime(now)}'),
            
            const SizedBox(height: 8),
            const Text(
              'ℹ️ Tất cả logic so sánh thời gian sử dụng GMT+7',
              style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(time);
  }
}

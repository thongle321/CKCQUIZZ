/// Demo để test logic thời gian
/// 
/// File này test các tình huống thời gian khác nhau

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';

class TimeTestDemo extends StatefulWidget {
  const TimeTestDemo({super.key});

  @override
  State<TimeTestDemo> createState() => _TimeTestDemoState();
}

class _TimeTestDemoState extends State<TimeTestDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Test Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Logic Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildCurrentTimeTest(),
            const SizedBox(height: 20),
            
            _buildTimezoneTest(),
            const SizedBox(height: 20),
            
            _buildComparisonTest(),
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Refresh
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeTest() {
    final deviceTime = DateTime.now();
    final utcTime = DateTime.now().toUtc();
    final vietnamTime = TimezoneHelper.nowInVietnam();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Time Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Text('Device time: ${_formatTime(deviceTime)}'),
            Text('UTC time: ${_formatTime(utcTime)}'),
            Text('Vietnam time (GMT+7): ${_formatTime(vietnamTime)}'),
            
            const SizedBox(height: 8),
            Text(
              'Difference (Vietnam - UTC): ${vietnamTime.difference(utcTime).inHours} hours',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneTest() {
    // Test timezone conversion
    final testTimeGMT7 = DateTime(2025, 1, 15, 15, 30); // 3:30 PM GMT+7
    final testTimeGMT0 = TimezoneHelper.toUtc(testTimeGMT7); // Convert to GMT+0
    final backToGMT7 = TimezoneHelper.toLocal(testTimeGMT0); // Convert back to GMT+7
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timezone Conversion Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Text('Original (GMT+7): ${_formatTime(testTimeGMT7)}'),
            Text('Converted to GMT+0: ${_formatTime(testTimeGMT0)}'),
            Text('Back to GMT+7: ${_formatTime(backToGMT7)}'),
            
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: testTimeGMT7.isAtSameMomentAs(backToGMT7) 
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                testTimeGMT7.isAtSameMomentAs(backToGMT7)
                    ? '✅ Conversion is correct'
                    : '❌ Conversion failed',
                style: TextStyle(
                  color: testTimeGMT7.isAtSameMomentAs(backToGMT7) 
                      ? Colors.green 
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTest() {
    final now = TimezoneHelper.nowInVietnam();
    
    // Test case 1: Time in the past (should trigger auto submit)
    final pastTime = now.subtract(const Duration(minutes: 5));
    final pastTimeUtc = TimezoneHelper.toUtc(pastTime);
    final pastTimeBack = TimezoneHelper.toLocal(pastTimeUtc);
    
    // Test case 2: Time in the future (should not trigger)
    final futureTime = now.add(const Duration(minutes: 30));
    final futureTimeUtc = TimezoneHelper.toUtc(futureTime);
    final futureTimeBack = TimezoneHelper.toLocal(futureTimeUtc);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto Submit Logic Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Text('Current time: ${_formatTime(now)}'),
            
            const SizedBox(height: 12),
            const Text('Test Case 1: Past exam end time'),
            Text('Exam end (GMT+7): ${_formatTime(pastTime)}'),
            Text('Exam end (GMT+0): ${_formatTime(pastTimeUtc)}'),
            Text('Converted back: ${_formatTime(pastTimeBack)}'),
            Text('Should auto submit: ${now.isAfter(pastTimeBack) ? "YES" : "NO"}'),
            
            const SizedBox(height: 12),
            const Text('Test Case 2: Future exam end time'),
            Text('Exam end (GMT+7): ${_formatTime(futureTime)}'),
            Text('Exam end (GMT+0): ${_formatTime(futureTimeUtc)}'),
            Text('Converted back: ${_formatTime(futureTimeBack)}'),
            Text('Should auto submit: ${now.isAfter(futureTimeBack) ? "YES" : "NO"}'),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ℹ️ Logic: now.isAfter(examEndTimeLocal)\nwhere examEndTimeLocal = TimezoneHelper.toLocal(examEndTimeFromDB)',
                style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
              ),
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

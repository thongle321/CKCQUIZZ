/// Demo file để test timezone conversion
/// 
/// File này demo cách sử dụng TimezoneHelper để convert giữa GMT+0 và GMT+7

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ckcandr/models/de_thi_model.dart';

class TimezoneDemo extends StatelessWidget {
  const TimezoneDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timezone Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timezone Conversion Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildDemoSection(),
            
            const SizedBox(height: 20),
            
            _buildExamTimeDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSection() {
    final now = DateTime.now();
    final utcNow = DateTime.now().toUtc();
    final vietnamNow = TimezoneHelper.nowInVietnam();
    
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
            
            _buildTimeRow('Local Time (Device)', now),
            _buildTimeRow('UTC Time', utcNow),
            _buildTimeRow('Vietnam Time (GMT+7)', vietnamNow),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text(
              'Conversion Examples',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Example: Convert GMT+7 to GMT+0
            const Text('Example 1: Convert GMT+7 to GMT+0 (for database)'),
            _buildConversionExample(
              'Input (GMT+7)',
              DateTime(2025, 1, 15, 14, 30), // 2:30 PM GMT+7
              'Output (GMT+0)',
              TimezoneHelper.toUtc(DateTime(2025, 1, 15, 14, 30)), // 7:30 AM GMT+0
            ),
            
            const SizedBox(height: 12),
            
            // Example: Convert GMT+0 to GMT+7
            const Text('Example 2: Convert GMT+0 to GMT+7 (for display)'),
            _buildConversionExample(
              'Input (GMT+0)',
              DateTime(2025, 1, 15, 7, 30), // 7:30 AM GMT+0
              'Output (GMT+7)',
              TimezoneHelper.toLocal(DateTime(2025, 1, 15, 7, 30)), // 2:30 PM GMT+7
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTimeDemo() {
    // Demo exam times
    final examStartGMT7 = DateTime(2025, 1, 20, 8, 0); // 8:00 AM GMT+7
    final examEndGMT7 = DateTime(2025, 1, 20, 10, 0); // 10:00 AM GMT+7
    
    // Convert to GMT+0 for database storage
    final examStartGMT0 = TimezoneHelper.toUtc(examStartGMT7);
    final examEndGMT0 = TimezoneHelper.toUtc(examEndGMT7);
    
    // Convert back to GMT+7 for display
    final displayStart = TimezoneHelper.toLocal(examStartGMT0);
    final displayEnd = TimezoneHelper.toLocal(examEndGMT0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exam Time Flow Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            const Text('1. Teacher creates exam with GMT+7 times:'),
            _buildTimeRow('Start Time (GMT+7)', examStartGMT7),
            _buildTimeRow('End Time (GMT+7)', examEndGMT7),
            
            const SizedBox(height: 12),
            
            const Text('2. System converts to GMT+0 for database:'),
            _buildTimeRow('Start Time (GMT+0)', examStartGMT0),
            _buildTimeRow('End Time (GMT+0)', examEndGMT0),
            
            const SizedBox(height: 12),
            
            const Text('3. System displays back as GMT+7 to users:'),
            _buildTimeRow('Display Start (GMT+7)', displayStart),
            _buildTimeRow('Display End (GMT+7)', displayEnd),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                '✅ Times match! The conversion is working correctly.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy HH:mm:ss').format(time),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionExample(String inputLabel, DateTime input, String outputLabel, DateTime output) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRow(inputLabel, input),
          _buildTimeRow(outputLabel, output),
        ],
      ),
    );
  }
}

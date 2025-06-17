/// Test script để kiểm tra API lớp học
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/sinh_vien_lop_provider.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: TestApiLopHocScreen(),
      ),
    ),
  );
}

class TestApiLopHocScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lopHocAsyncValue = ref.watch(sinhVienLopHocListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Lớp Học'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(sinhVienLopHocListProvider);
            },
          ),
        ],
      ),
      body: lopHocAsyncValue.when(
        data: (lopHocList) {
          return ListView.builder(
            itemCount: lopHocList.length,
            itemBuilder: (context, index) {
              final lopHoc = lopHocList[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(lopHoc.tenlop),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã lớp: ${lopHoc.malop}'),
                      Text('Học kỳ: HK${lopHoc.hocky ?? 'N/A'}'),
                      Text('Năm học: ${lopHoc.namhoc ?? 'N/A'}'),
                      Text('Sĩ số: ${lopHoc.siso ?? 0}'),
                      if (lopHoc.mamoi != null)
                        Text('Mã mời: ${lopHoc.mamoi}'),
                      Text('Trạng thái: ${lopHoc.trangthai == true ? "Hoạt động" : "Tạm dừng"}'),
                      if (lopHoc.monhocs.isNotEmpty)
                        Text('Môn học: ${lopHoc.monhocs.join(", ")}'),
                    ],
                  ),
                  trailing: Icon(
                    lopHoc.trangthai == true ? Icons.check_circle : Icons.pause_circle,
                    color: lopHoc.trangthai == true ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải dữ liệu từ API...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Lỗi: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sinhVienLopHocListProvider),
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

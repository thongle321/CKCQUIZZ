import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/mon_hoc_model.dart';

// Provider cho danh sách môn học
final monHocListProvider = StateProvider<List<MonHoc>>((ref) {
  return [
    MonHoc(
      id: '1',
      maMonHoc: 'WEB1013',
      tenMonHoc: 'Lập trình Web',
      soTinChi: 3,
      soGioLT: 30,
      soGioTH: 15,
      moTa: 'Môn học về các kỹ thuật lập trình web cơ bản',
    ),
    MonHoc(
      id: '2',
      maMonHoc: 'MOB1014',
      tenMonHoc: 'Lập trình Mobile',
      soTinChi: 4,
      soGioLT: 30,
      soGioTH: 30,
      moTa: 'Môn học về phát triển ứng dụng di động',
    ),
    MonHoc(
      id: '3',
      maMonHoc: 'JAV1001',
      tenMonHoc: 'Lập trình Java cơ bản',
      soTinChi: 3,
      soGioLT: 30,
      soGioTH: 15,
      moTa: 'Môn học về ngôn ngữ lập trình Java',
    ),
    MonHoc(
      id: '4',
      maMonHoc: 'HRM1025',
      tenMonHoc: 'Quản trị nhân sự',
      soTinChi: 2,
      soGioLT: 30,
      soGioTH: 0,
      moTa: 'Môn học về quản trị nhân sự trong doanh nghiệp',
    ),
    MonHoc(
      id: '5',
      maMonHoc: 'NET1022',
      tenMonHoc: 'Lập trình .NET',
      soTinChi: 3,
      soGioLT: 30,
      soGioTH: 15,
      trangThai: false,
      moTa: 'Môn học về phát triển ứng dụng trên nền tảng .NET',
    ),
    MonHoc(
      id: '6',
      maMonHoc: 'EMA1017',
      tenMonHoc: 'Marketing',
      soTinChi: 2,
      soGioLT: 30,
      soGioTH: 0,
      moTa: 'Môn học về các chiến lược marketing',
    ),
  ];
}); 
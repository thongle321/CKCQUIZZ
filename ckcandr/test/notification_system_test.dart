import 'package:flutter_test/flutter_test.dart';
import 'package:ckcandr/models/de_thi_model.dart';
import 'package:ckcandr/models/thong_bao_model.dart';

void main() {
  group('Notification System Model Tests', () {
    group('DeThiModel Tests', () {
      test('should create DeThiModel with correct properties', () {
        // Arrange & Act
        final exam = DeThiModel(
          made: 1,
          tende: 'Kiểm tra giữa kỳ',
          giaoCho: 'Lớp A, Lớp B',
          monthi: 1,
          thoigianbatdau: DateTime(2025, 1, 15, 10, 0),
          thoigianketthuc: DateTime(2025, 1, 15, 12, 0),
          trangthai: true,
        );

        // Assert
        expect(exam.made, equals(1));
        expect(exam.tende, equals('Kiểm tra giữa kỳ'));
        expect(exam.giaoCho, equals('Lớp A, Lớp B'));
        expect(exam.monthi, equals(1));
        expect(exam.trangthai, isTrue);
      });

      test('should determine exam status correctly', () {
        final now = DateTime.now();

        // Future exam
        final futureExam = DeThiModel(
          made: 1,
          tende: 'Future Exam',
          giaoCho: 'Lớp A',
          monthi: 1,
          thoigianbatdau: now.add(Duration(hours: 1)),
          thoigianketthuc: now.add(Duration(hours: 3)),
          trangthai: true,
        );

        // Past exam
        final pastExam = DeThiModel(
          made: 2,
          tende: 'Past Exam',
          giaoCho: 'Lớp B',
          monthi: 1,
          thoigianbatdau: now.subtract(Duration(hours: 3)),
          thoigianketthuc: now.subtract(Duration(hours: 1)),
          trangthai: true,
        );

        // Current exam
        final currentExam = DeThiModel(
          made: 3,
          tende: 'Current Exam',
          giaoCho: 'Lớp C',
          monthi: 1,
          thoigianbatdau: now.subtract(Duration(minutes: 30)),
          thoigianketthuc: now.add(Duration(minutes: 30)),
          trangthai: true,
        );

        // Assert
        expect(futureExam.getTrangThaiDeThi(), equals(TrangThaiDeThi.sapDienRa));
        expect(pastExam.getTrangThaiDeThi(), equals(TrangThaiDeThi.daKetThuc));
        expect(currentExam.getTrangThaiDeThi(), equals(TrangThaiDeThi.dangDienRa));
      });

      test('should determine edit permissions correctly', () {
        final now = DateTime.now();

        final futureExam = DeThiModel(
          made: 1,
          tende: 'Future Exam',
          giaoCho: 'Lớp A',
          monthi: 1,
          thoigianbatdau: now.add(Duration(hours: 1)),
          thoigianketthuc: now.add(Duration(hours: 3)),
          trangthai: true,
        );

        final pastExam = DeThiModel(
          made: 2,
          tende: 'Past Exam',
          giaoCho: 'Lớp B',
          monthi: 1,
          thoigianbatdau: now.subtract(Duration(hours: 3)),
          thoigianketthuc: now.subtract(Duration(hours: 1)),
          trangthai: true,
        );

        // Assert
        expect(futureExam.canEdit, isTrue);
        expect(futureExam.canDelete, isTrue);
        expect(pastExam.canEdit, isFalse);
        expect(pastExam.canDelete, isFalse);
      });
    });

    group('CreateThongBaoRequest Tests', () {
      test('should create request with correct format', () {
        // Arrange
        final noiDung = 'Test notification content';
        final nhomIds = [1, 2, 3];

        // Act
        final request = CreateThongBaoRequest(
          noiDung: noiDung,
          nhomIds: nhomIds,
        );

        // Assert
        expect(request.noiDung, equals(noiDung));
        expect(request.nhomIds, equals(nhomIds));

        final json = request.toJson();
        expect(json['noidung'], equals(noiDung));
        expect(json['nhomIds'], equals(nhomIds));
      });

      test('should create request with optional timestamp', () {
        // Arrange
        final noiDung = 'Test notification';
        final nhomIds = [1];
        final timestamp = DateTime.now();

        // Act
        final request = CreateThongBaoRequest(
          noiDung: noiDung,
          nhomIds: nhomIds,
          thoigiantao: timestamp,
        );

        // Assert
        expect(request.thoigiantao, equals(timestamp));

        final json = request.toJson();
        expect(json['thoigiantao'], isNotNull);
      });
    });

    group('ThongBao Model Tests', () {
      test('should detect exam notifications correctly', () {
        // Arrange
        final examNotification = ThongBao(
          maTb: 1,
          noiDung: '📝 Đề thi mới: "Kiểm tra giữa kỳ" đã được tạo',
          type: NotificationType.examNew,
          examId: 123,
        );

        final generalNotification = ThongBao(
          maTb: 2,
          noiDung: 'Thông báo chung về lịch học',
          type: NotificationType.general,
        );

        // Assert
        expect(examNotification.isExamNotification, isTrue);
        expect(generalNotification.isExamNotification, isFalse);
      });

      test('should determine exam action text correctly', () {
        final now = DateTime.now();

        // Can take exam now
        final currentExam = ThongBao(
          maTb: 1,
          noiDung: 'Đề thi đang diễn ra',
          type: NotificationType.examNew,
          examId: 1,
          examStartTime: now.subtract(Duration(minutes: 10)),
          examEndTime: now.add(Duration(minutes: 50)),
        );

        // Future exam
        final futureExam = ThongBao(
          maTb: 2,
          noiDung: 'Đề thi sắp diễn ra',
          type: NotificationType.examNew,
          examId: 2,
          examStartTime: now.add(Duration(hours: 1)),
          examEndTime: now.add(Duration(hours: 3)),
        );

        // Past exam
        final pastExam = ThongBao(
          maTb: 3,
          noiDung: 'Đề thi đã kết thúc',
          type: NotificationType.examNew,
          examId: 3,
          examStartTime: now.subtract(Duration(hours: 3)),
          examEndTime: now.subtract(Duration(hours: 1)),
        );

        // Assert
        expect(currentExam.examActionText, equals('Vào thi ngay'));
        expect(futureExam.examActionText, equals('Xem chi tiết'));
        expect(pastExam.examActionText, equals('Xem kết quả'));
      });

      test('should calculate time until exam correctly', () {
        final now = DateTime.now();
        final futureTime = now.add(Duration(hours: 2, minutes: 30));

        final notification = ThongBao(
          maTb: 1,
          noiDung: 'Đề thi sắp diễn ra',
          type: NotificationType.examNew,
          examId: 1,
          examStartTime: futureTime,
          examEndTime: futureTime.add(Duration(hours: 2)),
        );

        final timeUntil = notification.timeUntilExam;

        expect(timeUntil, isNotNull);
        expect(timeUntil!.inHours, equals(2));
        // Allow for small timing differences in test execution
        expect(timeUntil.inMinutes % 60, greaterThanOrEqualTo(29));
        expect(timeUntil.inMinutes % 60, lessThanOrEqualTo(30));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ckcandr/models/exam_permissions_model.dart';
import 'package:ckcandr/models/exam_taking_model.dart';

void main() {
  group('ExamPermissions Tests', () {
    test('should create default permissions with all disabled', () {
      final permissions = ExamPermissions.defaultPermissions();
      
      expect(permissions.showExamPaper, false);
      expect(permissions.showScore, false);
      expect(permissions.showAnswers, false);
      expect(permissions.canViewAnyResults, false);
    });

    test('should create permissions from JSON correctly', () {
      final json = {
        'hienthibailam': true,
        'xemdiemthi': false,
        'xemdapan': true,
      };
      
      final permissions = ExamPermissions.fromJson(json);
      
      expect(permissions.showExamPaper, true);
      expect(permissions.showScore, false);
      expect(permissions.showAnswers, true);
      expect(permissions.canViewAnyResults, true);
      expect(permissions.canViewCompleteResults, false);
    });

    test('should provide correct permission descriptions', () {
      // All disabled
      final noPermissions = ExamPermissions.defaultPermissions();
      expect(noPermissions.permissionDescription, 'Không được xem kết quả');

      // All enabled
      const allPermissions = ExamPermissions(
        showExamPaper: true,
        showScore: true,
        showAnswers: true,
      );
      expect(allPermissions.permissionDescription, 'Xem đầy đủ kết quả');

      // Only score
      const scoreOnly = ExamPermissions(
        showExamPaper: false,
        showScore: true,
        showAnswers: false,
      );
      expect(scoreOnly.permissionDescription, 'Chỉ được xem: điểm số');
    });

    test('should check specific permission combinations correctly', () {
      const permissions = ExamPermissions(
        showExamPaper: false,
        showScore: true,
        showAnswers: false,
      );

      expect(permissions.canViewOnlyScore, true);
      expect(permissions.canViewOnlyAnswers, false);
      expect(permissions.canViewOnlyExamPaper, false);
    });
  });

  group('ExamForStudent with Permissions Tests', () {
    test('should handle permissions correctly in canViewResult', () {
      // Create exam with result
      const exam = ExamForStudent(
        examId: 1,
        examName: 'Test Exam',
        totalQuestions: 10,
        status: 'DaKetThuc',
        resultId: 123,
      );

      // Without permissions (backward compatibility)
      expect(exam.canViewResult, true);

      // With no permissions
      final examWithNoPermissions = exam.copyWithPermissions(
        ExamPermissions.defaultPermissions()
      );
      expect(examWithNoPermissions.canViewResult, false);

      // With some permissions
      const somePermissions = ExamPermissions(
        showExamPaper: false,
        showScore: true,
        showAnswers: false,
      );
      final examWithSomePermissions = exam.copyWithPermissions(somePermissions);
      expect(examWithSomePermissions.canViewResult, true);
      expect(examWithSomePermissions.canViewScore, true);
      expect(examWithSomePermissions.canViewExamPaper, false);
      expect(examWithSomePermissions.canViewAnswers, false);
    });

    test('should not allow viewing results for ongoing exams', () {
      const ongoingExam = ExamForStudent(
        examId: 1,
        examName: 'Ongoing Exam',
        totalQuestions: 10,
        status: 'DangDienRa',
        resultId: null,
      );

      expect(ongoingExam.canViewResult, false);
      expect(ongoingExam.canViewScore, false);
      expect(ongoingExam.canViewExamPaper, false);
      expect(ongoingExam.canViewAnswers, false);
    });

    test('should copy exam with new permissions correctly', () {
      const originalExam = ExamForStudent(
        examId: 1,
        examName: 'Test Exam',
        totalQuestions: 10,
        status: 'DaKetThuc',
        resultId: 123,
      );

      const newPermissions = ExamPermissions(
        showExamPaper: true,
        showScore: false,
        showAnswers: true,
      );

      final updatedExam = originalExam.copyWithPermissions(newPermissions);

      expect(updatedExam.examId, originalExam.examId);
      expect(updatedExam.examName, originalExam.examName);
      expect(updatedExam.permissions, newPermissions);
      expect(updatedExam.canViewExamPaper, true);
      expect(updatedExam.canViewScore, false);
      expect(updatedExam.canViewAnswers, true);
    });
  });
}

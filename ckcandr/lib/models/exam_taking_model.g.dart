// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_taking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamForStudent _$ExamForStudentFromJson(Map<String, dynamic> json) =>
    ExamForStudent(
      examId: (json['made'] as num).toInt(),
      examName: json['tende'] as String?,
      subjectName: json['tenMonHoc'] as String?,
      duration: (json['thoigianthi'] as num?)?.toInt(),
      startTime: json['thoigiantbatdau'] == null
          ? null
          : DateTime.parse(json['thoigiantbatdau'] as String),
      endTime: json['thoigianketthuc'] == null
          ? null
          : DateTime.parse(json['thoigianketthuc'] as String),
      totalQuestions: (json['tongSoCau'] as num).toInt(),
      status: json['trangthaiThi'] as String,
      resultId: (json['ketQuaId'] as num?)?.toInt(),
      showExamPaper: json['showExamPaper'] as bool?,
      showScore: json['showScore'] as bool?,
      showAnswers: json['showAnswers'] as bool?,
    );

Map<String, dynamic> _$ExamForStudentToJson(ExamForStudent instance) =>
    <String, dynamic>{
      'made': instance.examId,
      'tende': instance.examName,
      'tenMonHoc': instance.subjectName,
      'thoigianthi': instance.duration,
      'thoigiantbatdau': instance.startTime?.toIso8601String(),
      'thoigianketthuc': instance.endTime?.toIso8601String(),
      'tongSoCau': instance.totalQuestions,
      'trangthaiThi': instance.status,
      'ketQuaId': instance.resultId,
      'showExamPaper': instance.showExamPaper,
      'showScore': instance.showScore,
      'showAnswers': instance.showAnswers,
    };

ExamQuestion _$ExamQuestionFromJson(Map<String, dynamic> json) => ExamQuestion(
      questionId: (json['macauhoi'] as num).toInt(),
      content: json['noiDung'] as String,
      difficulty: json['doKho'] as String,
      imageUrl: json['hinhanhurl'] as String?,
      questionType: json['loaiCauHoi'] as String,
      answers: (json['cauTraLois'] as List<dynamic>)
          .map((e) => ExamAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedAnswerId: json['selectedAnswerId'] as String?,
      selectedAnswerIds: (json['selectedAnswerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      essayAnswer: json['essayAnswer'] as String?,
      isAnswered: json['isAnswered'] as bool? ?? false,
    );

Map<String, dynamic> _$ExamQuestionToJson(ExamQuestion instance) =>
    <String, dynamic>{
      'macauhoi': instance.questionId,
      'noiDung': instance.content,
      'doKho': instance.difficulty,
      'hinhanhurl': instance.imageUrl,
      'loaiCauHoi': instance.questionType,
      'cauTraLois': instance.answers,
      'selectedAnswerId': instance.selectedAnswerId,
      'selectedAnswerIds': instance.selectedAnswerIds,
      'essayAnswer': instance.essayAnswer,
      'isAnswered': instance.isAnswered,
    };

ExamAnswer _$ExamAnswerFromJson(Map<String, dynamic> json) => ExamAnswer(
      answerId: (json['macautraloi'] as num).toInt(),
      content: json['noiDung'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );

Map<String, dynamic> _$ExamAnswerToJson(ExamAnswer instance) =>
    <String, dynamic>{
      'macautraloi': instance.answerId,
      'noiDung': instance.content,
      'isCorrect': instance.isCorrect,
    };

SubmitExamRequest _$SubmitExamRequestFromJson(Map<String, dynamic> json) =>
    SubmitExamRequest(
      examId: (json['made'] as num).toInt(),
      studentId: json['manguoidung'] as String,
      startTime: DateTime.parse(json['thoigianbatdau'] as String),
      endTime: DateTime.parse(json['thoigianketthuc'] as String),
      answers: (json['chiTietTraLoi'] as List<dynamic>)
          .map((e) => StudentAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmitExamRequestToJson(SubmitExamRequest instance) =>
    <String, dynamic>{
      'made': instance.examId,
      'manguoidung': instance.studentId,
      'thoigianbatdau': instance.startTime.toIso8601String(),
      'thoigianketthuc': instance.endTime.toIso8601String(),
      'chiTietTraLoi': instance.answers,
    };

StudentAnswer _$StudentAnswerFromJson(Map<String, dynamic> json) =>
    StudentAnswer(
      questionId: (json['macauhoi'] as num).toInt(),
      selectedAnswerId: (json['macautraloi'] as num?)?.toInt(),
      selectedAnswerIds: (json['danhSachMacautraloi'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      essayAnswer: json['cauTraLoiTuLuan'] as String?,
      answerTime: json['thoigiantraloi'] == null
          ? null
          : DateTime.parse(json['thoigiantraloi'] as String),
    );

Map<String, dynamic> _$StudentAnswerToJson(StudentAnswer instance) =>
    <String, dynamic>{
      'macauhoi': instance.questionId,
      'macautraloi': instance.selectedAnswerId,
      'danhSachMacautraloi': instance.selectedAnswerIds,
      'cauTraLoiTuLuan': instance.essayAnswer,
      'thoigiantraloi': instance.answerTime?.toIso8601String(),
    };

ExamResult _$ExamResultFromJson(Map<String, dynamic> json) => ExamResult(
      resultId: (json['makq'] as num).toInt(),
      examId: (json['made'] as num).toInt(),
      studentId: json['manguoidung'] as String,
      score: (json['diem'] as num).toDouble(),
      correctAnswers: (json['socaudung'] as num).toInt(),
      totalQuestions: (json['tongcauhoi'] as num).toInt(),
      startTime: DateTime.parse(json['thoigianbatdau'] as String),
      endTime: DateTime.parse(json['thoigianketthuc'] as String),
      completedTime: DateTime.parse(json['thoigianhoanthanh'] as String),
    );

Map<String, dynamic> _$ExamResultToJson(ExamResult instance) =>
    <String, dynamic>{
      'makq': instance.resultId,
      'made': instance.examId,
      'manguoidung': instance.studentId,
      'diem': instance.score,
      'socaudung': instance.correctAnswers,
      'tongcauhoi': instance.totalQuestions,
      'thoigianbatdau': instance.startTime.toIso8601String(),
      'thoigianketthuc': instance.endTime.toIso8601String(),
      'thoigianhoanthanh': instance.completedTime.toIso8601String(),
    };

ExamResultDetail _$ExamResultDetailFromJson(Map<String, dynamic> json) =>
    ExamResultDetail(
      resultId: (json['makq'] as num).toInt(),
      examId: (json['made'] as num).toInt(),
      examName: json['tende'] as String,
      studentId: json['manguoidung'] as String,
      studentName: json['hoten'] as String,
      score: (json['diem'] as num).toDouble(),
      correctAnswers: (json['socaudung'] as num).toInt(),
      totalQuestions: (json['tongcauhoi'] as num).toInt(),
      startTime: DateTime.parse(json['thoigianbatdau'] as String),
      endTime: DateTime.parse(json['thoigianketthuc'] as String),
      completedTime: DateTime.parse(json['thoigianhoanthanh'] as String),
      answerDetails: (json['chiTietTraLoi'] as List<dynamic>)
          .map((e) => StudentAnswerDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamResultDetailToJson(ExamResultDetail instance) =>
    <String, dynamic>{
      'makq': instance.resultId,
      'made': instance.examId,
      'tende': instance.examName,
      'manguoidung': instance.studentId,
      'hoten': instance.studentName,
      'diem': instance.score,
      'socaudung': instance.correctAnswers,
      'tongcauhoi': instance.totalQuestions,
      'thoigianbatdau': instance.startTime.toIso8601String(),
      'thoigianketthuc': instance.endTime.toIso8601String(),
      'thoigianhoanthanh': instance.completedTime.toIso8601String(),
      'chiTietTraLoi': instance.answerDetails,
    };

StudentAnswerDetail _$StudentAnswerDetailFromJson(Map<String, dynamic> json) =>
    StudentAnswerDetail(
      questionId: (json['macauhoi'] as num).toInt(),
      questionContent: json['noiDungCauHoi'] as String,
      selectedAnswerId: (json['macautraloichon'] as num?)?.toInt(),
      selectedAnswerContent: json['noiDungTraLoiChon'] as String?,
      correctAnswerId: (json['macautraloiDung'] as num).toInt(),
      correctAnswerContent: json['noiDungTraLoiDung'] as String,
      isCorrect: json['laDung'] as bool,
      answerTime: json['thoigiantraloi'] == null
          ? null
          : DateTime.parse(json['thoigiantraloi'] as String),
    );

Map<String, dynamic> _$StudentAnswerDetailToJson(
        StudentAnswerDetail instance) =>
    <String, dynamic>{
      'macauhoi': instance.questionId,
      'noiDungCauHoi': instance.questionContent,
      'macautraloichon': instance.selectedAnswerId,
      'noiDungTraLoiChon': instance.selectedAnswerContent,
      'macautraloiDung': instance.correctAnswerId,
      'noiDungTraLoiDung': instance.correctAnswerContent,
      'laDung': instance.isCorrect,
      'thoigiantraloi': instance.answerTime?.toIso8601String(),
    };

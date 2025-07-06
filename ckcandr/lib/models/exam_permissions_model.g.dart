// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_permissions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamPermissions _$ExamPermissionsFromJson(Map<String, dynamic> json) =>
    ExamPermissions(
      showExamPaper: json['hienthibailam'] as bool,
      showScore: json['xemdiemthi'] as bool,
      showAnswers: json['xemdapan'] as bool,
    );

Map<String, dynamic> _$ExamPermissionsToJson(ExamPermissions instance) =>
    <String, dynamic>{
      'hienthibailam': instance.showExamPaper,
      'xemdiemthi': instance.showScore,
      'xemdapan': instance.showAnswers,
    };

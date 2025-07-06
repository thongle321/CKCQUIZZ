// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStatistics _$DashboardStatisticsFromJson(Map<String, dynamic> json) =>
    DashboardStatistics(
      totalUsers: (json['totalUsers'] as num).toInt(),
      totalStudents: (json['totalStudents'] as num).toInt(),
      totalSubjects: (json['totalSubjects'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      totalExams: (json['totalExams'] as num).toInt(),
      activeExams: (json['activeExams'] as num).toInt(),
      completedExams: (json['completedExams'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatisticsToJson(
        DashboardStatistics instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'totalStudents': instance.totalStudents,
      'totalSubjects': instance.totalSubjects,
      'totalQuestions': instance.totalQuestions,
      'totalExams': instance.totalExams,
      'activeExams': instance.activeExams,
      'completedExams': instance.completedExams,
    };

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'dashboard_model.g.dart';

/// Model cho Dashboard Statistics từ API
@JsonSerializable()
class DashboardStatistics {
  @JsonKey(name: 'totalUsers')
  final int totalUsers;

  @JsonKey(name: 'totalStudents')
  final int totalStudents;

  @JsonKey(name: 'totalSubjects')
  final int totalSubjects;

  @JsonKey(name: 'totalQuestions')
  final int totalQuestions;

  @JsonKey(name: 'totalExams')
  final int totalExams;

  @JsonKey(name: 'activeExams')
  final int activeExams;

  @JsonKey(name: 'completedExams')
  final int completedExams;

  const DashboardStatistics({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalSubjects,
    required this.totalQuestions,
    required this.totalExams,
    required this.activeExams,
    required this.completedExams,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatisticsToJson(this);

  /// Empty state cho loading
  static const empty = DashboardStatistics(
    totalUsers: 0,
    totalStudents: 0,
    totalSubjects: 0,
    totalQuestions: 0,
    totalExams: 0,
    activeExams: 0,
    completedExams: 0,
  );
}

/// Model cho Dashboard Card Item
class DashboardCardItem {
  final String title;
  final String value;
  final String icon;
  final String color;
  final String? subtitle;
  final VoidCallback? onTap;

  const DashboardCardItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });
}

/// Model cho Quick Action Item
class QuickActionItem {
  final String title;
  final String icon;
  final String color;
  final VoidCallback onTap;
  final String? description;

  const QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.description,
  });
}

/// Model cho Recent Activity Item
class RecentActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final String type;
  final String? avatar;

  const RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    this.avatar,
  });
}

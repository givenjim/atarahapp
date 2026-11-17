// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReportDto _$UserReportDtoFromJson(Map<String, dynamic> json) =>
    UserReportDto(
      caseId: json['caseId'] as String,
      targetType: json['targetType'] as String,
      topReason: json['topReason'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      reportCount: json['reportCount'] as num,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserReportDtoToJson(UserReportDto instance) =>
    <String, dynamic>{
      'caseId': instance.caseId,
      'targetType': instance.targetType,
      'topReason': instance.topReason,
      'status': instance.status,
      'priority': instance.priority,
      'reportCount': instance.reportCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

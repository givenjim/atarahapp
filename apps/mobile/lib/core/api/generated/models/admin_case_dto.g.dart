// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_case_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCaseDto _$AdminCaseDtoFromJson(Map<String, dynamic> json) => AdminCaseDto(
  id: json['id'] as String,
  targetType: ReportTargetType.fromJson(json['targetType'] as String),
  targetId: json['targetId'] as String,
  status: ReportStatus.fromJson(json['status'] as String),
  priority: ModerationPriority.fromJson(json['priority'] as String),
  reportCount: json['reportCount'] as num,
  topReason: ReportReason.fromJson(json['topReason'] as String),
  assignee: json['assignee'] == null
      ? null
      : AdminPersonRefDto.fromJson(json['assignee'] as Map<String, dynamic>),
  author: json['author'] == null
      ? null
      : AdminPersonRefDto.fromJson(json['author'] as Map<String, dynamic>),
  preview: json['preview'] as String?,
  ageHours: json['ageHours'] as num,
  createdAt: DateTime.parse(json['createdAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
);

Map<String, dynamic> _$AdminCaseDtoToJson(AdminCaseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'status': instance.status,
      'priority': instance.priority,
      'reportCount': instance.reportCount,
      'topReason': instance.topReason,
      'assignee': instance.assignee,
      'author': instance.author,
      'preview': instance.preview,
      'ageHours': instance.ageHours,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

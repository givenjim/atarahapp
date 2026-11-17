// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_case_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCaseDetailDto _$AdminCaseDetailDtoFromJson(Map<String, dynamic> json) =>
    AdminCaseDetailDto(
      id: json['id'] as String,
      targetType: ReportTargetType.fromJson(json['targetType'] as String),
      targetId: json['targetId'] as String,
      status: ReportStatus.fromJson(json['status'] as String),
      priority: ModerationPriority.fromJson(json['priority'] as String),
      reportCount: json['reportCount'] as num,
      topReason: ReportReason.fromJson(json['topReason'] as String),
      assignee: json['assignee'] == null
          ? null
          : AdminPersonRefDto.fromJson(
              json['assignee'] as Map<String, dynamic>,
            ),
      author: json['author'] == null
          ? null
          : AdminPersonRefDto.fromJson(json['author'] as Map<String, dynamic>),
      preview: json['preview'] as String?,
      ageHours: json['ageHours'] as num,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      content: AdminCaseContentDto.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      reports: (json['reports'] as List<dynamic>)
          .map((e) => AdminCaseReportDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>)
          .map((e) => AdminCaseActionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      allowedActions: (json['allowedActions'] as List<dynamic>)
          .map((e) => ModerationAction.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$AdminCaseDetailDtoToJson(AdminCaseDetailDto instance) =>
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
      'content': instance.content,
      'reports': instance.reports,
      'history': instance.history,
      'allowedActions': instance.allowedActions,
    };

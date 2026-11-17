// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminReportDto _$AdminReportDtoFromJson(Map<String, dynamic> json) =>
    AdminReportDto(
      id: json['id'] as String,
      targetType: ReportTargetType.fromJson(json['targetType'] as String),
      targetId: json['targetId'] as String,
      reason: ReportReason.fromJson(json['reason'] as String),
      note: json['note'] as String?,
      status: ReportStatus.fromJson(json['status'] as String),
      caseId: json['caseId'] as String?,
      reporter: json['reporter'] == null
          ? null
          : AdminPersonRefDto.fromJson(
              json['reporter'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminReportDtoToJson(AdminReportDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'reason': instance.reason,
      'note': instance.note,
      'status': instance.status,
      'caseId': instance.caseId,
      'reporter': instance.reporter,
      'createdAt': instance.createdAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_case_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCaseReportDto _$AdminCaseReportDtoFromJson(Map<String, dynamic> json) =>
    AdminCaseReportDto(
      id: json['id'] as String,
      reason: ReportReason.fromJson(json['reason'] as String),
      note: json['note'] as String?,
      status: ReportStatus.fromJson(json['status'] as String),
      reporter: json['reporter'] == null
          ? null
          : AdminPersonRefDto.fromJson(
              json['reporter'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminCaseReportDtoToJson(AdminCaseReportDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
      'note': instance.note,
      'status': instance.status,
      'reporter': instance.reporter,
      'createdAt': instance.createdAt.toIso8601String(),
    };

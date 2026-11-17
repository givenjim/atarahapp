// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReportDto _$CreateReportDtoFromJson(Map<String, dynamic> json) =>
    CreateReportDto(
      targetType: ReportTargetType.fromJson(json['targetType'] as String),
      reason: ReportReason.fromJson(json['reason'] as String),
      targetId: json['targetId'] as String?,
      handle: json['handle'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CreateReportDtoToJson(CreateReportDto instance) =>
    <String, dynamic>{
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'handle': instance.handle,
      'reason': instance.reason,
      'note': instance.note,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyReportDto _$MyReportDtoFromJson(Map<String, dynamic> json) => MyReportDto(
  id: json['id'] as String,
  targetType: ReportTargetType.fromJson(json['targetType'] as String),
  reason: ReportReason.fromJson(json['reason'] as String),
  status: PublicReportStatus.fromJson(json['status'] as String),
  outcome: json['outcome'] == null
      ? null
      : MyReportDtoOutcome.fromJson(json['outcome'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
);

Map<String, dynamic> _$MyReportDtoToJson(MyReportDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetType': instance.targetType,
      'reason': instance.reason,
      'status': instance.status,
      'outcome': instance.outcome,
      'createdAt': instance.createdAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
    };

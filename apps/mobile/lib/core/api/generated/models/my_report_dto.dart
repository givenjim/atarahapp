// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_report_dto_outcome.dart';
import 'public_report_status.dart';
import 'report_reason.dart';
import 'report_target_type.dart';

part 'my_report_dto.g.dart';

@JsonSerializable()
class MyReportDto {
  const MyReportDto({
    required this.id,
    required this.targetType,
    required this.reason,
    required this.status,
    required this.outcome,
    required this.createdAt,
    required this.reviewedAt,
  });
  
  factory MyReportDto.fromJson(Map<String, Object?> json) => _$MyReportDtoFromJson(json);
  
  final String id;
  final ReportTargetType targetType;
  final ReportReason reason;

  /// What a reporter may know. Who decided, how and why stays internal.
  final PublicReportStatus status;

  /// Only once reviewed.
  final MyReportDtoOutcome? outcome;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  Map<String, Object?> toJson() => _$MyReportDtoToJson(this);
}

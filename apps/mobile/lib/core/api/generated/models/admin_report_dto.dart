// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_person_ref_dto.dart';
import 'report_reason.dart';
import 'report_status.dart';
import 'report_target_type.dart';

part 'admin_report_dto.g.dart';

@JsonSerializable()
class AdminReportDto {
  const AdminReportDto({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.note,
    required this.status,
    required this.caseId,
    required this.reporter,
    required this.createdAt,
  });
  
  factory AdminReportDto.fromJson(Map<String, Object?> json) => _$AdminReportDtoFromJson(json);
  
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final ReportReason reason;
  final String? note;
  final ReportStatus status;
  final String? caseId;
  final AdminPersonRefDto? reporter;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminReportDtoToJson(this);
}

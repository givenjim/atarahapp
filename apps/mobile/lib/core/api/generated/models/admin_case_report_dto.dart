// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_person_ref_dto.dart';
import 'report_reason.dart';
import 'report_status.dart';

part 'admin_case_report_dto.g.dart';

@JsonSerializable()
class AdminCaseReportDto {
  const AdminCaseReportDto({
    required this.id,
    required this.reason,
    required this.note,
    required this.status,
    required this.reporter,
    required this.createdAt,
  });

  factory AdminCaseReportDto.fromJson(Map<String, Object?> json) =>
      _$AdminCaseReportDtoFromJson(json);

  final String id;
  final ReportReason reason;
  final String? note;
  final ReportStatus status;
  final AdminPersonRefDto? reporter;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminCaseReportDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_case_action_dto.dart';
import 'admin_case_content_dto.dart';
import 'admin_case_report_dto.dart';
import 'admin_person_ref_dto.dart';
import 'moderation_action.dart';
import 'moderation_priority.dart';
import 'report_reason.dart';
import 'report_status.dart';
import 'report_target_type.dart';

part 'admin_case_detail_dto.g.dart';

@JsonSerializable()
class AdminCaseDetailDto {
  const AdminCaseDetailDto({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.status,
    required this.priority,
    required this.reportCount,
    required this.topReason,
    required this.assignee,
    required this.author,
    required this.preview,
    required this.ageHours,
    required this.createdAt,
    required this.resolvedAt,
    required this.content,
    required this.reports,
    required this.history,
    required this.allowedActions,
  });

  factory AdminCaseDetailDto.fromJson(Map<String, Object?> json) =>
      _$AdminCaseDetailDtoFromJson(json);

  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final ReportStatus status;
  final ModerationPriority priority;
  final num reportCount;
  final ReportReason topReason;
  final AdminPersonRefDto? assignee;

  /// Whose content or account is reported.
  final AdminPersonRefDto? author;

  /// A short excerpt of what was reported.
  final String? preview;

  /// Hours since the first report.
  final num ageHours;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final AdminCaseContentDto content;
  final List<AdminCaseReportDto> reports;

  /// Oldest first. Append-only.
  final List<AdminCaseActionDto> history;

  /// The decisions that make sense for this kind of target.
  final List<ModerationAction> allowedActions;

  Map<String, Object?> toJson() => _$AdminCaseDetailDtoToJson(this);
}

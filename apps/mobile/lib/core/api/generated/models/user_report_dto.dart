// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_report_dto.g.dart';

@JsonSerializable()
class UserReportDto {
  const UserReportDto({
    required this.caseId,
    required this.targetType,
    required this.topReason,
    required this.status,
    required this.priority,
    required this.reportCount,
    required this.createdAt,
  });
  
  factory UserReportDto.fromJson(Map<String, Object?> json) => _$UserReportDtoFromJson(json);
  
  final String caseId;
  final String targetType;
  final String topReason;
  final String status;
  final String priority;
  final num reportCount;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$UserReportDtoToJson(this);
}

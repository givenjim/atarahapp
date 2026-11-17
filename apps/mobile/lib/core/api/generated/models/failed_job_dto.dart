// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'failed_job_dto.g.dart';

@JsonSerializable()
class FailedJobDto {
  const FailedJobDto({
    required this.id,
    required this.name,
    required this.failedReason,
    required this.attemptsMade,
    this.failedAt,
  });

  factory FailedJobDto.fromJson(Map<String, Object?> json) =>
      _$FailedJobDtoFromJson(json);

  final String id;
  final String name;
  final String failedReason;
  final num attemptsMade;
  final DateTime? failedAt;

  Map<String, Object?> toJson() => _$FailedJobDtoToJson(this);
}

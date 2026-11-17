// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'progress_override_dto_action.dart';

part 'progress_override_dto.g.dart';

@JsonSerializable()
class ProgressOverrideDto {
  const ProgressOverrideDto({
    required this.userId,
    required this.courseId,
    required this.action,
    required this.reason,
    this.lessonId,
  });

  factory ProgressOverrideDto.fromJson(Map<String, Object?> json) =>
      _$ProgressOverrideDtoFromJson(json);

  final String userId;

  /// The course (learning content id).
  final String courseId;

  /// Required for the lesson actions.
  final String? lessonId;
  final ProgressOverrideDtoAction action;

  /// Why. Kept with the audit entry.
  final String reason;

  Map<String, Object?> toJson() => _$ProgressOverrideDtoToJson(this);
}

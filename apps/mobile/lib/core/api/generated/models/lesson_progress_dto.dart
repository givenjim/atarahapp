// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_progress_status.dart';

part 'lesson_progress_dto.g.dart';

@JsonSerializable()
class LessonProgressDto {
  const LessonProgressDto({
    required this.status,
    required this.lastPositionSeconds,
    this.completedAt,
  });

  factory LessonProgressDto.fromJson(Map<String, Object?> json) =>
      _$LessonProgressDtoFromJson(json);

  final LessonProgressStatus status;
  final num lastPositionSeconds;
  final DateTime? completedAt;

  Map<String, Object?> toJson() => _$LessonProgressDtoToJson(this);
}

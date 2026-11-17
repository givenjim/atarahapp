// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'lesson_progress_body_dto.g.dart';

@JsonSerializable()
class LessonProgressBodyDto {
  const LessonProgressBodyDto({
    this.positionSeconds,
    this.completed,
    this.restart,
  });

  factory LessonProgressBodyDto.fromJson(Map<String, Object?> json) =>
      _$LessonProgressBodyDtoFromJson(json);

  /// Where the member has got to, in seconds. Only ever moves forward.
  final num? positionSeconds;

  /// Mark the lesson complete (set once; repeating it changes nothing).
  final bool? completed;

  /// Start the lesson over: position back to zero, not completed.
  final bool? restart;

  Map<String, Object?> toJson() => _$LessonProgressBodyDtoToJson(this);
}

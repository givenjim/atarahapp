// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_progress_status.dart';

part 'learning_item_progress_dto.g.dart';

@JsonSerializable()
class LearningItemProgressDto {
  const LearningItemProgressDto({
    required this.status,
    required this.percent,
  });
  
  factory LearningItemProgressDto.fromJson(Map<String, Object?> json) => _$LearningItemProgressDtoFromJson(json);
  
  final LessonProgressStatus status;

  /// 0 to 100. For a course, completed lessons over all lessons.
  final num percent;

  Map<String, Object?> toJson() => _$LearningItemProgressDtoToJson(this);
}

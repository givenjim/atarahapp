// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_summary_dto_state.dart';

part 'lesson_summary_dto.g.dart';

@JsonSerializable()
class LessonSummaryDto {
  const LessonSummaryDto({
    required this.id,
    required this.sequence,
    required this.title,
    required this.durationMinutes,
    required this.state,
    required this.hasVideo,
    required this.hasEmbed,
  });
  
  factory LessonSummaryDto.fromJson(Map<String, Object?> json) => _$LessonSummaryDtoFromJson(json);
  
  final String id;
  final num sequence;
  final String title;
  final num durationMinutes;
  final LessonSummaryDtoState state;
  final bool hasVideo;
  final bool hasEmbed;

  Map<String, Object?> toJson() => _$LessonSummaryDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_dto.dart';
import 'lesson_dto_state.dart';
import 'lesson_progress_dto.dart';
import 'practice_dto.dart';

part 'lesson_dto.g.dart';

@JsonSerializable()
class LessonDto {
  const LessonDto({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.sequence,
    required this.lessonCount,
    required this.title,
    required this.durationMinutes,
    required this.body,
    required this.hasVideo,
    required this.progress,
    required this.state,
    required this.segments,
    this.practice,
    this.embedUrl,
    this.previousLessonId,
    this.nextLessonId,
  });

  factory LessonDto.fromJson(Map<String, Object?> json) =>
      _$LessonDtoFromJson(json);

  final String id;
  final String courseId;
  final String courseTitle;
  final num sequence;
  final num lessonCount;
  final String title;
  final num durationMinutes;
  final List<ArticleBlockDto> body;
  final PracticeDto? practice;

  /// Uploaded video: fetch the address from the video endpoint.
  final bool hasVideo;

  /// Embedded player address (allow-listed host).
  final String? embedUrl;
  final LessonProgressDto progress;
  final LessonDtoState state;
  final String? previousLessonId;
  final String? nextLessonId;

  /// One flag per lesson of the course (7-segment progress bar): completed or not.
  final List<bool> segments;

  Map<String, Object?> toJson() => _$LessonDtoToJson(this);
}

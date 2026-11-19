// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'certificate_dto.dart';
import 'lesson_progress_dto.dart';

part 'progress_result_dto.g.dart';

@JsonSerializable()
class ProgressResultDto {
  const ProgressResultDto({
    required this.progress,
    required this.courseCompleted,
    required this.percent,
    this.nextLessonId,
    this.certificate,
  });
  
  factory ProgressResultDto.fromJson(Map<String, Object?> json) => _$ProgressResultDtoFromJson(json);
  
  final LessonProgressDto progress;
  final bool courseCompleted;
  final num percent;
  final String? nextLessonId;

  /// Set when this write completed the course.
  final CertificateDto? certificate;

  Map<String, Object?> toJson() => _$ProgressResultDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'certificate_dto.dart';
import 'lesson_summary_dto.dart';

part 'course_info_dto.g.dart';

@JsonSerializable()
class CourseInfoDto {
  const CourseInfoDto({
    required this.lessonCount,
    required this.totalMinutes,
    required this.sequential,
    required this.enrolled,
    required this.completedLessons,
    required this.percent,
    required this.lessons,
    this.nextLessonId,
    this.certificate,
  });

  factory CourseInfoDto.fromJson(Map<String, Object?> json) =>
      _$CourseInfoDtoFromJson(json);

  final num lessonCount;
  final num totalMinutes;
  final bool sequential;
  final bool enrolled;
  final num completedLessons;
  final num percent;

  /// The lesson "Continue learning" opens.
  final String? nextLessonId;
  final List<LessonSummaryDto> lessons;
  final CertificateDto? certificate;

  Map<String, Object?> toJson() => _$CourseInfoDtoToJson(this);
}

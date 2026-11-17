// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'enrolment_dto.g.dart';

@JsonSerializable()
class EnrolmentDto {
  const EnrolmentDto({
    required this.courseId,
    required this.enrolledAt,
    this.nextLessonId,
  });

  factory EnrolmentDto.fromJson(Map<String, Object?> json) =>
      _$EnrolmentDtoFromJson(json);

  final String courseId;
  final DateTime enrolledAt;
  final String? nextLessonId;

  Map<String, Object?> toJson() => _$EnrolmentDtoToJson(this);
}

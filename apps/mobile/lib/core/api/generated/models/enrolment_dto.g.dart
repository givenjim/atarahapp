// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrolment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnrolmentDto _$EnrolmentDtoFromJson(Map<String, dynamic> json) => EnrolmentDto(
  courseId: json['courseId'] as String,
  enrolledAt: DateTime.parse(json['enrolledAt'] as String),
  nextLessonId: json['nextLessonId'] as String?,
);

Map<String, dynamic> _$EnrolmentDtoToJson(EnrolmentDto instance) =>
    <String, dynamic>{
      'courseId': instance.courseId,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'nextLessonId': instance.nextLessonId,
    };

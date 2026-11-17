// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseInfoDto _$CourseInfoDtoFromJson(Map<String, dynamic> json) =>
    CourseInfoDto(
      lessonCount: json['lessonCount'] as num,
      totalMinutes: json['totalMinutes'] as num,
      sequential: json['sequential'] as bool,
      enrolled: json['enrolled'] as bool,
      completedLessons: json['completedLessons'] as num,
      percent: json['percent'] as num,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => LessonSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextLessonId: json['nextLessonId'] as String?,
      certificate: json['certificate'] == null
          ? null
          : CertificateDto.fromJson(
              json['certificate'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CourseInfoDtoToJson(CourseInfoDto instance) =>
    <String, dynamic>{
      'lessonCount': instance.lessonCount,
      'totalMinutes': instance.totalMinutes,
      'sequential': instance.sequential,
      'enrolled': instance.enrolled,
      'completedLessons': instance.completedLessons,
      'percent': instance.percent,
      'nextLessonId': instance.nextLessonId,
      'lessons': instance.lessons,
      'certificate': instance.certificate,
    };

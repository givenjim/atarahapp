// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressResultDto _$ProgressResultDtoFromJson(Map<String, dynamic> json) =>
    ProgressResultDto(
      progress: LessonProgressDto.fromJson(
        json['progress'] as Map<String, dynamic>,
      ),
      courseCompleted: json['courseCompleted'] as bool,
      percent: json['percent'] as num,
      nextLessonId: json['nextLessonId'] as String?,
      certificate: json['certificate'] == null
          ? null
          : CertificateDto.fromJson(
              json['certificate'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ProgressResultDtoToJson(ProgressResultDto instance) =>
    <String, dynamic>{
      'progress': instance.progress,
      'courseCompleted': instance.courseCompleted,
      'percent': instance.percent,
      'nextLessonId': instance.nextLessonId,
      'certificate': instance.certificate,
    };

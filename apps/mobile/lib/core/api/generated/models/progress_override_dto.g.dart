// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_override_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressOverrideDto _$ProgressOverrideDtoFromJson(Map<String, dynamic> json) =>
    ProgressOverrideDto(
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      action: ProgressOverrideDtoAction.fromJson(json['action'] as String),
      reason: json['reason'] as String,
      lessonId: json['lessonId'] as String?,
    );

Map<String, dynamic> _$ProgressOverrideDtoToJson(
  ProgressOverrideDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'courseId': instance.courseId,
  'lessonId': instance.lessonId,
  'action': instance.action,
  'reason': instance.reason,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_item_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningItemProgressDto _$LearningItemProgressDtoFromJson(
  Map<String, dynamic> json,
) => LearningItemProgressDto(
  status: LessonProgressStatus.fromJson(json['status'] as String),
  percent: json['percent'] as num,
);

Map<String, dynamic> _$LearningItemProgressDtoToJson(
  LearningItemProgressDto instance,
) => <String, dynamic>{'status': instance.status, 'percent': instance.percent};

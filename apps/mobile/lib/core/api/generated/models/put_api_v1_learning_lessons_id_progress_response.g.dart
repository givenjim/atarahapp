// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_learning_lessons_id_progress_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1LearningLessonsIdProgressResponse
_$PutApiV1LearningLessonsIdProgressResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1LearningLessonsIdProgressResponse(
  data: ProgressResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1LearningLessonsIdProgressResponseToJson(
  PutApiV1LearningLessonsIdProgressResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

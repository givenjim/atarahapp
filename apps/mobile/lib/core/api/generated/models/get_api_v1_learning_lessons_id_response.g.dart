// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_learning_lessons_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LearningLessonsIdResponse _$GetApiV1LearningLessonsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LearningLessonsIdResponse(
  data: LessonDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LearningLessonsIdResponseToJson(
  GetApiV1LearningLessonsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

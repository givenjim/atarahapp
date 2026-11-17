// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_learning_lessons_id_video_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LearningLessonsIdVideoResponse
_$GetApiV1LearningLessonsIdVideoResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1LearningLessonsIdVideoResponse(
      data: LessonVideoDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1LearningLessonsIdVideoResponseToJson(
  GetApiV1LearningLessonsIdVideoResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

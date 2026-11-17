// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_learning_id_start_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1LearningIdStartResponse _$PostApiV1LearningIdStartResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1LearningIdStartResponse(
  data: LearningItemProgressDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1LearningIdStartResponseToJson(
  PostApiV1LearningIdStartResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

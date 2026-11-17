// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_learning_contents_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLearningContentsResponse
_$PostApiV1AdminLearningContentsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminLearningContentsResponse(
      data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminLearningContentsResponseToJson(
  PostApiV1AdminLearningContentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

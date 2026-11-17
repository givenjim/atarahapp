// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_learning_contents_id_publish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLearningContentsIdPublishResponse
_$PostApiV1AdminLearningContentsIdPublishResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminLearningContentsIdPublishResponse(
  data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminLearningContentsIdPublishResponseToJson(
  PostApiV1AdminLearningContentsIdPublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

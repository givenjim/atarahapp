// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_learning_contents_id_unpublish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLearningContentsIdUnpublishResponse
_$PostApiV1AdminLearningContentsIdUnpublishResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminLearningContentsIdUnpublishResponse(
  data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminLearningContentsIdUnpublishResponseToJson(
  PostApiV1AdminLearningContentsIdUnpublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

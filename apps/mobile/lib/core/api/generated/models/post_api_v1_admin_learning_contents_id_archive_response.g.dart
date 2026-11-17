// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_learning_contents_id_archive_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLearningContentsIdArchiveResponse
_$PostApiV1AdminLearningContentsIdArchiveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminLearningContentsIdArchiveResponse(
  data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminLearningContentsIdArchiveResponseToJson(
  PostApiV1AdminLearningContentsIdArchiveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

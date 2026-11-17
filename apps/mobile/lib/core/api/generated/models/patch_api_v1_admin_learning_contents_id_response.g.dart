// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_learning_contents_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminLearningContentsIdResponse
_$PatchApiV1AdminLearningContentsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminLearningContentsIdResponse(
  data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminLearningContentsIdResponseToJson(
  PatchApiV1AdminLearningContentsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

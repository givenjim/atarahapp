// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_posts_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1PostsIdResponse _$PatchApiV1PostsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1PostsIdResponse(
  data: PostViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1PostsIdResponseToJson(
  PatchApiV1PostsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

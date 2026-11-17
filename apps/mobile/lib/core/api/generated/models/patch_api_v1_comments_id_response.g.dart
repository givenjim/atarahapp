// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_comments_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1CommentsIdResponse _$PatchApiV1CommentsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1CommentsIdResponse(
  data: CommentViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1CommentsIdResponseToJson(
  PatchApiV1CommentsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

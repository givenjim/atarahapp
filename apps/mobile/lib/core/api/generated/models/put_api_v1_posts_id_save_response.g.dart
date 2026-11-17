// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_posts_id_save_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1PostsIdSaveResponse _$PutApiV1PostsIdSaveResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1PostsIdSaveResponse(
  data: SavedStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1PostsIdSaveResponseToJson(
  PutApiV1PostsIdSaveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

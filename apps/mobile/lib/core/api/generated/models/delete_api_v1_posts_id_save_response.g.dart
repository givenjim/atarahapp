// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_posts_id_save_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1PostsIdSaveResponse _$DeleteApiV1PostsIdSaveResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1PostsIdSaveResponse(
  data: SavedStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1PostsIdSaveResponseToJson(
  DeleteApiV1PostsIdSaveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

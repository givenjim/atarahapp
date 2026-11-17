// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_posts_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1PostsIdResponse _$GetApiV1PostsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1PostsIdResponse(
  data: PostViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1PostsIdResponseToJson(
  GetApiV1PostsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

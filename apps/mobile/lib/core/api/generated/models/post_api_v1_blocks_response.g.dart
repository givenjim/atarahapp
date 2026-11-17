// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_blocks_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1BlocksResponse _$PostApiV1BlocksResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1BlocksResponse(
  data: BlockedMemberDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1BlocksResponseToJson(
  PostApiV1BlocksResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

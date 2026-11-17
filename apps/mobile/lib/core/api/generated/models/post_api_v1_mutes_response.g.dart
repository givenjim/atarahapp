// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_mutes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MutesResponse _$PostApiV1MutesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MutesResponse(
  data: MuteStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MutesResponseToJson(
  PostApiV1MutesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

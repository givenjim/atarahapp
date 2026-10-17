// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_media_id_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MediaIdCompleteResponse _$PostApiV1MediaIdCompleteResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MediaIdCompleteResponse(
  data: MediaAssetDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MediaIdCompleteResponseToJson(
  PostApiV1MediaIdCompleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

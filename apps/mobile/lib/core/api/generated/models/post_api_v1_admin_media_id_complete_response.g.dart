// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_media_id_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMediaIdCompleteResponse
_$PostApiV1AdminMediaIdCompleteResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminMediaIdCompleteResponse(
      data: MediaAssetDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminMediaIdCompleteResponseToJson(
  PostApiV1AdminMediaIdCompleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

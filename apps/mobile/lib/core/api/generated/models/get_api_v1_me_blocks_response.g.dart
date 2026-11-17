// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_blocks_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeBlocksResponse _$GetApiV1MeBlocksResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeBlocksResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => BlockedMemberDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeBlocksResponseToJson(
  GetApiV1MeBlocksResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

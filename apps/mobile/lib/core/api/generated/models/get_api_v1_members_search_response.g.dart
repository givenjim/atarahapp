// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_members_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MembersSearchResponse _$GetApiV1MembersSearchResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MembersSearchResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => MemberHitDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MembersSearchResponseToJson(
  GetApiV1MembersSearchResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

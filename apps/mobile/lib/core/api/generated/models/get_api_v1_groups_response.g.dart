// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1GroupsResponse _$GetApiV1GroupsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1GroupsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => GroupCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1GroupsResponseToJson(
  GetApiV1GroupsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

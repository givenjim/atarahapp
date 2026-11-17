// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminGroupsResponse _$GetApiV1AdminGroupsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminGroupsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminGroupDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminGroupsResponseToJson(
  GetApiV1AdminGroupsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_groups_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminGroupsIdResponse _$GetApiV1AdminGroupsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminGroupsIdResponse(
  data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminGroupsIdResponseToJson(
  GetApiV1AdminGroupsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

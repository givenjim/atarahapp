// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_admin_groups_id_pins_post_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1AdminGroupsIdPinsPostIdResponse
_$DeleteApiV1AdminGroupsIdPinsPostIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1AdminGroupsIdPinsPostIdResponse(
  data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1AdminGroupsIdPinsPostIdResponseToJson(
  DeleteApiV1AdminGroupsIdPinsPostIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

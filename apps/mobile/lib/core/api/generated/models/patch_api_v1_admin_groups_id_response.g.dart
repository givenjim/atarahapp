// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_groups_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminGroupsIdResponse _$PatchApiV1AdminGroupsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminGroupsIdResponse(
  data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminGroupsIdResponseToJson(
  PatchApiV1AdminGroupsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

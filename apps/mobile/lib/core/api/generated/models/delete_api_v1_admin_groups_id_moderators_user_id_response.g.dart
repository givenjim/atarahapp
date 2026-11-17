// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_admin_groups_id_moderators_user_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1AdminGroupsIdModeratorsUserIdResponse
_$DeleteApiV1AdminGroupsIdModeratorsUserIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1AdminGroupsIdModeratorsUserIdResponse(
  data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1AdminGroupsIdModeratorsUserIdResponseToJson(
  DeleteApiV1AdminGroupsIdModeratorsUserIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

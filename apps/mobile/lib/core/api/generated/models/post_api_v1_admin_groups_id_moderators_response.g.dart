// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_groups_id_moderators_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminGroupsIdModeratorsResponse
_$PostApiV1AdminGroupsIdModeratorsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminGroupsIdModeratorsResponse(
      data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminGroupsIdModeratorsResponseToJson(
  PostApiV1AdminGroupsIdModeratorsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminGroupsResponse _$PostApiV1AdminGroupsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminGroupsResponse(
  data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminGroupsResponseToJson(
  PostApiV1AdminGroupsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

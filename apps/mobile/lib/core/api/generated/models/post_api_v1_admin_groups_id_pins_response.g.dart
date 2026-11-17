// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_groups_id_pins_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminGroupsIdPinsResponse _$PostApiV1AdminGroupsIdPinsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminGroupsIdPinsResponse(
  data: AdminGroupDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminGroupsIdPinsResponseToJson(
  PostApiV1AdminGroupsIdPinsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

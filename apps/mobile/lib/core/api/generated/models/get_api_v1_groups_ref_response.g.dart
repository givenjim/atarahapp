// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_groups_ref_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1GroupsRefResponse _$GetApiV1GroupsRefResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1GroupsRefResponse(
  data: GroupDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1GroupsRefResponseToJson(
  GetApiV1GroupsRefResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

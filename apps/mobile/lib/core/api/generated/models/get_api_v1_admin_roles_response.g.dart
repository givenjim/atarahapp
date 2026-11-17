// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_roles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminRolesResponse _$GetApiV1AdminRolesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminRolesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => RoleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminRolesResponseToJson(
  GetApiV1AdminRolesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

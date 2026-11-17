// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_users_id_roles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminUsersIdRolesResponse _$PostApiV1AdminUsersIdRolesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminUsersIdRolesResponse(
  data: AdminUserDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminUsersIdRolesResponseToJson(
  PostApiV1AdminUsersIdRolesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

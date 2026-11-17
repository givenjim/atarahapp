// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_admin_users_id_roles_role_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1AdminUsersIdRolesRoleResponse
_$DeleteApiV1AdminUsersIdRolesRoleResponseFromJson(Map<String, dynamic> json) =>
    DeleteApiV1AdminUsersIdRolesRoleResponse(
      data: AdminUserDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$DeleteApiV1AdminUsersIdRolesRoleResponseToJson(
  DeleteApiV1AdminUsersIdRolesRoleResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

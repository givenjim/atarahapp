// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto.dart';

part 'delete_api_v1_admin_users_id_roles_role_response.g.dart';

@JsonSerializable()
class DeleteApiV1AdminUsersIdRolesRoleResponse {
  const DeleteApiV1AdminUsersIdRolesRoleResponse({
    required this.data,
    this.meta,
  });
  
  factory DeleteApiV1AdminUsersIdRolesRoleResponse.fromJson(Map<String, Object?> json) => _$DeleteApiV1AdminUsersIdRolesRoleResponseFromJson(json);
  
  final AdminUserDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1AdminUsersIdRolesRoleResponseToJson(this);
}

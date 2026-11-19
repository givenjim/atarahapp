// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto.dart';

part 'post_api_v1_admin_users_id_roles_response.g.dart';

@JsonSerializable()
class PostApiV1AdminUsersIdRolesResponse {
  const PostApiV1AdminUsersIdRolesResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminUsersIdRolesResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminUsersIdRolesResponseFromJson(json);
  
  final AdminUserDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminUsersIdRolesResponseToJson(this);
}

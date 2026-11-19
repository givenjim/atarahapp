// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role_dto.dart';

part 'get_api_v1_admin_roles_response.g.dart';

@JsonSerializable()
class GetApiV1AdminRolesResponse {
  const GetApiV1AdminRolesResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminRolesResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminRolesResponseFromJson(json);
  
  final List<RoleDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminRolesResponseToJson(this);
}

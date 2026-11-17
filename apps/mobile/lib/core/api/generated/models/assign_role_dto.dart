// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role_key.dart';

part 'assign_role_dto.g.dart';

@JsonSerializable()
class AssignRoleDto {
  const AssignRoleDto({required this.role, this.reason});

  factory AssignRoleDto.fromJson(Map<String, Object?> json) =>
      _$AssignRoleDtoFromJson(json);

  final RoleKey role;

  /// Why. Kept in the audit log.
  final String? reason;

  Map<String, Object?> toJson() => _$AssignRoleDtoToJson(this);
}

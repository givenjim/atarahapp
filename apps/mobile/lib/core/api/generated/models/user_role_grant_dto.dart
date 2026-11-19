// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role_key.dart';

part 'user_role_grant_dto.g.dart';

@JsonSerializable()
class UserRoleGrantDto {
  const UserRoleGrantDto({
    required this.key,
    required this.name,
    required this.isStaff,
    required this.grantedAt,
    this.grantedBy,
  });
  
  factory UserRoleGrantDto.fromJson(Map<String, Object?> json) => _$UserRoleGrantDtoFromJson(json);
  
  final RoleKey key;
  final String name;
  final bool isStaff;
  final DateTime grantedAt;

  /// Name of whoever granted it.
  final String? grantedBy;

  Map<String, Object?> toJson() => _$UserRoleGrantDtoToJson(this);
}

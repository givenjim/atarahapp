// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role_key.dart';

part 'role_dto.g.dart';

@JsonSerializable()
class RoleDto {
  const RoleDto({
    required this.key,
    required this.name,
    required this.description,
    required this.isStaff,
    required this.permissions,
  });
  
  factory RoleDto.fromJson(Map<String, Object?> json) => _$RoleDtoFromJson(json);
  
  final RoleKey key;
  final String name;
  final String description;

  /// Administrative roles need an authenticator code and a super admin to assign.
  final bool isStaff;
  final List<String> permissions;

  Map<String, Object?> toJson() => _$RoleDtoToJson(this);
}

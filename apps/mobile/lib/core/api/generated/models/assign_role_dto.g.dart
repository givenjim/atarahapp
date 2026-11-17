// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_role_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignRoleDto _$AssignRoleDtoFromJson(Map<String, dynamic> json) =>
    AssignRoleDto(
      role: RoleKey.fromJson(json['role'] as String),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$AssignRoleDtoToJson(AssignRoleDto instance) =>
    <String, dynamic>{'role': instance.role, 'reason': instance.reason};

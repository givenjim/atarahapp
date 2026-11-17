// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_grant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRoleGrantDto _$UserRoleGrantDtoFromJson(Map<String, dynamic> json) =>
    UserRoleGrantDto(
      key: RoleKey.fromJson(json['key'] as String),
      name: json['name'] as String,
      isStaff: json['isStaff'] as bool,
      grantedAt: DateTime.parse(json['grantedAt'] as String),
      grantedBy: json['grantedBy'] as String?,
    );

Map<String, dynamic> _$UserRoleGrantDtoToJson(UserRoleGrantDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'isStaff': instance.isStaff,
      'grantedAt': instance.grantedAt.toIso8601String(),
      'grantedBy': instance.grantedBy,
    };

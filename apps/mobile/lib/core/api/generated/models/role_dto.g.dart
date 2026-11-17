// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleDto _$RoleDtoFromJson(Map<String, dynamic> json) => RoleDto(
  key: RoleKey.fromJson(json['key'] as String),
  name: json['name'] as String,
  description: json['description'] as String,
  isStaff: json['isStaff'] as bool,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RoleDtoToJson(RoleDto instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'description': instance.description,
  'isStaff': instance.isStaff,
  'permissions': instance.permissions,
};

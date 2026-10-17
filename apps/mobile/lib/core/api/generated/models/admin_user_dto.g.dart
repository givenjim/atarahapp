// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserDto _$AdminUserDtoFromJson(Map<String, dynamic> json) => AdminUserDto(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  status: AdminUserDtoStatus.fromJson(json['status'] as String),
  statusReason: json['statusReason'] as String?,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AdminUserDtoToJson(AdminUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'status': instance.status,
      'statusReason': instance.statusReason,
      'roles': instance.roles,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

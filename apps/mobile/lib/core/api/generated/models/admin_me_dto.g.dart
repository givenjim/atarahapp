// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_me_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminMeDto _$AdminMeDtoFromJson(Map<String, dynamic> json) => AdminMeDto(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  emailVerified: json['emailVerified'] as bool,
  phoneVerified: json['phoneVerified'] as bool,
  status: AdminMeDtoStatus.fromJson(json['status'] as String),
  timeZone: json['timeZone'] as String,
  locale: json['locale'] as String,
  roles: (json['roles'] as List<dynamic>)
      .map((e) => AdminMeDtoRoles.fromJson(e as String))
      .toList(),
  entitlements: (json['entitlements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  membership: MembershipSummaryDto.fromJson(
    json['membership'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AdminMeDtoToJson(AdminMeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'status': instance.status,
      'timeZone': instance.timeZone,
      'locale': instance.locale,
      'roles': instance.roles,
      'entitlements': instance.entitlements,
      'membership': instance.membership,
      'createdAt': instance.createdAt.toIso8601String(),
      'permissions': instance.permissions,
    };

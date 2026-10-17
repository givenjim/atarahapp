// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAuthSessionDto _$AdminAuthSessionDtoFromJson(Map<String, dynamic> json) =>
    AdminAuthSessionDto(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt'] as String,
      ),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.parse(
        json['refreshTokenExpiresAt'] as String,
      ),
      user: MeDto.fromJson(json['user'] as Map<String, dynamic>),
      recoveryCodes: (json['recoveryCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AdminAuthSessionDtoToJson(
  AdminAuthSessionDto instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'accessTokenExpiresAt': instance.accessTokenExpiresAt.toIso8601String(),
  'refreshToken': instance.refreshToken,
  'refreshTokenExpiresAt': instance.refreshTokenExpiresAt.toIso8601String(),
  'user': instance.user,
  'recoveryCodes': instance.recoveryCodes,
};

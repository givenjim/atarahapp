// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSessionDto _$UserSessionDtoFromJson(Map<String, dynamic> json) =>
    UserSessionDto(
      id: json['id'] as String,
      client: json['client'] as String,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$UserSessionDtoToJson(UserSessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client': instance.client,
      'deviceName': instance.deviceName,
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
    };

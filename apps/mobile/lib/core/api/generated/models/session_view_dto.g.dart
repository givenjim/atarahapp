// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_view_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionViewDto _$SessionViewDtoFromJson(Map<String, dynamic> json) =>
    SessionViewDto(
      id: json['id'] as String,
      client: SessionViewDtoClient.fromJson(json['client'] as String),
      deviceName: json['deviceName'] as String?,
      approxLocation: json['approxLocation'] as String?,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      current: json['current'] as bool,
    );

Map<String, dynamic> _$SessionViewDtoToJson(SessionViewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client': instance.client,
      'deviceName': instance.deviceName,
      'approxLocation': instance.approxLocation,
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
      'current': instance.current,
    };

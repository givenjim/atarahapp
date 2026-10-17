// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reauth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReauthDto _$ReauthDtoFromJson(Map<String, dynamic> json) => ReauthDto(
  reauthenticatedUntil: DateTime.parse(json['reauthenticatedUntil'] as String),
);

Map<String, dynamic> _$ReauthDtoToJson(ReauthDto instance) => <String, dynamic>{
  'reauthenticatedUntil': instance.reauthenticatedUntil.toIso8601String(),
};

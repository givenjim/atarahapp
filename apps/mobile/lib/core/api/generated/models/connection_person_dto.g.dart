// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_person_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionPersonDto _$ConnectionPersonDtoFromJson(Map<String, dynamic> json) =>
    ConnectionPersonDto(
      handle: json['handle'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      headline: json['headline'] as String?,
      discipline: json['discipline'] as String?,
    );

Map<String, dynamic> _$ConnectionPersonDtoToJson(
  ConnectionPersonDto instance,
) => <String, dynamic>{
  'handle': instance.handle,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'headline': instance.headline,
  'discipline': instance.discipline,
};

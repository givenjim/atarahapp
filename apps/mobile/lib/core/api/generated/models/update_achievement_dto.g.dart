// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_achievement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAchievementDto _$UpdateAchievementDtoFromJson(
  Map<String, dynamic> json,
) => UpdateAchievementDto(
  type: json['type'] == null
      ? null
      : UpdateAchievementDtoType.fromJson(json['type'] as String),
  title: json['title'] as String?,
  issuer: json['issuer'] as String?,
  achievedOn: json['achievedOn'] as String?,
  description: json['description'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$UpdateAchievementDtoToJson(
  UpdateAchievementDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'title': instance.title,
  'issuer': instance.issuer,
  'achievedOn': instance.achievedOn,
  'description': instance.description,
  'url': instance.url,
};

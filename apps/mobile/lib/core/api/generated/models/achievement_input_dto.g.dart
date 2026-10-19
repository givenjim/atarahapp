// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_input_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AchievementInputDto _$AchievementInputDtoFromJson(Map<String, dynamic> json) =>
    AchievementInputDto(
      type: AchievementInputDtoType.fromJson(json['type'] as String),
      title: json['title'] as String,
      issuer: json['issuer'] as String?,
      achievedOn: json['achievedOn'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AchievementInputDtoToJson(
  AchievementInputDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'title': instance.title,
  'issuer': instance.issuer,
  'achievedOn': instance.achievedOn,
  'description': instance.description,
  'url': instance.url,
};

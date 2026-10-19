// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AchievementDto _$AchievementDtoFromJson(Map<String, dynamic> json) =>
    AchievementDto(
      id: json['id'] as String,
      type: AchievementDtoType.fromJson(json['type'] as String),
      title: json['title'] as String,
      source: AchievementDtoSource.fromJson(json['source'] as String),
      issuer: json['issuer'] as String?,
      achievedOn: json['achievedOn'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AchievementDtoToJson(AchievementDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'issuer': instance.issuer,
      'achievedOn': instance.achievedOn,
      'description': instance.description,
      'url': instance.url,
      'source': instance.source,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkillEntryDto _$SkillEntryDtoFromJson(Map<String, dynamic> json) =>
    SkillEntryDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      source: SkillEntryDtoSource.fromJson(json['source'] as String),
      projectCount: json['projectCount'] as num,
      level: json['level'] == null
          ? null
          : SkillEntryDtoLevel.fromJson(json['level'] as String),
    );

Map<String, dynamic> _$SkillEntryDtoToJson(SkillEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'level': instance.level,
      'source': instance.source,
      'projectCount': instance.projectCount,
    };

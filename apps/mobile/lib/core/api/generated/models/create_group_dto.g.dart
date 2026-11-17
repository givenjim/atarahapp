// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGroupDto _$CreateGroupDtoFromJson(Map<String, dynamic> json) =>
    CreateGroupDto(
      name: json['name'] as String,
      type: GroupType.fromJson(json['type'] as String),
      isOfficial: json['isOfficial'] as bool? ?? true,
      visibility: json['visibility'] == null
          ? GroupVisibility.open
          : GroupVisibility.fromJson(json['visibility'] as String),
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      disciplineId: json['disciplineId'] as String?,
      countyId: json['countyId'] as String?,
      coverMediaId: json['coverMediaId'] as String?,
    );

Map<String, dynamic> _$CreateGroupDtoToJson(CreateGroupDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'type': instance.type,
      'description': instance.description,
      'disciplineId': instance.disciplineId,
      'countyId': instance.countyId,
      'coverMediaId': instance.coverMediaId,
      'isOfficial': instance.isOfficial,
      'visibility': instance.visibility,
    };

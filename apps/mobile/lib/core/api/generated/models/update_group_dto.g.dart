// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateGroupDto _$UpdateGroupDtoFromJson(Map<String, dynamic> json) =>
    UpdateGroupDto(
      name: json['name'] as String,
      description: json['description'] as String,
      disciplineId: json['disciplineId'] as String?,
      countyId: json['countyId'] as String?,
      coverMediaId: json['coverMediaId'] as String?,
      isOfficial: json['isOfficial'] as bool,
      visibility: GroupVisibility.fromJson(json['visibility'] as String),
    );

Map<String, dynamic> _$UpdateGroupDtoToJson(UpdateGroupDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'disciplineId': instance.disciplineId,
      'countyId': instance.countyId,
      'coverMediaId': instance.coverMediaId,
      'isOfficial': instance.isOfficial,
      'visibility': instance.visibility,
    };

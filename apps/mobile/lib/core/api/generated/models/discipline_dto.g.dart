// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discipline_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisciplineDto _$DisciplineDtoFromJson(Map<String, dynamic> json) =>
    DisciplineDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      specialisations: (json['specialisations'] as List<dynamic>)
          .map((e) => SpecialisationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DisciplineDtoToJson(DisciplineDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'icon': instance.icon,
      'specialisations': instance.specialisations,
    };

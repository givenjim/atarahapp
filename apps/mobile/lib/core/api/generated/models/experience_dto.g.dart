// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperienceDto _$ExperienceDtoFromJson(Map<String, dynamic> json) =>
    ExperienceDto(
      id: json['id'] as String,
      title: json['title'] as String,
      organisation: json['organisation'] as String,
      startDate: json['startDate'] as String,
      current: json['current'] as bool,
      location: json['location'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ExperienceDtoToJson(ExperienceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'organisation': instance.organisation,
      'location': instance.location,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'current': instance.current,
      'description': instance.description,
    };

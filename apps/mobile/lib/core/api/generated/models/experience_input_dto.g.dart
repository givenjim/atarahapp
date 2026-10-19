// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_input_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperienceInputDto _$ExperienceInputDtoFromJson(Map<String, dynamic> json) =>
    ExperienceInputDto(
      title: json['title'] as String,
      organisation: json['organisation'] as String,
      startDate: json['startDate'] as String,
      current: json['current'] as bool,
      location: json['location'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ExperienceInputDtoToJson(ExperienceInputDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'organisation': instance.organisation,
      'location': instance.location,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'current': instance.current,
      'description': instance.description,
    };

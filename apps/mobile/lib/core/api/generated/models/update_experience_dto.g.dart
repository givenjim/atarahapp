// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_experience_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateExperienceDto _$UpdateExperienceDtoFromJson(Map<String, dynamic> json) =>
    UpdateExperienceDto(
      title: json['title'] as String?,
      organisation: json['organisation'] as String?,
      location: json['location'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      current: json['current'] as bool?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UpdateExperienceDtoToJson(
  UpdateExperienceDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'organisation': instance.organisation,
  'location': instance.location,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'current': instance.current,
  'description': instance.description,
};

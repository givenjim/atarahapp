// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_cv_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCvDto _$UpdateCvDtoFromJson(Map<String, dynamic> json) => UpdateCvDto(
  sections: (json['sections'] as List<dynamic>?)
      ?.map((e) => UpdateCvDtoSections.fromJson(e as String))
      .toList(),
  projectIds: (json['projectIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  restricted: (json['restricted'] as List<dynamic>?)
      ?.map((e) => UpdateCvDtoRestricted.fromJson(e as String))
      .toList(),
);

Map<String, dynamic> _$UpdateCvDtoToJson(UpdateCvDto instance) =>
    <String, dynamic>{
      'sections': instance.sections,
      'projectIds': instance.projectIds,
      'restricted': instance.restricted,
    };

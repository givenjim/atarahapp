// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvConfigDto _$CvConfigDtoFromJson(Map<String, dynamic> json) => CvConfigDto(
  sections: (json['sections'] as List<dynamic>)
      .map((e) => CvConfigDtoSections.fromJson(e as String))
      .toList(),
  projectIds: (json['projectIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  restricted: (json['restricted'] as List<dynamic>)
      .map((e) => CvConfigDtoRestricted.fromJson(e as String))
      .toList(),
);

Map<String, dynamic> _$CvConfigDtoToJson(CvConfigDto instance) =>
    <String, dynamic>{
      'sections': instance.sections,
      'projectIds': instance.projectIds,
      'restricted': instance.restricted,
    };

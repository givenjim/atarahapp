// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_section_audience_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvSectionAudienceDto _$CvSectionAudienceDtoFromJson(
  Map<String, dynamic> json,
) => CvSectionAudienceDto(
  section: CvSectionAudienceDtoSection.fromJson(json['section'] as String),
  visibility: CvSectionAudienceDtoVisibility.fromJson(
    json['visibility'] as String,
  ),
  available: json['available'] as bool,
);

Map<String, dynamic> _$CvSectionAudienceDtoToJson(
  CvSectionAudienceDto instance,
) => <String, dynamic>{
  'section': instance.section,
  'visibility': instance.visibility,
  'available': instance.available,
};

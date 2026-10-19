// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_visibility_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SectionVisibilityDto _$SectionVisibilityDtoFromJson(
  Map<String, dynamic> json,
) => SectionVisibilityDto(
  section: SectionVisibilityDtoSection.fromJson(json['section'] as String),
  visibility: SectionVisibilityDtoVisibility.fromJson(
    json['visibility'] as String,
  ),
);

Map<String, dynamic> _$SectionVisibilityDtoToJson(
  SectionVisibilityDto instance,
) => <String, dynamic>{
  'section': instance.section,
  'visibility': instance.visibility,
};

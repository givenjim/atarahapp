// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_section_visibility_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetSectionVisibilityDto _$SetSectionVisibilityDtoFromJson(
  Map<String, dynamic> json,
) => SetSectionVisibilityDto(
  section: SetSectionVisibilityDtoSection.fromJson(json['section'] as String),
  visibility: SetSectionVisibilityDtoVisibility.fromJson(
    json['visibility'] as String,
  ),
);

Map<String, dynamic> _$SetSectionVisibilityDtoToJson(
  SetSectionVisibilityDto instance,
) => <String, dynamic>{
  'section': instance.section,
  'visibility': instance.visibility,
};

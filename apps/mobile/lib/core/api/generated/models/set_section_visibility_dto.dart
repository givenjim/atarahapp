// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'set_section_visibility_dto_section.dart';
import 'set_section_visibility_dto_visibility.dart';

part 'set_section_visibility_dto.g.dart';

@JsonSerializable()
class SetSectionVisibilityDto {
  const SetSectionVisibilityDto({
    required this.section,
    required this.visibility,
  });

  factory SetSectionVisibilityDto.fromJson(Map<String, Object?> json) =>
      _$SetSectionVisibilityDtoFromJson(json);

  final SetSectionVisibilityDtoSection section;
  final SetSectionVisibilityDtoVisibility visibility;

  Map<String, Object?> toJson() => _$SetSectionVisibilityDtoToJson(this);
}

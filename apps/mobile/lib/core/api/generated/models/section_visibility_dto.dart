// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'section_visibility_dto_section.dart';
import 'section_visibility_dto_visibility.dart';

part 'section_visibility_dto.g.dart';

@JsonSerializable()
class SectionVisibilityDto {
  const SectionVisibilityDto({required this.section, required this.visibility});

  factory SectionVisibilityDto.fromJson(Map<String, Object?> json) =>
      _$SectionVisibilityDtoFromJson(json);

  final SectionVisibilityDtoSection section;
  final SectionVisibilityDtoVisibility visibility;

  Map<String, Object?> toJson() => _$SectionVisibilityDtoToJson(this);
}

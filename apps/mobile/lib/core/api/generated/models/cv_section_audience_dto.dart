// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_section_audience_dto_section.dart';
import 'cv_section_audience_dto_visibility.dart';

part 'cv_section_audience_dto.g.dart';

@JsonSerializable()
class CvSectionAudienceDto {
  const CvSectionAudienceDto({
    required this.section,
    required this.visibility,
    required this.available,
  });
  
  factory CvSectionAudienceDto.fromJson(Map<String, Object?> json) => _$CvSectionAudienceDtoFromJson(json);
  
  final CvSectionAudienceDtoSection section;
  final CvSectionAudienceDtoVisibility visibility;

  /// Whether the member may include it in this format at all.
  final bool available;

  Map<String, Object?> toJson() => _$CvSectionAudienceDtoToJson(this);
}

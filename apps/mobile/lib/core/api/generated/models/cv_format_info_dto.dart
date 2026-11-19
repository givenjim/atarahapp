// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_format_info_dto_allowed_sections.dart';
import 'cv_format_info_dto_default_sections.dart';
import 'cv_format_info_dto_format.dart';

part 'cv_format_info_dto.g.dart';

@JsonSerializable()
class CvFormatInfoDto {
  const CvFormatInfoDto({
    required this.format,
    required this.label,
    required this.allowedSections,
    required this.defaultSections,
    required this.maxProjects,
  });
  
  factory CvFormatInfoDto.fromJson(Map<String, Object?> json) => _$CvFormatInfoDtoFromJson(json);
  
  final CvFormatInfoDtoFormat format;
  final String label;
  final List<CvFormatInfoDtoAllowedSections> allowedSections;
  final List<CvFormatInfoDtoDefaultSections> defaultSections;

  /// The most projects the layout lists (0 means the format lists none).
  final num maxProjects;

  Map<String, Object?> toJson() => _$CvFormatInfoDtoToJson(this);
}

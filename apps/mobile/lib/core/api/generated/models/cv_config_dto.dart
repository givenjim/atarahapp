// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_config_dto_restricted.dart';
import 'cv_config_dto_sections.dart';

part 'cv_config_dto.g.dart';

@JsonSerializable()
class CvConfigDto {
  const CvConfigDto({
    required this.sections,
    required this.projectIds,
    required this.restricted,
  });
  
  factory CvConfigDto.fromJson(Map<String, Object?> json) => _$CvConfigDtoFromJson(json);
  
  final List<CvConfigDtoSections> sections;
  final List<String> projectIds;
  final List<CvConfigDtoRestricted> restricted;

  Map<String, Object?> toJson() => _$CvConfigDtoToJson(this);
}

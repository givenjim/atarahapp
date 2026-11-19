// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cv_preview_skill_dto.g.dart';

@JsonSerializable()
class CvPreviewSkillDto {
  const CvPreviewSkillDto({
    required this.name,
    required this.verified,
  });
  
  factory CvPreviewSkillDto.fromJson(Map<String, Object?> json) => _$CvPreviewSkillDtoFromJson(json);
  
  final String name;

  /// True only when Atarah has verified this skill.
  final bool verified;

  Map<String, Object?> toJson() => _$CvPreviewSkillDtoToJson(this);
}

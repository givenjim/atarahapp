// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_preview_dto_included.dart';
import 'cv_preview_dto_withheld.dart';
import 'cv_preview_skill_dto.dart';
import 'cv_preview_work_dto.dart';

part 'cv_preview_dto.g.dart';

@JsonSerializable()
class CvPreviewDto {
  const CvPreviewDto({
    required this.displayName,
    required this.subtitle,
    required this.identityVerified,
    required this.work,
    required this.skills,
    required this.included,
    required this.withheld,
    this.avatarUrl,
    this.summary,
  });
  
  factory CvPreviewDto.fromJson(Map<String, Object?> json) => _$CvPreviewDtoFromJson(json);
  
  final String displayName;

  /// The format label shown under the name, e.g. "Creative CV".
  final String subtitle;
  final String? avatarUrl;
  final bool identityVerified;
  final String? summary;
  final List<CvPreviewWorkDto> work;
  final List<CvPreviewSkillDto> skills;
  final List<CvPreviewDtoIncluded> included;

  /// Picked sections left out because they are not public and not explicitly allowed.
  final List<CvPreviewDtoWithheld> withheld;

  Map<String, Object?> toJson() => _$CvPreviewDtoToJson(this);
}

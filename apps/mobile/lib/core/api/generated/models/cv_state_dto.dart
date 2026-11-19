// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_config_dto.dart';
import 'cv_format_info_dto.dart';
import 'cv_preview_dto.dart';
import 'cv_project_choice_dto.dart';
import 'cv_render_dto.dart';
import 'cv_section_audience_dto.dart';
import 'cv_share_dto.dart';

part 'cv_state_dto.g.dart';

@JsonSerializable()
class CvStateDto {
  const CvStateDto({
    required this.info,
    required this.config,
    required this.sections,
    required this.projects,
    required this.preview,
    required this.shares,
    this.latestRender,
  });
  
  factory CvStateDto.fromJson(Map<String, Object?> json) => _$CvStateDtoFromJson(json);
  
  final CvFormatInfoDto info;
  final CvConfigDto config;
  final List<CvSectionAudienceDto> sections;

  /// Published projects the member can list.
  final List<CvProjectChoiceDto> projects;
  final CvPreviewDto preview;
  final CvRenderDto? latestRender;
  final List<CvShareDto> shares;

  Map<String, Object?> toJson() => _$CvStateDtoToJson(this);
}

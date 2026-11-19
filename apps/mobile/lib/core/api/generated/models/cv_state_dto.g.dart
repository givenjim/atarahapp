// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvStateDto _$CvStateDtoFromJson(Map<String, dynamic> json) => CvStateDto(
  info: CvFormatInfoDto.fromJson(json['info'] as Map<String, dynamic>),
  config: CvConfigDto.fromJson(json['config'] as Map<String, dynamic>),
  sections: (json['sections'] as List<dynamic>)
      .map((e) => CvSectionAudienceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  projects: (json['projects'] as List<dynamic>)
      .map((e) => CvProjectChoiceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  preview: CvPreviewDto.fromJson(json['preview'] as Map<String, dynamic>),
  shares: (json['shares'] as List<dynamic>)
      .map((e) => CvShareDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  latestRender: json['latestRender'] == null
      ? null
      : CvRenderDto.fromJson(json['latestRender'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CvStateDtoToJson(CvStateDto instance) =>
    <String, dynamic>{
      'info': instance.info,
      'config': instance.config,
      'sections': instance.sections,
      'projects': instance.projects,
      'preview': instance.preview,
      'latestRender': instance.latestRender,
      'shares': instance.shares,
    };

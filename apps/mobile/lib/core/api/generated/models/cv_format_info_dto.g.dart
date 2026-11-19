// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_format_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvFormatInfoDto _$CvFormatInfoDtoFromJson(Map<String, dynamic> json) =>
    CvFormatInfoDto(
      format: CvFormatInfoDtoFormat.fromJson(json['format'] as String),
      label: json['label'] as String,
      allowedSections: (json['allowedSections'] as List<dynamic>)
          .map((e) => CvFormatInfoDtoAllowedSections.fromJson(e as String))
          .toList(),
      defaultSections: (json['defaultSections'] as List<dynamic>)
          .map((e) => CvFormatInfoDtoDefaultSections.fromJson(e as String))
          .toList(),
      maxProjects: json['maxProjects'] as num,
    );

Map<String, dynamic> _$CvFormatInfoDtoToJson(CvFormatInfoDto instance) =>
    <String, dynamic>{
      'format': instance.format,
      'label': instance.label,
      'allowedSections': instance.allowedSections,
      'defaultSections': instance.defaultSections,
      'maxProjects': instance.maxProjects,
    };

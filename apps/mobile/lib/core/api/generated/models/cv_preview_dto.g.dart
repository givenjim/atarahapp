// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_preview_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvPreviewDto _$CvPreviewDtoFromJson(Map<String, dynamic> json) => CvPreviewDto(
  displayName: json['displayName'] as String,
  subtitle: json['subtitle'] as String,
  identityVerified: json['identityVerified'] as bool,
  work: (json['work'] as List<dynamic>)
      .map((e) => CvPreviewWorkDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  skills: (json['skills'] as List<dynamic>)
      .map((e) => CvPreviewSkillDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  included: (json['included'] as List<dynamic>)
      .map((e) => CvPreviewDtoIncluded.fromJson(e as String))
      .toList(),
  withheld: (json['withheld'] as List<dynamic>)
      .map((e) => CvPreviewDtoWithheld.fromJson(e as String))
      .toList(),
  avatarUrl: json['avatarUrl'] as String?,
  summary: json['summary'] as String?,
);

Map<String, dynamic> _$CvPreviewDtoToJson(CvPreviewDto instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'subtitle': instance.subtitle,
      'avatarUrl': instance.avatarUrl,
      'identityVerified': instance.identityVerified,
      'summary': instance.summary,
      'work': instance.work,
      'skills': instance.skills,
      'included': instance.included,
      'withheld': instance.withheld,
    };

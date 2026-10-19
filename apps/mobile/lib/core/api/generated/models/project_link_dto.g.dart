// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_link_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectLinkDto _$ProjectLinkDtoFromJson(Map<String, dynamic> json) =>
    ProjectLinkDto(
      id: json['id'] as String,
      label: json['label'] as String,
      url: json['url'] as String,
      embedUrl: json['embedUrl'] as String?,
    );

Map<String, dynamic> _$ProjectLinkDtoToJson(ProjectLinkDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'url': instance.url,
      'embedUrl': instance.embedUrl,
    };

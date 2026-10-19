// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectMediaDto _$ProjectMediaDtoFromJson(Map<String, dynamic> json) =>
    ProjectMediaDto(
      id: json['id'] as String,
      kind: ProjectMediaDtoKind.fromJson(json['kind'] as String),
      mimeType: json['mimeType'] as String,
      status: ProjectMediaDtoStatus.fromJson(json['status'] as String),
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: json['width'] as num?,
      height: json['height'] as num?,
      caption: json['caption'] as String?,
    );

Map<String, dynamic> _$ProjectMediaDtoToJson(ProjectMediaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'mimeType': instance.mimeType,
      'status': instance.status,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'width': instance.width,
      'height': instance.height,
      'caption': instance.caption,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProjectDto _$UpdateProjectDtoFromJson(Map<String, dynamic> json) =>
    UpdateProjectDto(
      title: json['title'] as String?,
      role: json['role'] as String?,
      client: json['client'] as String?,
      projectDate: json['projectDate'] as String?,
      category: json['category'] == null
          ? null
          : UpdateProjectDtoCategory.fromJson(json['category'] as String),
      disciplineId: json['disciplineId'],
      description: json['description'] as String?,
      outcome: json['outcome'] as String?,
      featured: json['featured'] as bool?,
      visibility: json['visibility'] == null
          ? null
          : UpdateProjectDtoVisibility.fromJson(json['visibility'] as String),
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      skillIds: (json['skillIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => ProfileLinkInputDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateProjectDtoToJson(UpdateProjectDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'role': instance.role,
      'client': instance.client,
      'projectDate': instance.projectDate,
      'category': instance.category,
      'disciplineId': instance.disciplineId,
      'description': instance.description,
      'outcome': instance.outcome,
      'featured': instance.featured,
      'visibility': instance.visibility,
      'mediaIds': instance.mediaIds,
      'skillIds': instance.skillIds,
      'links': instance.links,
    };

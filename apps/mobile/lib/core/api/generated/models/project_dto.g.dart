// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
  id: json['id'] as String,
  title: json['title'] as String,
  category: ProjectDtoCategory.fromJson(json['category'] as String),
  featured: json['featured'] as bool,
  status: ProjectDtoStatus.fromJson(json['status'] as String),
  visibility: ProjectDtoVisibility.fromJson(json['visibility'] as String),
  mediaCount: json['mediaCount'] as num,
  hidden: json['hidden'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  skills: (json['skills'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  media: (json['media'] as List<dynamic>)
      .map((e) => ProjectMediaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  links: (json['links'] as List<dynamic>)
      .map((e) => ProjectLinkDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  collaborators: (json['collaborators'] as List<dynamic>)
      .map((e) => CollaboratorDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  role: json['role'] as String?,
  projectDate: json['projectDate'] as String?,
  coverUrl: json['coverUrl'] as String?,
  client: json['client'] as String?,
  description: json['description'] as String?,
  outcome: json['outcome'] as String?,
  discipline: json['discipline'] == null
      ? null
      : DisciplineLite.fromJson(json['discipline'] as Map<String, dynamic>),
  hiddenReason: json['hiddenReason'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'role': instance.role,
      'category': instance.category,
      'projectDate': instance.projectDate,
      'featured': instance.featured,
      'status': instance.status,
      'visibility': instance.visibility,
      'coverUrl': instance.coverUrl,
      'mediaCount': instance.mediaCount,
      'hidden': instance.hidden,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'client': instance.client,
      'description': instance.description,
      'outcome': instance.outcome,
      'discipline': instance.discipline,
      'skills': instance.skills,
      'media': instance.media,
      'links': instance.links,
      'collaborators': instance.collaborators,
      'hiddenReason': instance.hiddenReason,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

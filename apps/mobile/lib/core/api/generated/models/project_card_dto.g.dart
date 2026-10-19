// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectCardDto _$ProjectCardDtoFromJson(Map<String, dynamic> json) =>
    ProjectCardDto(
      id: json['id'] as String,
      title: json['title'] as String,
      category: ProjectCardDtoCategory.fromJson(json['category'] as String),
      featured: json['featured'] as bool,
      status: ProjectCardDtoStatus.fromJson(json['status'] as String),
      visibility: ProjectCardDtoVisibility.fromJson(
        json['visibility'] as String,
      ),
      mediaCount: json['mediaCount'] as num,
      hidden: json['hidden'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      role: json['role'] as String?,
      projectDate: json['projectDate'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );

Map<String, dynamic> _$ProjectCardDtoToJson(ProjectCardDto instance) =>
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
    };

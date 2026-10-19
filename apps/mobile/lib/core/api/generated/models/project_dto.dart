// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collaborator_dto.dart';
import 'discipline_lite.dart';
import 'project_dto_category.dart';
import 'project_dto_status.dart';
import 'project_dto_visibility.dart';
import 'project_link_dto.dart';
import 'project_media_dto.dart';
import 'taxonomy_item_dto.dart';

part 'project_dto.g.dart';

@JsonSerializable()
class ProjectDto {
  const ProjectDto({
    required this.id,
    required this.title,
    required this.category,
    required this.featured,
    required this.status,
    required this.visibility,
    required this.mediaCount,
    required this.hidden,
    required this.updatedAt,
    required this.skills,
    required this.media,
    required this.links,
    required this.collaborators,
    this.role,
    this.projectDate,
    this.coverUrl,
    this.client,
    this.description,
    this.outcome,
    this.discipline,
    this.hiddenReason,
    this.publishedAt,
  });

  factory ProjectDto.fromJson(Map<String, Object?> json) =>
      _$ProjectDtoFromJson(json);

  final String id;
  final String title;
  final String? role;
  final ProjectDtoCategory category;

  /// A calendar date, YYYY-MM-DD.
  final String? projectDate;
  final bool featured;
  final ProjectDtoStatus status;
  final ProjectDtoVisibility visibility;
  final String? coverUrl;
  final num mediaCount;

  /// Hidden by a moderator. Only the owner ever sees a hidden project.
  final bool hidden;
  final DateTime updatedAt;
  final String? client;
  final String? description;
  final String? outcome;
  final DisciplineLite? discipline;
  final List<TaxonomyItemDto> skills;
  final List<ProjectMediaDto> media;
  final List<ProjectLinkDto> links;
  final List<CollaboratorDto> collaborators;

  /// Owner only: why a moderator hid the project.
  final String? hiddenReason;
  final DateTime? publishedAt;

  Map<String, Object?> toJson() => _$ProjectDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_project_detail_dto_category.dart';
import 'admin_project_detail_dto_status.dart';
import 'admin_project_detail_dto_visibility.dart';
import 'collaborator_dto.dart';
import 'discipline_lite.dart';
import 'project_link_dto.dart';
import 'project_media_dto.dart';
import 'taxonomy_item_dto.dart';

part 'admin_project_detail_dto.g.dart';

@JsonSerializable()
class AdminProjectDetailDto {
  const AdminProjectDetailDto({
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
    required this.ownerUserId,
    required this.ownerName,
    this.role,
    this.projectDate,
    this.coverUrl,
    this.client,
    this.description,
    this.outcome,
    this.discipline,
    this.hiddenReason,
    this.publishedAt,
    this.ownerHandle,
    this.hiddenAt,
  });

  factory AdminProjectDetailDto.fromJson(Map<String, Object?> json) =>
      _$AdminProjectDetailDtoFromJson(json);

  final String id;
  final String title;
  final String? role;
  final AdminProjectDetailDtoCategory category;

  /// A calendar date, YYYY-MM-DD.
  final String? projectDate;
  final bool featured;
  final AdminProjectDetailDtoStatus status;
  final AdminProjectDetailDtoVisibility visibility;
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
  final String ownerUserId;
  final String ownerName;
  final String? ownerHandle;
  final DateTime? hiddenAt;

  Map<String, Object?> toJson() => _$AdminProjectDetailDtoToJson(this);
}

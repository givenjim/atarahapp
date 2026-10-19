// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_card_dto_category.dart';
import 'project_card_dto_status.dart';
import 'project_card_dto_visibility.dart';

part 'project_card_dto.g.dart';

@JsonSerializable()
class ProjectCardDto {
  const ProjectCardDto({
    required this.id,
    required this.title,
    required this.category,
    required this.featured,
    required this.status,
    required this.visibility,
    required this.mediaCount,
    required this.hidden,
    required this.updatedAt,
    this.role,
    this.projectDate,
    this.coverUrl,
  });

  factory ProjectCardDto.fromJson(Map<String, Object?> json) =>
      _$ProjectCardDtoFromJson(json);

  final String id;
  final String title;
  final String? role;
  final ProjectCardDtoCategory category;

  /// A calendar date, YYYY-MM-DD.
  final String? projectDate;
  final bool featured;
  final ProjectCardDtoStatus status;
  final ProjectCardDtoVisibility visibility;
  final String? coverUrl;
  final num mediaCount;

  /// Hidden by a moderator. Only the owner ever sees a hidden project.
  final bool hidden;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$ProjectCardDtoToJson(this);
}

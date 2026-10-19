// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'profile_link_input_dto.dart';
import 'update_project_dto_category.dart';
import 'update_project_dto_visibility.dart';

part 'update_project_dto.g.dart';

@JsonSerializable()
class UpdateProjectDto {
  const UpdateProjectDto({
    this.title,
    this.role,
    this.client,
    this.projectDate,
    this.category,
    this.disciplineId,
    this.description,
    this.outcome,
    this.featured,
    this.visibility,
    this.mediaIds,
    this.skillIds,
    this.links,
  });

  factory UpdateProjectDto.fromJson(Map<String, Object?> json) =>
      _$UpdateProjectDtoFromJson(json);

  final String? title;

  /// Your role on the project. Empty clears it.
  final String? role;

  /// Empty clears it.
  final String? client;

  /// A calendar date, YYYY-MM-DD. Empty clears it.
  final String? projectDate;
  final UpdateProjectDtoCategory? category;
  final dynamic disciplineId;
  final String? description;

  /// What the work achieved.
  final String? outcome;
  final bool? featured;
  final UpdateProjectDtoVisibility? visibility;

  /// Your uploaded files in display order; the first is the cover. Replaces the list. At most 10.
  final List<String>? mediaIds;

  /// Skills used. Replaces the list. At most 10.
  final List<String>? skillIds;

  /// External links. Replaces the list. At most 5.
  final List<ProfileLinkInputDto>? links;

  Map<String, Object?> toJson() => _$UpdateProjectDtoToJson(this);
}

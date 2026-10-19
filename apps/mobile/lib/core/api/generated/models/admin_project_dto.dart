// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_project_dto_category.dart';
import 'admin_project_dto_status.dart';
import 'admin_project_dto_visibility.dart';

part 'admin_project_dto.g.dart';

@JsonSerializable()
class AdminProjectDto {
  const AdminProjectDto({
    required this.id,
    required this.title,
    required this.category,
    required this.featured,
    required this.status,
    required this.visibility,
    required this.mediaCount,
    required this.hidden,
    required this.updatedAt,
    required this.ownerUserId,
    required this.ownerName,
    this.role,
    this.projectDate,
    this.coverUrl,
    this.ownerHandle,
    this.hiddenReason,
    this.hiddenAt,
  });

  factory AdminProjectDto.fromJson(Map<String, Object?> json) =>
      _$AdminProjectDtoFromJson(json);

  final String id;
  final String title;
  final String? role;
  final AdminProjectDtoCategory category;

  /// A calendar date, YYYY-MM-DD.
  final String? projectDate;
  final bool featured;
  final AdminProjectDtoStatus status;
  final AdminProjectDtoVisibility visibility;
  final String? coverUrl;
  final num mediaCount;

  /// Hidden by a moderator. Only the owner ever sees a hidden project.
  final bool hidden;
  final DateTime updatedAt;
  final String ownerUserId;
  final String ownerName;
  final String? ownerHandle;
  final String? hiddenReason;
  final DateTime? hiddenAt;

  Map<String, Object?> toJson() => _$AdminProjectDtoToJson(this);
}

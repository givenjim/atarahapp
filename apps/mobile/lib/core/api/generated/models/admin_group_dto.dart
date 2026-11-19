// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_group_dto_role.dart';
import 'admin_group_moderator_dto.dart';
import 'group_type.dart';
import 'group_visibility.dart';

part 'admin_group_dto.g.dart';

@JsonSerializable()
class AdminGroupDto {
  const AdminGroupDto({
    required this.id,
    required this.slug,
    required this.type,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.memberCount,
    required this.isOfficial,
    required this.focus,
    required this.joined,
    required this.role,
    required this.visibility,
    required this.disciplineId,
    required this.countyId,
    required this.coverMediaId,
    required this.archivedAt,
    required this.moderators,
    required this.pinnedPostIds,
    required this.createdAt,
  });
  
  factory AdminGroupDto.fromJson(Map<String, Object?> json) => _$AdminGroupDtoFromJson(json);
  
  final String id;
  final String slug;
  final GroupType type;
  final String name;
  final String description;
  final String? coverUrl;
  final num memberCount;

  /// Run by Atarah.
  final bool isOfficial;

  /// Discipline or county the group is about.
  final String? focus;
  final bool joined;
  final AdminGroupDtoRole? role;
  final GroupVisibility visibility;
  final String? disciplineId;
  final String? countyId;
  final String? coverMediaId;
  final DateTime? archivedAt;
  final List<AdminGroupModeratorDto> moderators;

  /// Pinned post ids, newest first.
  final List<String> pinnedPostIds;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminGroupDtoToJson(this);
}

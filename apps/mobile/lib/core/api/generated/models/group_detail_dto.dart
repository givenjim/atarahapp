// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_detail_dto_role.dart';
import 'group_type.dart';
import 'group_viewer_dto.dart';
import 'group_visibility.dart';
import 'post_view_dto.dart';

part 'group_detail_dto.g.dart';

@JsonSerializable()
class GroupDetailDto {
  const GroupDetailDto({
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
    required this.pinned,
    required this.recentDiscussions,
    required this.viewer,
  });

  factory GroupDetailDto.fromJson(Map<String, Object?> json) =>
      _$GroupDetailDtoFromJson(json);

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
  final GroupDetailDtoRole? role;
  final GroupVisibility visibility;

  /// The latest pinned announcement.
  final PostViewDto? pinned;

  /// The latest discussions, newest first.
  final List<PostViewDto> recentDiscussions;
  final GroupViewerDto viewer;

  Map<String, Object?> toJson() => _$GroupDetailDtoToJson(this);
}

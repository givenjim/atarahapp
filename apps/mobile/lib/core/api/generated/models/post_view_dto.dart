// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_audience.dart';
import 'post_author_dto.dart';
import 'post_group_ref_dto.dart';
import 'post_link_preview_dto.dart';
import 'post_media_item_dto.dart';
import 'post_type.dart';
import 'post_view_status.dart';
import 'post_viewer_dto.dart';

part 'post_view_dto.g.dart';

@JsonSerializable()
class PostViewDto {
  const PostViewDto({
    required this.id,
    required this.type,
    required this.body,
    required this.audience,
    required this.group,
    required this.author,
    required this.media,
    required this.link,
    required this.reactionCount,
    required this.replyCount,
    required this.isStaffAnnouncement,
    required this.status,
    required this.viewer,
    required this.createdAt,
    required this.editedAt,
  });
  
  factory PostViewDto.fromJson(Map<String, Object?> json) => _$PostViewDtoFromJson(json);
  
  final String id;
  final PostType type;
  final String body;
  final PostAudience audience;
  final PostGroupRefDto? group;
  final PostAuthorDto author;
  final List<PostMediaItemDto> media;
  final PostLinkPreviewDto? link;
  final num reactionCount;
  final num replyCount;
  final bool isStaffAnnouncement;

  /// HIDDEN only on the author’s own post after a moderator hid it.
  final PostViewStatus status;
  final PostViewerDto viewer;
  final DateTime createdAt;
  final DateTime? editedAt;

  Map<String, Object?> toJson() => _$PostViewDtoToJson(this);
}

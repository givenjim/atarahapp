// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_audience.dart';
import 'post_type.dart';

part 'create_post_dto.g.dart';

@JsonSerializable()
class CreatePostDto {
  const CreatePostDto({
    required this.type,
    this.audience = PostAudience.members,
    this.body,
    this.groupId,
    this.mediaIds,
    this.linkUrl,
  });
  
  factory CreatePostDto.fromJson(Map<String, Object?> json) => _$CreatePostDtoFromJson(json);
  
  /// ANNOUNCEMENT needs the community.announce permission.
  final PostType type;

  /// Required unless the post has media or a link.
  final String? body;

  /// GROUP is implied by `groupId`.
  final PostAudience audience;

  /// Post into a group you belong to.
  final String? groupId;

  /// Your uploaded images or videos (POST /media/uploads), in display order.
  final List<String>? mediaIds;

  /// One web link; its preview is fetched by the server shortly after posting.
  final String? linkUrl;

  Map<String, Object?> toJson() => _$CreatePostDtoToJson(this);
}

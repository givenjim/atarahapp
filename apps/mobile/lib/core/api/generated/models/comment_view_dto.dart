// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_author_dto.dart';
import 'reply_view_dto.dart';

part 'comment_view_dto.g.dart';

@JsonSerializable()
class CommentViewDto {
  const CommentViewDto({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.body,
    required this.author,
    required this.isMine,
    required this.createdAt,
    required this.editedAt,
    required this.replies,
  });

  factory CommentViewDto.fromJson(Map<String, Object?> json) =>
      _$CommentViewDtoFromJson(json);

  final String id;
  final String postId;

  /// Always null on a top-level comment.
  final String? parentCommentId;
  final String body;
  final PostAuthorDto author;
  final bool isMine;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// Oldest first. One reply level only.
  final List<ReplyViewDto> replies;

  Map<String, Object?> toJson() => _$CommentViewDtoToJson(this);
}
